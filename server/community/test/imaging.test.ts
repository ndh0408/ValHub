import zlib from 'node:zlib';
import { describe, expect, it } from 'vitest';
import { ImageError, MAX_PIXELS, minimalTiff, readTiffOrientation, sanitizeImage } from '../src/imaging.js';
import { containsAnySecret, containsText, exifTiff, makeJpeg, makePng, makeWebp, PNG_IDAT_RAW, SECRETS } from './fixtures.js';

const u32be = (b: Uint8Array, at: number) => ((b[at]! << 24) | (b[at + 1]! << 16) | (b[at + 2]! << 8) | b[at + 3]!) >>> 0;

/** JPEG marker sequence (marker bytes only, outside scan data). */
function jpegMarkers(b: Uint8Array): number[] {
  const out: number[] = [];
  let pos = 2;
  while (pos < b.length) {
    while (b[pos] === 0xff) pos++;
    const m = b[pos++]!;
    out.push(m);
    if (m === 0xd9) break;
    const len = (b[pos]! << 8) | b[pos + 1]!;
    pos += len;
    if (m === 0xda) {
      while (!(b[pos] === 0xff && b[pos + 1] !== 0 && !(b[pos + 1]! >= 0xd0 && b[pos + 1]! <= 0xd7))) pos++;
    }
  }
  return out;
}

function pngChunks(b: Uint8Array): { type: string; len: number; crcOk: boolean; data: Uint8Array }[] {
  const out = [];
  let pos = 8;
  while (pos < b.length) {
    const len = u32be(b, pos);
    const type = String.fromCharCode(...b.subarray(pos + 4, pos + 8));
    const crc = u32be(b, pos + 8 + len);
    out.push({ type, len, crcOk: zlib.crc32(b.subarray(pos + 4, pos + 8 + len)) >>> 0 === crc, data: b.subarray(pos + 8, pos + 8 + len) });
    pos += 12 + len;
  }
  return out;
}

function webpChunks(b: Uint8Array): { type: string; payload: Uint8Array }[] {
  const out = [];
  let pos = 12;
  while (pos + 8 <= b.length) {
    const type = String.fromCharCode(...b.subarray(pos, pos + 4));
    const size = (b[pos + 4]! | (b[pos + 5]! << 8) | (b[pos + 6]! << 16) | (b[pos + 7]! << 24)) >>> 0;
    out.push({ type, payload: b.subarray(pos + 8, pos + 8 + size) });
    pos += 8 + size + (size & 1);
  }
  return out;
}

