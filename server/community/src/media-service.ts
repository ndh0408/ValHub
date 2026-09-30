import type { Repo } from './db/repo.js';
import type { MediaStore } from './media.js';
import type { ErasureLedger } from './erasures.js';

/** What the media lifecycle helpers need (kept small so the sweeper / CLI can use them too). */
export interface MediaDeps {
  repo: Repo;
  media: MediaStore;
  now: () => number;
  logError?: (msg: string) => void;
  erasureLedger?: ErasureLedger;
}

/**
 * Deletes files and rows: post deleted by its author, account deleted, orphan / expired-quarantine
 * sweep. Rows go first, so the files stop being served immediately (GET /v1/media needs an active row);
 * a file that cannot be removed is picked up later by the stray-file sweep.
 */
export async function deleteMedia(d: MediaDeps, keys: readonly string[]): Promise<void> {
  if (keys.length === 0) return;
  d.repo.deleteMediaRows([...keys]);
  for (const key of keys) {
    try {
      await d.media.delete(key);
      await d.media.deleteQuarantined(key);
    } catch (e) {
      d.logError?.(`media delete failed: ${(e as Error).name}`);
    }
  }
}

/**
 * Content hidden by reports: the files leave public serving at once (row status) and are moved to the
 * private quarantine area, where they are kept for 30 days for moderators, then purged by the sweeper.
 */
export async function quarantineMedia(d: MediaDeps, keys: readonly string[]): Promise<void> {
  if (keys.length === 0) return;
  d.repo.setMediaQuarantined([...keys], d.now());
  for (const key of keys) {
    try {
      await d.media.quarantine(key);
    } catch (e) {
      d.logError?.(`media quarantine failed: ${(e as Error).name}`);
    }
  }
}

/** Media keys of a post's `media` JSON column. */
export function postMediaKeys(mediaJson: string): string[] {
  try {
    const v: unknown = JSON.parse(mediaJson);
    return Array.isArray(v) ? v.filter((k): k is string => typeof k === 'string') : [];
  } catch {
    return [];
  }
}
