import fs from 'node:fs/promises';
import path from 'node:path';

export type ImageExt = 'jpg' | 'png' | 'webp';

export const MAX_MEDIA_BYTES = 2 * 1024 * 1024;

export const CONTENT_TYPES: Record<ImageExt, string> = {
  jpg: 'image/jpeg',
  png: 'image/png',
  webp: 'image/webp',
};

/** Media keys are fully server-generated: u/<userId 32 hex>/<random 32 hex>.<ext>. */
export const MEDIA_KEY_RE = /^u\/[0-9a-f]{32}\/[0-9a-f]{32}\.(jpg|png|webp)$/;

/** Detects the image type from magic bytes (never trust the content-type alone). */
export function sniffImage(b: Uint8Array): ImageExt | null {
  if (b.length >= 3 && b[0] === 0xff && b[1] === 0xd8 && b[2] === 0xff) return 'jpg';
  if (
    b.length >= 8 &&
    b[0] === 0x89 &&
    b[1] === 0x50 &&
    b[2] === 0x4e &&
    b[3] === 0x47 &&
    b[4] === 0x0d &&
    b[5] === 0x0a &&
    b[6] === 0x1a &&
    b[7] === 0x0a
  ) {
    return 'png';
  }
  if (
    b.length >= 12 &&
    b[0] === 0x52 && // R
    b[1] === 0x49 && // I
    b[2] === 0x46 && // F
    b[3] === 0x46 && // F
    b[8] === 0x57 && // W
    b[9] === 0x45 && // E
    b[10] === 0x42 && // B
    b[11] === 0x50 // P
  ) {
    return 'webp';
  }
  return null;
}

export interface StoredFile {
  key: string;
  mtimeMs: number;
  /** `media` = publicly servable; `quarantine` = kept privately for moderators. */
  area: 'media' | 'quarantine';
}

/** Blob storage for uploaded images. */
export interface MediaStore {
  put(key: string, bytes: Uint8Array): Promise<void>;
  /** Returns null when missing (quarantined files are never returned). */
  get(key: string): Promise<Uint8Array | null>;
  /** Deletes the public file; false when there was none. */
  delete(key: string): Promise<boolean>;
  /** Moves the public file to the private quarantine area; false when there was none. */
  quarantine(key: string): Promise<boolean>;
  /** Deletes the quarantined file; false when there was none. */
  deleteQuarantined(key: string): Promise<boolean>;
  /** Moves a quarantined file back to the public area (moderator action); false when there was none. */
  restore(key: string): Promise<boolean>;
  /** Every stored file (both areas), for the stray-file sweep. */
  list(): Promise<StoredFile[]>;
}

const isNotFound = (e: unknown) => (e as NodeJS.ErrnoException).code === 'ENOENT';

/**
 * Stores files under `<root>/<key>` (public) and `<quarantineRoot>/<key>` (private); keys are
 * validated so paths can never escape either root.
 */
export class DiskMediaStore implements MediaStore {
  private readonly root: string;
  private readonly quarantineRoot: string;

  constructor(root: string, quarantineRoot = path.join(path.dirname(path.resolve(root)), 'quarantine')) {
    this.root = path.resolve(root);
    this.quarantineRoot = path.resolve(quarantineRoot);
  }

  private resolve(base: string, key: string): string {
    if (!MEDIA_KEY_RE.test(key)) throw new Error('invalid media key');
    const full = path.resolve(base, ...key.split('/'));
    if (!full.startsWith(base + path.sep)) throw new Error('invalid media key');
    return full;
  }

  async put(key: string, bytes: Uint8Array): Promise<void> {
    const full = this.resolve(this.root, key);
    await fs.mkdir(path.dirname(full), { recursive: true });
    const tmp = `${full}.${process.pid}.tmp`;
    await fs.writeFile(tmp, bytes, { flag: 'wx' });
    await fs.rename(tmp, full);
  }

  async get(key: string): Promise<Uint8Array | null> {
    if (!MEDIA_KEY_RE.test(key)) return null;
    try {
      return await fs.readFile(this.resolve(this.root, key));
    } catch (e) {
      if (isNotFound(e)) return null;
      throw e;
    }
  }

  /** Removes a user's directory once it is empty (best effort), so no trace of the account id remains. */
  private async pruneDir(file: string): Promise<void> {
    try {
      await fs.rmdir(path.dirname(file));
    } catch {
      // not empty / already gone
    }
  }

  private async unlink(base: string, key: string): Promise<boolean> {
    if (!MEDIA_KEY_RE.test(key)) return false;
    try {
      const file = this.resolve(base, key);
      await fs.unlink(file);
      await this.pruneDir(file);
      return true;
    } catch (e) {
      if (isNotFound(e)) return false;
      throw e;
    }
  }

  delete(key: string): Promise<boolean> {
    return this.unlink(this.root, key);
  }

  deleteQuarantined(key: string): Promise<boolean> {
    return this.unlink(this.quarantineRoot, key);
  }

  private async move(from: string, to: string, key: string): Promise<boolean> {
    if (!MEDIA_KEY_RE.test(key)) return false;
    const src = this.resolve(from, key);
    const dst = this.resolve(to, key);
    try {
      await fs.mkdir(path.dirname(dst), { recursive: true });
      await fs.rename(src, dst);
      await this.pruneDir(src);
      return true;
    } catch (e) {
      if (isNotFound(e)) return false;
      throw e;
    }
  }

  quarantine(key: string): Promise<boolean> {
    return this.move(this.root, this.quarantineRoot, key);
  }

  restore(key: string): Promise<boolean> {
    return this.move(this.quarantineRoot, this.root, key);
  }

  async list(): Promise<StoredFile[]> {
    const out: StoredFile[] = [];
    for (const [base, area] of [
      [this.root, 'media'],
      [this.quarantineRoot, 'quarantine'],
    ] as const) {
      let users: string[];
      try {
        users = await fs.readdir(path.join(base, 'u'));
      } catch (e) {
        if (isNotFound(e)) continue;
        throw e;
      }
      for (const user of users) {
        let files: string[];
        try {
          files = await fs.readdir(path.join(base, 'u', user));
        } catch {
          continue;
        }
        for (const file of files) {
          const key = `u/${user}/${file}`;
          if (!MEDIA_KEY_RE.test(key)) continue; // temp files etc. are not ours to judge
          try {
            const st = await fs.stat(path.join(base, 'u', user, file));
            out.push({ key, mtimeMs: st.mtimeMs, area });
          } catch {
            // vanished meanwhile
          }
        }
      }
    }
    return out;
  }
}
