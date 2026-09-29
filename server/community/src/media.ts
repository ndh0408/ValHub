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

/** Blob storage for uploaded images. */
export interface MediaStore {
  put(key: string, bytes: Uint8Array): Promise<void>;
  /** Returns null when missing. */
  get(key: string): Promise<Uint8Array | null>;
}

/** Stores files under `<root>/<key>`; keys are validated so paths can never escape `root`. */
export class DiskMediaStore implements MediaStore {
  private readonly root: string;

  constructor(root: string) {
    this.root = path.resolve(root);
  }

  private resolve(key: string): string {
    if (!MEDIA_KEY_RE.test(key)) throw new Error('invalid media key');
    const full = path.resolve(this.root, ...key.split('/'));
    if (!full.startsWith(this.root + path.sep)) throw new Error('invalid media key');
    return full;
  }

  async put(key: string, bytes: Uint8Array): Promise<void> {
    const full = this.resolve(key);
    await fs.mkdir(path.dirname(full), { recursive: true });
    const tmp = `${full}.${process.pid}.tmp`;
    await fs.writeFile(tmp, bytes, { flag: 'wx' });
    await fs.rename(tmp, full);
  }

  async get(key: string): Promise<Uint8Array | null> {
    if (!MEDIA_KEY_RE.test(key)) return null;
    try {
      return await fs.readFile(this.resolve(key));
    } catch (e) {
      if ((e as NodeJS.ErrnoException).code === 'ENOENT') return null;
      throw e;
    }
  }
}
