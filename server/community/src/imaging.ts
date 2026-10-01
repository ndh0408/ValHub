/** Structural parser for cheap checks and parser tests. Production uploads
 * also pass through image-decoder.ts for full native pixel decoding,
 * orientation correction and metadata-free re-encoding.
 */
import type { ImageExt } from './media.js';
import { sniffImage } from './media.js';

export class ImageError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ImageError';
  }
}

/** Larger images are refused (client-side decompression bombs: a 2 MB PNG can be 100k × 100k px). */
export const MAX_PIXELS = 16_000_000;
export const MAX_SIDE = 8192;
const MAX_SEGMENTS = 2048;

export interface SanitizedImage {
  bytes: Uint8Array;
  ext: ImageExt;
  width: number;
  height: number;
}

export function sanitizeImage(input: Uint8Array): SanitizedImage {
  const ext = sniffImage(input);
  if (ext === null) throw new ImageError('not a JPEG, PNG or WebP image');
  const r = ext === 'jpg' ? sanitizeJpeg(input) : ext === 'png' ? sanitizePng(input) : sanitizeWebp(input);
  if (r.width < 1 || r.height < 1) throw new ImageError('image has no size');
  if (r.width > MAX_SIDE || r.height > MAX_SIDE || r.width * r.height > MAX_PIXELS) {
    throw new ImageError('image is too large in pixels');
  }
  return { ...r, ext };
}

// ---- helpers ------------------------------------------------------------------------------

const ascii = (b: Uint8Array, at: number, len: number): string =>
  String.fromCharCode(...b.subarray(at, at + len));

const u16be = (b: Uint8Array, at: number): number => (b[at]! << 8) | b[at + 1]!;
const u32be = (b: Uint8Array, at: number): number =>
  ((b[at]! << 24) | (b[at + 1]! << 16) | (b[at + 2]! << 8) | b[at + 3]!) >>> 0;
const u32le = (b: Uint8Array, at: number): number =>
  (b[at]! | (b[at + 1]! << 8) | (b[at + 2]! << 16) | (b[at + 3]! << 24)) >>> 0;

function concat(parts: Uint8Array[]): Uint8Array {
  let n = 0;
  for (const p of parts) n += p.length;
  const out = new Uint8Array(n);
  let at = 0;
  for (const p of parts) {
    out.set(p, at);
    at += p.length;
  }
  return out;
}

/** EXIF orientation (1..8) from a TIFF block, or 1 when absent / unreadable. */
export function readTiffOrientation(tiff: Uint8Array): number {
  if (tiff.length < 8) return 1;
  const le = tiff[0] === 0x49 && tiff[1] === 0x49;
  const be = tiff[0] === 0x4d && tiff[1] === 0x4d;
  if (!le && !be) return 1;
  const u16 = (at: number) => (le ? tiff[at]! | (tiff[at + 1]! << 8) : (tiff[at]! << 8) | tiff[at + 1]!);
  const u32 = (at: number) =>
    le
      ? (tiff[at]! | (tiff[at + 1]! << 8) | (tiff[at + 2]! << 16) | (tiff[at + 3]! << 24)) >>> 0
      : ((tiff[at]! << 24) | (tiff[at + 1]! << 16) | (tiff[at + 2]! << 8) | tiff[at + 3]!) >>> 0;
  if (u16(2) !== 42) return 1;
  const ifd = u32(4);
  if (ifd < 8 || ifd + 2 > tiff.length) return 1;
  const count = u16(ifd);
  for (let i = 0; i < count; i++) {
    const e = ifd + 2 + i * 12;
    if (e + 12 > tiff.length) return 1;
    if (u16(e) === 0x0112 && u16(e + 2) === 3) {
      const v = u16(e + 8);
      return v >= 1 && v <= 8 ? v : 1;
    }
  }
  return 1;
}