describe('JPEG', () => {
  it('drops EXIF (with GPS), XMP, IPTC and comments, and keeps everything a decoder needs', () => {
    const input = makeJpeg({ exif: { orientation: 1, gps: true } });
    expect(containsAnySecret(input)).not.toBeNull();
    const r = sanitizeImage(input);
    expect(r.ext).toBe('jpg');
    expect(containsAnySecret(r.bytes)).toBeNull();
    expect(jpegMarkers(r.bytes)).toEqual([0xe0, 0xdb, 0xc0, 0xc4, 0xda, 0xd9]); // JFIF, DQT, SOF0, DHT, SOS, EOI
    expect(r.width).toBe(2);
    expect(r.height).toBe(2);
    // Scan data (with a stuffed 0xFF00 and a restart marker) is passed through byte for byte.
    expect(containsText(r.bytes, '\x12\x34\xff\x00\x56\xff\xd0\x78\x9a')).toBe(true);
  });

  it('keeps ICC profiles and Adobe markers, drops everything else in APPn', () => {
    const r = sanitizeImage(makeJpeg({ icc: true }));
    expect(jpegMarkers(r.bytes)).toContain(0xe2);
    expect(containsText(r.bytes, 'ICC_PROFILE')).toBe(true);
    expect(jpegMarkers(r.bytes)).not.toContain(0xed);
    expect(jpegMarkers(r.bytes)).not.toContain(0xfe);
  });

  it.each([2, 3, 6, 8])('keeps only the orientation (%i) as a minimal EXIF block so photos are not sideways', (o) => {
    const r = sanitizeImage(makeJpeg({ exif: { orientation: o, gps: true } }));
    expect(containsAnySecret(r.bytes)).toBeNull();
    const markers = jpegMarkers(r.bytes);
    expect(markers.slice(0, 2)).toEqual([0xe0, 0xe1]); // right after JFIF
    const at = Buffer.from(r.bytes).indexOf(Buffer.from('Exif\0\0', 'latin1'));
    const app1Len = (r.bytes[at - 2]! << 8) | r.bytes[at - 1]!;
    expect(app1Len).toBe(34);
    expect(readTiffOrientation(r.bytes.subarray(at + 6, at + 6 + 26))).toBe(o);
    expect(Buffer.from(r.bytes).includes(Buffer.from('SecretCamera'))).toBe(false);
  });

  it('puts the orientation right after SOI when the file has no JFIF', () => {
    const r = sanitizeImage(makeJpeg({ jfif: false, exif: { orientation: 6 } }));
    expect(jpegMarkers(r.bytes)[0]).toBe(0xe1);
  });

  it('writes no EXIF at all for orientation 1 / none', () => {
    expect(jpegMarkers(sanitizeImage(makeJpeg({ exif: { orientation: 1 } })).bytes)).not.toContain(0xe1);
    expect(jpegMarkers(sanitizeImage(makeJpeg({ exif: { gps: true } })).bytes)).not.toContain(0xe1);
  });

  it('drops data appended after EOI (polyglots, hidden payloads)', () => {
    const trailing = new TextEncoder().encode('<script>alert(1)</script>PK\x03\x04SecretText');
    const r = sanitizeImage(makeJpeg({ trailing }));
    expect(containsText(r.bytes, 'script')).toBe(false);
    expect(r.bytes.at(-2)).toBe(0xff);
    expect(r.bytes.at(-1)).toBe(0xd9);
  });

  it('is idempotent and byte-identical for a clean file', () => {
    const clean = makeJpeg({ exif: false, xmp: false, iptc: false, comment: false });
    expect(Buffer.from(sanitizeImage(clean).bytes).equals(Buffer.from(clean))).toBe(true);
    const once = sanitizeImage(makeJpeg({ exif: { orientation: 6, gps: true } })).bytes;
    expect(Buffer.from(sanitizeImage(once).bytes).equals(Buffer.from(once))).toBe(true);
  });

  it.each([
    ['truncated inside a segment', (b: Uint8Array) => b.subarray(0, 40)],
    ['no EOI', (b: Uint8Array) => b.subarray(0, b.length - 2)],
    ['scan cut off', (b: Uint8Array) => b.subarray(0, b.length - 9)],
    ['garbage marker', (b: Uint8Array) => Uint8Array.from([...b.subarray(0, 2), 0x12, 0x34, ...b.subarray(2)])],
    ['zero-length segment', (b: Uint8Array) => Uint8Array.from([...b.subarray(0, 2), 0xff, 0xdb, 0, 0, ...b.subarray(2)])],
    ['segment longer than the file', (b: Uint8Array) => Uint8Array.from([...b.subarray(0, 2), 0xff, 0xdb, 0xff, 0xff, ...b.subarray(2)])],
  ])('rejects a malformed file: %s', (_name, mutate) => {
    expect(() => sanitizeImage(mutate(makeJpeg()))).toThrowError(ImageError);
  });

  it('rejects a JPEG without frame or scan', () => {
    const noScan = Uint8Array.from([0xff, 0xd8, 0xff, 0xd9]);
    expect(() => sanitizeImage(noScan)).toThrowError(ImageError);
  });

  it('rejects absurd dimensions', () => {
    expect(() => sanitizeImage(makeJpeg({ width: 20000, height: 20000 }))).toThrowError(ImageError);
    expect(() => sanitizeImage(makeJpeg({ width: 0, height: 5 }))).toThrowError(ImageError);
    expect(sanitizeImage(makeJpeg({ width: 7000, height: 7000 })).width).toBe(7000); // 49 MP < limit
    expect(() => sanitizeImage(makeJpeg({ width: 8000, height: 8000 }))).toThrowError(ImageError); // 64 MP
    expect(MAX_PIXELS).toBe(50_000_000);
  });
});

