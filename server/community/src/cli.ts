/**
 * Operator CLI, run inside the container:
 *
 *   docker compose exec valvn-community node dist/cli.js <command> [options]
 *
 * Commands: help | stats | find | export | delete | quarantine list|restore|purge | unhide | sweep
 * It uses the same code paths as the API (account deletion, media lifecycle, sweeper), needs no secrets
 * (only DATA_DIR), and never prints tokens; user data is printed only by `export`.
 */
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { buildExport, deleteAccount } from './account.js';
import type { Repo, UserRow } from './db/repo.js';
import { openDatabase } from './db/database.js';
import { SqliteRepo } from './db/sqlite-repo.js';
import { DiskMediaStore, MEDIA_KEY_RE, type MediaStore } from './media.js';
import { deleteMedia, postMediaKeys } from './media-service.js';
import { sweep } from './sweeper.js';
import { REPORT_TARGETS, isUuid, type ReportTarget } from './validate.js';

export interface CliDeps {
  repo: Repo;
  media: MediaStore;
  now: () => number;
  out: (line: string) => void;
  err: (line: string) => void;
  /** Base URL used for media links in exports (PUBLIC_BASE_URL). */
  baseUrl?: string;
}

const HELP = `valvn-community operator CLI

  stats                                   row counts, media bytes, quarantined files
  find --riot "Name#Tag"                  users with that Riot ID (id, region, data counts)
  export (--id <id> | --riot "Name#Tag")  all data of a user as JSON (GET /v1/me/export equivalent)
  delete (--id <id> | --riot "Name#Tag") --yes
                                          erase a user (GET/DELETE /v1/me equivalent); without --yes: dry run
  quarantine list                         files hidden by reports (kept 30 days)
  quarantine restore <key>                put a file back in public serving
  quarantine purge <key>                  delete a quarantined file now
  unhide (post|comment|lfg|review) <uuid> un-hide content and forget its reports (false report)
  sweep                                   run the housekeeping sweep once
`;

function flag(args: string[], name: string): string | undefined {
  const i = args.indexOf(`--${name}`);
  return i >= 0 ? args[i + 1] : undefined;
}

function resolveUser(args: string[], d: CliDeps): UserRow[] {
  const id = flag(args, 'id');
  if (id) {
    const u = /^[0-9a-f]{32}$/.test(id) ? d.repo.getUser(id) : null;
    return u ? [u] : [];
  }
  const riot = flag(args, 'riot');
  if (riot) {
    const at = riot.lastIndexOf('#');
    if (at <= 0 || at === riot.length - 1) return [];
    return d.repo.findUsersByRiotId(riot.slice(0, at), riot.slice(at + 1));
  }
  return [];
}

export async function runCli(argv: string[], d: CliDeps): Promise<number> {
  const [cmd, ...args] = argv;
  switch (cmd) {
    case undefined:
    case 'help':
    case '--help':
      d.out(HELP);
      return 0;

    case 'stats': {
      d.out(JSON.stringify(d.repo.stats(), null, 2));
      return 0;
    }

    case 'find': {
      const users = resolveUser(args, d);
      if (users.length === 0) {
        d.err('no such user');
        return 1;
      }
      for (const u of users) {
        const data = d.repo.accountData(u.id)!;
        d.out(
          JSON.stringify({
            id: u.id,
            gameName: u.game_name,
            tagLine: u.tag_line,
            region: u.region,
            country: u.country,
            createdAt: new Date(u.created_at).toISOString(),
            posts: data.posts.length,
            comments: data.comments.length,
            reviews: data.reviews.length,
            votes: data.votes.length,
            lfgPosts: data.lfgPosts.length,
            media: data.media.length,
          }),
        );
      }
      return 0;
    }

    case 'export': {
      const users = resolveUser(args, d);
      if (users.length !== 1) {
        d.err(users.length === 0 ? 'no such user' : 'several users match: use --id');
        return 1;
      }
      d.out(JSON.stringify(buildExport(d.repo.accountData(users[0]!.id)!, d.baseUrl ?? '', d.now()), null, 2));
      return 0;
    }

    case 'delete': {
      const users = resolveUser(args, d);
      if (users.length !== 1) {
        d.err(users.length === 0 ? 'no such user' : 'several users match: use --id');
        return 1;
      }
      const u = users[0]!;
      const data = d.repo.accountData(u.id)!;
      const summary = `${u.id} (${u.game_name}#${u.tag_line}): ${data.posts.length} posts, ${data.comments.length} comments, ${data.reviews.length} reviews, ${data.votes.length} votes, ${data.lfgPosts.length} LFG posts, ${data.media.length} files`;
      if (!args.includes('--yes')) {
        d.out(`DRY RUN, would erase ${summary}. Re-run with --yes.`);
        return 2;
      }
      await deleteAccount(d, u.id);
      d.out(`erased ${summary}`);
      return 0;
    }

    case 'quarantine': {
      const [sub, key] = args;
      if (sub === 'list') {
        const rows = d.repo.mediaQuarantineDue(Number.MAX_SAFE_INTEGER);
        for (const r of rows) {
          d.out(`${r.key}\tuser=${r.user_id}\tsince=${new Date(r.quarantined_at ?? 0).toISOString()}\tpost=${r.post_id ?? '-'}`);
        }
        if (rows.length === 0) d.out('(no quarantined files)');
        return 0;
      }
      if ((sub === 'restore' || sub === 'purge') && key && MEDIA_KEY_RE.test(key)) {
        const row = d.repo.getMedia(key);
        if (!row || row.status !== 'quarantined') {
          d.err('not a quarantined file');
          return 1;
        }
        if (sub === 'restore') {
          if (!(await d.media.restore(key))) {
            d.err('the quarantined file is missing on disk');
            return 1;
          }
          d.repo.setMediaActive([key]);
          d.out(`restored ${key}`);
        } else {
          await deleteMedia(d, [key]);
          d.out(`purged ${key}`);
        }
        return 0;
      }
      d.err(HELP);
      return 1;
    }

    case 'unhide': {
      const [type, id] = args;
      if (!type || !id || !(REPORT_TARGETS as readonly string[]).includes(type) || !isUuid(id)) {
        d.err(HELP);
        return 1;
      }
      const keys = type === 'post' ? postMediaKeys(d.repo.getPost(id, '')?.media ?? '[]') : [];
      if (!d.repo.restoreTarget(type as ReportTarget, id)) {
        d.err('no such content');
        return 1;
      }
      for (const key of keys) {
        if (d.repo.getMedia(key)?.status === 'quarantined' && (await d.media.restore(key))) d.repo.setMediaActive([key]);
      }
      d.out(`un-hidden ${type} ${id}${keys.length ? ` and ${keys.length} file(s)` : ''}`);
      return 0;
    }

    case 'sweep': {
      d.out(JSON.stringify(await sweep(d), null, 2));
      return 0;
    }

    default:
      d.err(`unknown command: ${cmd}\n${HELP}`);
      return 1;
  }
}

// Entry point when run as a script.
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const dataDir = path.resolve(process.env.DATA_DIR || '/data');
  const db = openDatabase(path.join(dataDir, 'community.db'));
  const code = await runCli(process.argv.slice(2), {
    repo: new SqliteRepo(db),
    media: new DiskMediaStore(path.join(dataDir, 'media'), path.join(dataDir, 'quarantine')),
    now: () => Date.now(),
    out: (l) => console.log(l),
    err: (l) => console.error(l),
    baseUrl: (process.env.PUBLIC_BASE_URL ?? '').replace(/\/+$/, ''),
  });
  db.close();
  process.exit(code);
}