/** A minimal big-endian TIFF block holding only the orientation tag (26 bytes). */
export function minimalTiff(orientation: number): Uint8Array {
  return Uint8Array.from([
    0x4d, 0x4d, 0x00, 0x2a, 0x00, 0x00, 0x00, 0x08, // header, IFD0 at offset 8
    0x00, 0x01, // one entry
    0x01, 0x12, 0x00, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, orientation, 0x00, 0x00, // Orientation, SHORT, 1
    0x00, 0x00, 0x00, 0x00, // no next IFD
  ]);
}

// ---- JPEG -----------------------------------------------------------------------------------

function sanitizeJpeg(b: Uint8Array): Omit<SanitizedImage, 'ext'> {
  if (b.length < 4 || b[0] !== 0xff || b[1] !== 0xd8) throw new ImageError('bad JPEG signature');
  const kept: Uint8Array[] = [];
  let firstIsJfif = false;
  let orientation = 1;
  let width = 0;
  let height = 0;
  let sawSof = false;
  let sawSos = false;
  let pos = 2;
  let ended = false;

  let segments = 0;
  while (!ended) {
    if (++segments > MAX_SEGMENTS) throw new ImageError('too many JPEG segments');
    if (pos >= b.length || b[pos] !== 0xff) throw new ImageError('bad JPEG marker');
    while (pos < b.length && b[pos] === 0xff) pos++; // fill bytes
    if (pos >= b.length) throw new ImageError('truncated JPEG');
    const m = b[pos++]!;
    if (m === 0xd9) {
      ended = true; // EOI: whatever follows is dropped
      break;
    }
    if (m === 0x00 || m === 0x01 || (m >= 0xd0 && m <= 0xd8)) {
      kept.push(Uint8Array.from([0xff, m]));
      continue;
    }
    if (pos + 2 > b.length) throw new ImageError('truncated JPEG');
    const len = u16be(b, pos);
    if (len < 2 || pos + len > b.length) throw new ImageError('bad JPEG segment length');
    const data = b.subarray(pos + 2, pos + len);
    const whole = b.subarray(pos - 2, pos + len).slice();
    whole[0] = 0xff;
    whole[1] = m;
    pos += len;

    if (m === 0xe0) {
      if (ascii(data, 0, 5) === 'JFIF\0' && data.length >= 14) {
        if (kept.length === 0) firstIsJfif = true;
        // Canonical JFIF header (length field 16): an embedded thumbnail (extra bytes) is removed.
        const jfif = new Uint8Array(18);
        jfif.set([0xff, 0xe0, 0x00, 0x10]);
        jfif.set(data.subarray(0, 12), 4); // "JFIF\0", version, units, densities
        kept.push(jfif); // thumbnail size bytes 12..13 stay 0
      }
    } else if (m === 0xe1) {
      if (ascii(data, 0, 6) === 'Exif\0\0') orientation = Math.max(orientation, readTiffOrientation(data.subarray(6)));
      // EXIF, XMP and every other APP1: dropped
    } else if (m === 0xe2) {
      if (ascii(data, 0, 12) === 'ICC_PROFILE\0') kept.push(whole);
    } else if (m === 0xee) {
      if (ascii(data, 0, 5) === 'Adobe') kept.push(whole);
    } else if ((m >= 0xe3 && m <= 0xef) || m === 0xfe) {
      // APP3..APP15 (IPTC, Photoshop, ...) and comments: dropped
    } else if (m >= 0xc0 && m <= 0xcf && m !== 0xc4 && m !== 0xc8 && m !== 0xcc) {
      if (len < 10) throw new ImageError('bad JPEG frame header');
      height = u16be(data, 1);
      width = u16be(data, 3);
      sawSof = true;
      kept.push(whole);
    } else if (m === 0xda) {
      kept.push(whole);
      sawSos = true;
      // Entropy-coded scan data runs until the next marker that is not a stuffed byte / restart.
      let j = pos;
      for (;;) {
        if (j + 1 >= b.length) throw new ImageError('truncated JPEG scan');
        if (b[j] === 0xff) {
          const n = b[j + 1]!;
          if (n === 0x00 || (n >= 0xd0 && n <= 0xd7)) {
            j += 2;
            continue;
          }
          if (n === 0xff) {
            j += 1;
            continue;
          }
          break;
        }
        j += 1;
      }
      kept.push(b.slice(pos, j));
      pos = j;
    } else if (m === 0xdb || m === 0xc4 || m === 0xcc || m === 0xdd || m === 0xdc) {
      kept.push(whole); // DQT, DHT, DAC, DRI, DNL: the tables a decoder needs
    }
    // Anything else (reserved / extension markers, JPGn, ...) is dropped: only known structure is kept.
  }
  if (!ended || !sawSof || !sawSos) throw new ImageError('incomplete JPEG');

  const parts: Uint8Array[] = [Uint8Array.from([0xff, 0xd8])];
  const exif =
    orientation > 1
      ? (() => {
          const tiff = minimalTiff(orientation);
          const seg = new Uint8Array(4 + 6 + tiff.length);
          seg.set([0xff, 0xe1, 0x00, 2 + 6 + tiff.length]);
          seg.set([0x45, 0x78, 0x69, 0x66, 0x00, 0x00], 4); // "Exif\0\0"
          seg.set(tiff, 10);
          return seg;
        })()
      : null;
  kept.forEach((seg, i) => {
    parts.push(seg);
    if (exif && i === 0 && firstIsJfif) parts.push(exif);
  });
  if (exif && !firstIsJfif) parts.splice(1, 0, exif);
  parts.push(Uint8Array.from([0xff, 0xd9]));
  return { bytes: concat(parts), width, height };
}

