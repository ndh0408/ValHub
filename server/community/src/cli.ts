/**
 * Operator CLI, run inside the container:
 *
 *   docker compose exec valvn-community node dist/cli.js <command> [options]
 *
 * Commands: help | stats | find | export | delete | quarantine list|restore|purge | unhide | sweep |
 *           ban | restrict | unban | sanctions list | hide | delete-content | reports list | hidden list | audit list
 * It uses the same code paths as the API (account deletion, media lifecycle, sweeper), needs no secrets
 * (only DATA_DIR), and never prints tokens; user data is printed only by `export`. Every moderation action is
 * written to the `moderation_audit` table (structured values only, no free text).
 */
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { buildExport, deleteAccount } from './account.js';
import { REPORT_MIN_ACCOUNT_AGE_MS } from './context.js';
import type { Repo, SanctionRow, UserRow } from './db/repo.js';
import { openDatabase } from './db/database.js';
import { SqliteRepo } from './db/sqlite-repo.js';
import { DiskMediaStore, MEDIA_KEY_RE, type MediaStore } from './media.js';
import { deleteMedia, postMediaKeys, quarantineMedia } from './media-service.js';
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

/** Reason codes of a sanction / takedown (stored and shown to the user as a code, never free text). */
export const SANCTION_REASONS = ['spam', 'harassment', 'hate', 'scam', 'nsfw', 'evasion', 'minor', 'illegal', 'other'] as const;

const HELP = `valvn-community operator CLI

  stats                                   row counts, media bytes, quarantined files
  find --riot "Name#Tag"                  users with that Riot ID (id, region, data counts, active sanction)
  export (--id <id> | --riot "Name#Tag")  all data of a user as JSON (GET /v1/me/export equivalent)
  delete (--id <id> | --riot "Name#Tag") --yes
                                          erase a user (GET/DELETE /v1/me equivalent); without --yes: dry run.
                                          Sanctions survive an erasure (a banned user cannot start over).
  quarantine list                         files hidden by reports (kept 30 days)
  quarantine restore <key>                put a file back in public serving
  quarantine purge <key>                  delete a quarantined file now
  unhide (post|comment|lfg|review) <uuid> un-hide content and forget its reports (false report)
  sweep                                   run the housekeeping sweep once

  Moderation (every action is logged in the audit table; --reason is one of: ${SANCTION_REASONS.join(' ')})
  ban (--id <id> | --riot "Name#Tag") [--days N] [--reason code] --yes
                                          ban an account (no access; permanent unless --days); without --yes: dry run
  restrict (--id <id> | --riot "Name#Tag") --days N [--reason code] --yes
                                          temporary restriction: read-only (no posting, commenting, LFG, voting)
  unban (--id <id> | --riot "Name#Tag")   lift every active sanction of the account
  sanctions list [--active] [--id <id> | --riot "Name#Tag"] [--limit N]
  hide (post|comment|lfg|review) <uuid>   hide one item now (its images are quarantined)
  delete-content (post|comment|lfg|review) <uuid> --yes
                                          delete one item for good (comments / likes / images go with it); dry run without --yes
  reports list [--limit N]                reported items: reporters, eligible reporters, hidden state, excerpt
  hidden list [--limit N]                 everything that is hidden (by reports or by a moderator)
  audit list [--id <id> | --riot "Name#Tag"] [--limit N]
                                          the operator action log
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

/**
 * The account id an operation targets: `--id` is used as given (a sanction may target an account that was erased
 * or never signed in here, since the id is all that identifies it), `--riot` must match exactly one user.
 */
function resolveUserId(args: string[], d: CliDeps): { id: string; user: UserRow | null } | { error: string } {
  const id = flag(args, 'id');
  if (id) {
    if (!/^[0-9a-f]{32}$/.test(id)) return { error: '--id must be 32 hex characters' };
    return { id, user: d.repo.getUser(id) };
  }
  const users = resolveUser(args, d);
  if (users.length === 1) return { id: users[0]!.id, user: users[0]! };
  if (!flag(args, 'riot')) return { error: 'give --id <id> or --riot "Name#Tag"' };
  return { error: users.length === 0 ? 'no such user' : 'several users match: use --id' };
}

function parseReason(args: string[]): string | { error: string } {
  const r = flag(args, 'reason') ?? 'other';
  return (SANCTION_REASONS as readonly string[]).includes(r)
    ? r
    : { error: `--reason must be one of: ${SANCTION_REASONS.join(' ')}` };
}

function parseDays(args: string[], required: boolean): number | null | { error: string } {
  const raw = flag(args, 'days');
  if (raw === undefined) return required ? { error: '--days N is required (1..3650)' } : null;
  const n = Number(raw);
  return Number.isInteger(n) && n >= 1 && n <= 3650 ? n : { error: '--days must be a whole number of days (1..3650)' };
}

function parseLimit(args: string[], def: number): number {
  const n = Number(flag(args, 'limit'));
  return Number.isInteger(n) && n >= 1 && n <= 1000 ? n : def;
}

const isTarget = (t: string | undefined): t is ReportTarget => !!t && (REPORT_TARGETS as readonly string[]).includes(t);

const iso = (ms: number) => new Date(ms).toISOString();

function describeSanction(s: SanctionRow): string {
  const end = s.until === null ? 'permanent' : `until ${iso(s.until)}`;
  const lifted = s.lifted_at === null ? '' : ` lifted ${iso(s.lifted_at)}`;
  return `#${s.id} ${s.kind} ${end} reason=${s.reason} since ${iso(s.created_at)}${lifted}`;
}