describe('PNG', () => {
  it('drops text, EXIF and time chunks and keeps the rest with valid CRCs', () => {
    const input = makePng();
    expect(containsAnySecret(input)).not.toBeNull();
    const r = sanitizeImage(input);
    expect(r.ext).toBe('png');
    expect(containsAnySecret(r.bytes)).toBeNull();
    const chunks = pngChunks(r.bytes);
    expect(chunks.map((c) => c.type)).toEqual(['IHDR', 'gAMA', 'IDAT', 'IEND']);
    expect(chunks.every((c) => c.crcOk)).toBe(true);
    expect(Buffer.from(zlib.inflateSync(chunks[2]!.data)).equals(Buffer.from(PNG_IDAT_RAW))).toBe(true);
    expect([r.width, r.height]).toEqual([1, 1]);
  });

  it('drops data after IEND and is idempotent', () => {
    const r = sanitizeImage(makePng({ trailing: new TextEncoder().encode('<html>SecretText</html>') }));
    expect(containsText(r.bytes, 'html')).toBe(false);
    expect(Buffer.from(sanitizeImage(r.bytes).bytes).equals(Buffer.from(r.bytes))).toBe(true);
  });

  it('rejects oversized / malformed files', () => {
    expect(() => sanitizeImage(makePng({ ihdrWidth: 20000, ihdrHeight: 20000 }))).toThrowError(ImageError);
    expect(() => sanitizeImage(makePng({ ihdrWidth: 0, ihdrHeight: 1 }))).toThrowError(ImageError);
    const ok = makePng();
    expect(() => sanitizeImage(ok.subarray(0, ok.length - 12))).toThrowError(ImageError); // no IEND
    expect(() => sanitizeImage(ok.subarray(0, 30))).toThrowError(ImageError);
    const notIhdrFirst = Uint8Array.from([...ok.subarray(0, 8), ...ok.subarray(8 + 25)]);
    expect(() => sanitizeImage(notIhdrFirst)).toThrowError(ImageError);
  });
});

describe('WebP', () => {
  it('drops EXIF and XMP, clears their flags and rebuilds a consistent RIFF', () => {
    const input = makeWebp();
    expect(containsAnySecret(input)).not.toBeNull();
    const r = sanitizeImage(input);
    expect(r.ext).toBe('webp');
    expect(containsAnySecret(r.bytes)).toBeNull();
    const chunks = webpChunks(r.bytes);
    expect(chunks.map((c) => c.type)).toEqual(['VP8X', 'VP8L']);
    expect(chunks[0]!.payload[0]! & 0x0c).toBe(0); // EXIF + XMP flags cleared
    expect(chunks[0]!.payload[0]! & 0x10).toBe(0x10); // alpha flag kept
    const riffSize = r.bytes[4]! | (r.bytes[5]! << 8) | (r.bytes[6]! << 16) | (r.bytes[7]! << 24);
    expect(riffSize).toBe(r.bytes.length - 8);
    expect([r.width, r.height]).toEqual([2, 2]);
  });

  it('keeps only the orientation as a minimal EXIF chunk', () => {
    const r = sanitizeImage(makeWebp({ exif: { orientation: 6 } }));
    expect(containsAnySecret(r.bytes)).toBeNull();
    const chunks = webpChunks(r.bytes);
    expect(chunks.map((c) => c.type)).toEqual(['VP8X', 'VP8L', 'EXIF']);
    expect(chunks[0]!.payload[0]! & 0x08).toBe(0x08);
    expect(readTiffOrientation(chunks[2]!.payload)).toBe(6);
    expect(chunks[2]!.payload.length).toBe(26);
  });

  it('drops trailing data and is idempotent', () => {
    const r = sanitizeImage(makeWebp({ trailing: new TextEncoder().encode('SecretText<script>') }));
    expect(containsText(r.bytes, 'script')).toBe(false);
    expect(Buffer.from(sanitizeImage(r.bytes).bytes).equals(Buffer.from(r.bytes))).toBe(true);
  });

  it('leaves a simple (VP8L only) file untouched', () => {
    const simple = makeWebp({ extended: false });
    expect(Buffer.from(sanitizeImage(simple).bytes).equals(Buffer.from(simple))).toBe(true);
  });

  it('rejects malformed / oversized files', () => {
    const ok = makeWebp();
    expect(() => sanitizeImage(ok.subarray(0, ok.length - 5))).toThrowError(ImageError);
    expect(() => sanitizeImage(makeWebp({ width: 20000, height: 20000 }))).toThrowError(ImageError);
    expect(() => sanitizeImage(Uint8Array.from([...ok.subarray(0, 4), 8, 0, 0, 0, ...ok.subarray(8, 20)]))).toThrowError(ImageError);
  });
});