// ---- PNG ------------------------------------------------------------------------------------

/** Chunks a decoder needs; everything else (text, time, EXIF, APNG frames, ...) is dropped. */
const PNG_KEEP = new Set(['IHDR', 'PLTE', 'IDAT', 'IEND', 'tRNS', 'gAMA', 'cHRM', 'sRGB', 'iCCP', 'sBIT', 'bKGD']);

function sanitizePng(b: Uint8Array): Omit<SanitizedImage, 'ext'> {
  let pos = 8;
  const kept: Uint8Array[] = [b.slice(0, 8)];
  let width = 0;
  let height = 0;
  let first = true;
  let sawIdat = false;
  let ended = false;
  let segments = 0;
  while (pos < b.length && !ended) {
    if (++segments > MAX_SEGMENTS) throw new ImageError('too many PNG chunks');
    if (pos + 12 > b.length) throw new ImageError('truncated PNG');
    const len = u32be(b, pos);
    if (len > 0x7fffffff || pos + 12 + len > b.length) throw new ImageError('bad PNG chunk length');
    const type = ascii(b, pos + 4, 4);
    if (first) {
      if (type !== 'IHDR' || len !== 13) throw new ImageError('PNG must start with IHDR');
      width = u32be(b, pos + 8);
      height = u32be(b, pos + 12);
      first = false;
    }
    if (type === 'IDAT') sawIdat = true;
    if (PNG_KEEP.has(type)) kept.push(b.slice(pos, pos + 12 + len));
    if (type === 'IEND') ended = true;
    pos += 12 + len;
  }
  if (first || !sawIdat || !ended) throw new ImageError('incomplete PNG');
  return { bytes: concat(kept), width, height };
}

// ---- WebP -----------------------------------------------------------------------------------

const WEBP_KEEP = new Set(['VP8 ', 'VP8L', 'VP8X', 'ALPH', 'ANIM', 'ANMF', 'ICCP']);