export async function runCli(argv: string[], d: CliDeps): Promise<number> {
  const [cmd, ...args] = argv;
  const audit = (action: string, o: { targetType?: string; targetId?: string; userId?: string; detail?: unknown } = {}) =>
    d.repo.addAudit({ at: d.now(), action, ...o });

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
        const sanction = d.repo.activeSanction(u.id, d.now());
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
            sanction: sanction ? describeSanction(sanction) : null,
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
          audit('quarantine-restore', { targetType: 'media', targetId: key, userId: row.user_id });
          d.out(`restored ${key}`);
        } else {
          await deleteMedia(d, [key]);
          audit('quarantine-purge', { targetType: 'media', targetId: key, userId: row.user_id });
          d.out(`purged ${key}`);
        }
        return 0;
      }
      d.err(HELP);
      return 1;
    }

    case 'unhide': {
      const [type, id] = args;
      if (!isTarget(type) || !id || !isUuid(id)) {
        d.err(HELP);
        return 1;
      }
      const keys = type === 'post' ? postMediaKeys(d.repo.getPost(id, '')?.media ?? '[]') : [];
      const owner = d.repo.reportTargetOwner(type, id);
      if (!d.repo.restoreTarget(type, id)) {
        d.err('no such content');
        return 1;
      }
      for (const key of keys) {
        if (d.repo.getMedia(key)?.status === 'quarantined' && (await d.media.restore(key))) d.repo.setMediaActive([key]);
      }
      audit('unhide', { targetType: type, targetId: id, userId: owner ?? undefined, detail: { files: keys.length } });
      d.out(`un-hidden ${type} ${id}${keys.length ? ` and ${keys.length} file(s)` : ''}`);
      return 0;
    }

    case 'sweep': {
      d.out(JSON.stringify(await sweep(d), null, 2));
      return 0;
    }

    // ---- sanctions ------------------------------------------------------------------------------------------

    case 'ban':
    case 'restrict': {
      const target = resolveUserId(args, d);
      if ('error' in target) {
        d.err(target.error);
        return 1;
      }
      const reason = parseReason(args);
      if (typeof reason !== 'string') {
        d.err(reason.error);
        return 1;
      }
      const days = parseDays(args, cmd === 'restrict');
      if (days !== null && typeof days !== 'number') {
        d.err(days.error);
        return 1;
      }
      const now = d.now();
      const until = days === null ? null : now + days * 86_400_000;
      const who = target.user ? `${target.id} (${target.user.game_name}#${target.user.tag_line})` : `${target.id} (no account row)`;
      const what = `${cmd === 'ban' ? 'ban' : 'restriction (read-only)'} ${until === null ? 'permanent' : `until ${iso(until)}`}, reason ${reason}`;
      if (!args.includes('--yes')) {
        d.out(`DRY RUN, would apply ${what} to ${who}. Re-run with --yes.`);
        return 2;
      }
      const s = d.repo.addSanction({ userId: target.id, kind: cmd === 'ban' ? 'ban' : 'restrict', until, reason, now });
      if (cmd === 'ban') d.repo.bumpSessionEpoch(target.id); // sessions issued so far stop working at once
      audit(cmd, { targetType: 'user', targetId: target.id, userId: target.id, detail: { until, reason, sanction: s.id } });
      d.out(`applied ${what} to ${who}`);
      return 0;
    }

    case 'unban': {
      const target = resolveUserId(args, d);
      if ('error' in target) {
        d.err(target.error);
        return 1;
      }
      const lifted = d.repo.liftSanctions(target.id, d.now());
      audit('unban', { targetType: 'user', targetId: target.id, userId: target.id, detail: { lifted } });
      d.out(lifted > 0 ? `lifted ${lifted} sanction(s) of ${target.id}` : `${target.id} has no active sanction`);
      return lifted > 0 ? 0 : 1;
    }

    case 'sanctions': {
      if (args[0] !== 'list') {
        d.err(HELP);
        return 1;
      }
      let userId: string | undefined;
      if (flag(args, 'id') || flag(args, 'riot')) {
        const target = resolveUserId(args, d);
        if ('error' in target) {
          d.err(target.error);
          return 1;
        }
        userId = target.id;
      }
      const rows = d.repo.listSanctions({ userId, activeOnly: args.includes('--active'), now: d.now(), limit: parseLimit(args, 100) });
      for (const s of rows) d.out(`${s.user_id}\t${describeSanction(s)}`);
      if (rows.length === 0) d.out('(no sanctions)');
      return 0;
    }

    // ---- single items ----------------------------------------------------------------------------------------

    case 'hide': {
      const [type, id] = args;
      if (!isTarget(type) || !id || !isUuid(id)) {
        d.err(HELP);
        return 1;
      }
      const out = d.repo.hideTarget(type, id);
      if (!out) {
        d.err('no such content');
        return 1;
      }
      let files = 0;
      if (type === 'post') {
        const keys = postMediaKeys(d.repo.getPost(id, '')?.media ?? '[]').filter((k) => d.repo.getMedia(k)?.status === 'active');
        await quarantineMedia(d, keys);
        files = keys.length;
      }
      audit('hide', { targetType: type, targetId: id, userId: out.ownerId, detail: { newlyHidden: out.newlyHidden, files } });
      d.out(`hidden ${type} ${id} of ${out.ownerId}${files ? ` and quarantined ${files} file(s)` : ''}${out.newlyHidden ? '' : ' (was already hidden)'}`);
      return 0;
    }

    case 'delete-content': {
      const [type, id] = args;
      if (!isTarget(type) || !id || !isUuid(id)) {
        d.err(HELP);
        return 1;
      }
      const owner = d.repo.reportTargetOwner(type, id);
      if (owner === null) {
        d.err('no such content');
        return 1;
      }
      if (!args.includes('--yes')) {
        d.out(`DRY RUN, would delete ${type} ${id} of ${owner}. Re-run with --yes.`);
        return 2;
      }
      const out = d.repo.deleteTarget(type, id)!;
      await deleteMedia(d, out.mediaKeys);
      audit('delete-content', { targetType: type, targetId: id, userId: out.ownerId, detail: { files: out.mediaKeys.length } });
      d.out(`deleted ${type} ${id} of ${out.ownerId}${out.mediaKeys.length ? ` and ${out.mediaKeys.length} file(s)` : ''}`);
      return 0;
    }

    // ---- queues ----------------------------------------------------------------------------------------------

    case 'reports': {
      if (args[0] !== 'list') {
        d.err(HELP);
        return 1;
      }
      const rows = d.repo.reportedTargets({ limit: parseLimit(args, 50), now: d.now(), minReporterAgeMs: REPORT_MIN_ACCOUNT_AGE_MS });
      for (const r of rows) {
        const state = r.ownerId === null ? 'gone' : r.hidden ? `hidden(${r.hiddenReason ?? '?'})` : 'visible';
        d.out(
          `${r.type} ${r.targetId}\tauthor=${r.ownerId ?? '-'}\treports=${r.reports} eligible=${r.eligible}\t${state}\tlast=${iso(r.lastAt)}\t"${r.excerpt.replace(/\s+/g, ' ')}"\treasons: ${r.reasons.join(' | ')}`,
        );
      }
      if (rows.length === 0) d.out('(no reports)');
      return 0;
    }

    case 'hidden': {
      if (args[0] !== 'list') {
        d.err(HELP);
        return 1;
      }
      const rows = d.repo.hiddenItems(parseLimit(args, 50));
      for (const r of rows) {
        d.out(`${r.type} ${r.id}\tauthor=${r.ownerId}\thidden by ${r.hiddenReason ?? '?'}\tcreated=${iso(r.createdAt)}\t"${r.excerpt.replace(/\s+/g, ' ')}"`);
      }
      if (rows.length === 0) d.out('(nothing is hidden)');
      return 0;
    }

    case 'audit': {
      if (args[0] !== 'list') {
        d.err(HELP);
        return 1;
      }
      let userId: string | undefined;
      if (flag(args, 'id') || flag(args, 'riot')) {
        const target = resolveUserId(args, d);
        if ('error' in target) {
          d.err(target.error);
          return 1;
        }
        userId = target.id;
      }
      const rows = d.repo.listAudit({ userId, limit: parseLimit(args, 50) });
      for (const r of rows) {
        d.out(`${iso(r.at)}\t${r.action}\t${r.target_type ?? '-'} ${r.target_id ?? '-'}\tuser=${r.user_id ?? '-'}\t${r.detail ?? ''}`);
      }
      if (rows.length === 0) d.out('(no operator actions logged)');
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