describe('EXIF helpers', () => {
  it('reads orientation from little- and big-endian TIFF and rejects junk', () => {
    expect(readTiffOrientation(exifTiff({ orientation: 8, gps: true }))).toBe(8);
    expect(readTiffOrientation(minimalTiff(3))).toBe(3);
    expect(readTiffOrientation(exifTiff({ gps: true }))).toBe(1);
    for (const junk of [new Uint8Array(0), Uint8Array.of(1, 2, 3), new Uint8Array(40).fill(0xff), Uint8Array.from([0x49, 0x49, 42, 0, 0xff, 0xff, 0xff, 0xff])]) {
      expect(readTiffOrientation(junk)).toBe(1);
    }
  });
});

describe('robustness', () => {
  it('rejects non-images and unsupported types', () => {
    for (const bad of [new Uint8Array(0), new TextEncoder().encode('<svg xmlns="http://www.w3.org/2000/svg"/>'), Uint8Array.of(0x47, 0x49, 0x46, 0x38)]) {
      expect(() => sanitizeImage(bad)).toThrowError(ImageError);
    }
  });

  it('never throws anything but ImageError and never leaks metadata, whatever the input', () => {
    // Deterministic pseudo-random mutations of valid files (bit flips, truncation, insertion).
    let seed = 1234567;
    const rnd = (n: number) => {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed % n;
    };
    const bases = [makeJpeg({ icc: true, exif: { orientation: 6, gps: true } }), makePng(), makeWebp({ exif: { orientation: 3 } })];
    let accepted = 0;
    for (let i = 0; i < 1500; i++) {
      const base = bases[i % bases.length]!;
      const b = Uint8Array.from(base);
      for (let k = 0; k < 1 + rnd(4); k++) b[rnd(b.length)] = rnd(256);
      const cut = rnd(3) === 0 ? b.subarray(0, 1 + rnd(b.length)) : b;
      let r: ReturnType<typeof sanitizeImage> | null = null;
      try {
        r = sanitizeImage(cut);
      } catch (e) {
        expect(e, `iteration ${i}`).toBeInstanceOf(ImageError);
      }
      if (r) {
        accepted++;
        expect(containsAnySecret(r.bytes), `secrets ${i}`).toBeNull();
        expect(r.width * r.height).toBeLessThanOrEqual(MAX_PIXELS);
        // A second pass changes nothing.
        expect(Buffer.from(sanitizeImage(r.bytes).bytes).equals(Buffer.from(r.bytes)), `idempotent ${i}`).toBe(true);
      }
    }
    expect(accepted).toBeGreaterThan(50); // the mutations are not all fatal, so both paths were exercised
    void SECRETS;
  });
});