function sanitizeWebp(b: Uint8Array): Omit<SanitizedImage, 'ext'> {
  if (b.length < 20) throw new ImageError('truncated WebP');
  const riffEnd = 8 + u32le(b, 4);
  if (riffEnd > b.length || riffEnd < 20) throw new ImageError('bad WebP size');
  const chunks: { type: string; payload: Uint8Array }[] = [];
  let orientation = 1;
  let pos = 12;
  let segments = 0;
  while (pos + 8 <= riffEnd) {
    if (++segments > MAX_SEGMENTS) throw new ImageError('too many WebP chunks');
    const type = ascii(b, pos, 4);
    const size = u32le(b, pos + 4);
    if (pos + 8 + size > riffEnd) throw new ImageError('bad WebP chunk size');
    const payload = b.subarray(pos + 8, pos + 8 + size);
    if (type === 'ANIM' || type === 'ANMF' || (type === 'VP8X' && ((payload[0] ?? 0) & 2) !== 0)) throw new ImageError('animated WebP is not supported');
    if (type === 'EXIF') {
      const tiff = ascii(payload, 0, 6) === 'Exif\0\0' ? payload.subarray(6) : payload;
      orientation = Math.max(orientation, readTiffOrientation(tiff));
    } else if (WEBP_KEEP.has(type)) {
      chunks.push({ type, payload: payload.slice() });
    }
    pos += 8 + size + (size & 1);
  }

  let width = 0;
  let height = 0;
  for (const c of chunks) {
    const p = c.payload;
    if (c.type === 'VP8X' && p.length >= 10) {
      width = 1 + (p[4]! | (p[5]! << 8) | (p[6]! << 16));
      height = 1 + (p[7]! | (p[8]! << 8) | (p[9]! << 16));
      break;
    }
    if (c.type === 'VP8 ' && p.length >= 10 && p[3] === 0x9d && p[4] === 0x01 && p[5] === 0x2a) {
      width = (p[6]! | (p[7]! << 8)) & 0x3fff;
      height = (p[8]! | (p[9]! << 8)) & 0x3fff;
    } else if (c.type === 'VP8L' && p.length >= 5 && p[0] === 0x2f) {
      const bits = (p[1]! | (p[2]! << 8) | (p[3]! << 16) | (p[4]! << 24)) >>> 0;
      width = (bits & 0x3fff) + 1;
      height = ((bits >>> 14) & 0x3fff) + 1;
    }
  }
  if (!chunks.some((c) => c.type === 'VP8 ' || c.type === 'VP8L' || c.type === 'ANMF')) {
    throw new ImageError('WebP has no image data');
  }

  const out: { type: string; payload: Uint8Array }[] = [];
  const vp8x = chunks.find((c) => c.type === 'VP8X');
  for (const c of chunks) {
    if (c.type === 'VP8X') {
      const p = c.payload.slice();
      p[0] = (p[0]! & ~0x0c) | (orientation > 1 ? 0x08 : 0); // clear EXIF + XMP flags; EXIF only if we keep orientation
      out.push({ type: 'VP8X', payload: p });
    } else {
      out.push(c);
    }
  }
  if (orientation > 1) {
    if (!vp8x) {
      // A simple-format file cannot carry EXIF: rebuild it as an extended one so the orientation survives.
      const p = new Uint8Array(10);
      p[0] = 0x08;
      const w = width - 1;
      const h = height - 1;
      p.set([w & 0xff, (w >> 8) & 0xff, (w >> 16) & 0xff, h & 0xff, (h >> 8) & 0xff, (h >> 16) & 0xff], 4);
      out.unshift({ type: 'VP8X', payload: p });
    }
    out.push({ type: 'EXIF', payload: minimalTiff(orientation) });
  }

  let size = 4;
  for (const c of out) size += 8 + c.payload.length + (c.payload.length & 1);
  const bytes = new Uint8Array(8 + size);
  bytes.set([0x52, 0x49, 0x46, 0x46], 0);
  new DataView(bytes.buffer).setUint32(4, size, true);
  bytes.set([0x57, 0x45, 0x42, 0x50], 8);
  let at = 12;
  for (const c of out) {
    for (let i = 0; i < 4; i++) bytes[at + i] = c.type.charCodeAt(i);
    new DataView(bytes.buffer).setUint32(at + 4, c.payload.length, true);
    bytes.set(c.payload, at + 8);
    at += 8 + c.payload.length + (c.payload.length & 1);
  }
  return { bytes, width, height };
}
