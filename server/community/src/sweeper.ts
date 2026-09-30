import { deleteMedia, quarantineMedia, type MediaDeps } from './media-service.js';

/** Uploaded but never attached to a post: removed after a day. */
export const ORPHAN_MEDIA_MS = 24 * 60 * 60_000;
/** Files of content hidden by reports stay in quarantine for moderators this long. */
export const QUARANTINE_MS = 30 * 24 * 60 * 60_000;
/** Reports are personal data (who reported what): kept 12 months at most (privacy policy). */
export const REPORT_RETENTION_MS = 365 * 24 * 60 * 60_000;
/** A file without a database row is only judged a stray after this long (an upload writes file, then row). */
export const STRAY_GRACE_MS = 60 * 60_000;

export interface SweepResult {
  hiddenQuarantined: number;
  orphanMediaDeleted: number;
  quarantinePurged: number;
  strayFilesDeleted: number;
  reportsExpired: number;
  reportsOrphaned: number;
}

/**
 * Periodic housekeeping (every 10 minutes, and once at start-up):
 * - files of hidden posts that are still public → quarantine (catch-up for failed moves / old data);
 * - orphan uploads (never attached, > 24 h) → deleted;
 * - quarantined files older than 30 days → deleted;
 * - stray files on disk without a row (e.g. a failed delete) → deleted;
 * - reports older than 12 months and reports about content that no longer exists → deleted;
 * - old rate-limit windows and LFG posts expired for more than 8 days.
 * Every step is independent and tolerant: one failure never blocks the others.
 */
export async function sweep(d: MediaDeps & { prune?: () => void }): Promise<SweepResult> {
  const now = d.now();
  const out: SweepResult = {
    hiddenQuarantined: 0,
    orphanMediaDeleted: 0,
    quarantinePurged: 0,
    strayFilesDeleted: 0,
    reportsExpired: 0,
    reportsOrphaned: 0,
  };
  const step = async (name: string, fn: () => Promise<void> | void) => {
    try {
      await fn();
    } catch (e) {
      d.logError?.(`sweep ${name} failed: ${(e as Error).name}: ${(e as Error).message}`);
    }
  };

  await step('hidden-media', async () => {
    const rows = d.repo.mediaOfHiddenPosts();
    await quarantineMedia(d, rows.map((r) => r.key));
    out.hiddenQuarantined = rows.length;
  });

  await step('orphan-media', async () => {
    const rows = d.repo.mediaOrphans(now - ORPHAN_MEDIA_MS);
    await deleteMedia(d, rows.map((r) => r.key));
    out.orphanMediaDeleted = rows.length;
  });

  await step('quarantine-expiry', async () => {
    const rows = d.repo.mediaQuarantineDue(now - QUARANTINE_MS);
    await deleteMedia(d, rows.map((r) => r.key));
    out.quarantinePurged = rows.length;
  });

  await step('stray-files', async () => {
    for (const f of await d.media.list()) {
      if (now - f.mtimeMs < STRAY_GRACE_MS) continue;
      const row = d.repo.getMedia(f.key);
      if (!row) {
        // No row: the file is not ours to keep (deleted account / post whose file delete failed).
        if (f.area === 'media') await d.media.delete(f.key);
        else await d.media.deleteQuarantined(f.key);
        out.strayFilesDeleted++;
      } else if (f.area === 'media' && row.status === 'quarantined') {
        await d.media.quarantine(f.key); // the row says hidden but the bytes are still public
      }
    }
  });

  await step('reports+cleanup', () => {
    const r = d.repo.sweepReports(now - REPORT_RETENTION_MS);
    out.reportsExpired = r.reportsExpired;
    out.reportsOrphaned = r.reportsOrphaned;
    d.repo.cleanup(now); // rate-limit windows, long-expired LFG posts
  });

  d.prune?.();
  return out;
}
