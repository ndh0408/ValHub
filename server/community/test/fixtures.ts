import zlib from 'node:zlib';

/** Marker strings planted in metadata; tests assert they never survive sanitising. */
export const SECRETS = ['SecretCamera', 'GPSLatitude', 'Photoshop', 'xmpmeta', 'SecretComment', 'SecretText'];

const enc = (s: string) => new TextEncoder().encode(s);
const concat = (...parts: Uint8Array[]): Uint8Array => {
  const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
  let at = 0;
  for (const p of parts) {
    out.set(p, at);
    at += p.length;
  }
  return out;
};
const u16be = (n: number) => Uint8Array.from([(n >> 8) & 0xff, n & 0xff]);
const u32be = (n: number) => Uint8Array.from([(n >>> 24) & 0xff, (n >>> 16) & 0xff, (n >>> 8) & 0xff, n & 0xff]);
const u16le = (n: number) => Uint8Array.from([n & 0xff, (n >> 8) & 0xff]);
const u32le = (n: number) => Uint8Array.from([n & 0xff, (n >>> 8) & 0xff, (n >>> 16) & 0xff, (n >>> 24) & 0xff]);

/** Little-endian TIFF with Make, Orientation and a GPS IFD (all "secret" data). */
export function exifTiff(opts: { orientation?: number; make?: string; gps?: boolean } = {}): Uint8Array {
  const make = enc(`${opts.make ?? 'SecretCamera'}\0`);
  const entries: { tag: number; type: number; count: number; value: Uint8Array }[] = [];
  // Layout: header(8) + IFD0(2 + n*12 + 4) + data. Offsets are computed after we know n.
  const n = 1 + (opts.orientation ? 1 : 0) + (opts.gps ? 1 : 0);
  const ifd0Size = 2 + n * 12 + 4;
  const dataStart = 8 + ifd0Size;
  entries.push({ tag: 0x010f, type: 2, count: make.length, value: u32le(dataStart) });
  if (opts.orientation) entries.push({ tag: 0x0112, type: 3, count: 1, value: concat(u16le(opts.orientation), u16le(0)) });
  const gpsOffset = dataStart + make.length + (make.length & 1);
  if (opts.gps) entries.push({ tag: 0x8825, type: 4, count: 1, value: u32le(gpsOffset) });
  entries.sort((a, b) => a.tag - b.tag);
  const ifd0 = concat(
    u16le(entries.length),
    ...entries.map((e) => concat(u16le(e.tag), u16le(e.type), u32le(e.count), e.value)),
    u32le(0),
  );
  const parts = [enc('II'), u16le(42), u32le(8), ifd0, make, make.length & 1 ? Uint8Array.of(0) : new Uint8Array(0)];
  if (opts.gps) {
    const label = enc('GPSLatitude\0');
    // GPS IFD with one ASCII entry (tag 1, "GPSLatitudeRef"-like) pointing at a label.
    parts.push(
      u16le(1),
      concat(u16le(1), u16le(2), u32le(label.length), u32le(gpsOffset + 2 + 12 + 4)),
      u32le(0),
      label,
    );
  }
  return concat(...parts);
}

export interface JpegOpts {
  width?: number;
  height?: number;
  jfif?: boolean;
  exif?: { orientation?: number; gps?: boolean } | false;
  xmp?: boolean;
  iptc?: boolean;
  comment?: boolean;
  icc?: boolean;
  trailing?: Uint8Array;
  exifFirst?: boolean;
}

/** A structurally valid JPEG (not decodable pixels, but every marker the sanitiser walks). */
export function makeJpeg(o: JpegOpts = {}): Uint8Array {
  const seg = (m: number, data: Uint8Array) => concat(Uint8Array.of(0xff, m), u16be(data.length + 2), data);
  const jfif = seg(0xe0, concat(enc('JFIF\0'), Uint8Array.of(1, 1, 0, 0, 1, 0, 1, 0, 0)));
  const exif =
    o.exif === false
      ? null
      : seg(0xe1, concat(enc('Exif\0\0'), exifTiff({ ...(o.exif ?? { gps: true }), make: 'SecretCamera' })));
  const parts: Uint8Array[] = [Uint8Array.of(0xff, 0xd8)];
  if (o.exifFirst && exif) parts.push(exif);
  if (o.jfif !== false) parts.push(jfif);
  if (!o.exifFirst && exif) parts.push(exif);
  if (o.xmp !== false) parts.push(seg(0xe1, concat(enc('http://ns.adobe.com/xap/1.0/\0'), enc('<x:xmpmeta>SecretText</x:xmpmeta>'))));
  if (o.iptc !== false) parts.push(seg(0xed, concat(enc('Photoshop 3.0\0'), enc('8BIM SecretText'))));
  if (o.comment !== false) parts.push(seg(0xfe, enc('SecretComment')));
  if (o.icc) parts.push(seg(0xe2, concat(enc('ICC_PROFILE\0'), Uint8Array.of(1, 1), new Uint8Array(20).fill(7))));
  parts.push(seg(0xdb, concat(Uint8Array.of(0), new Uint8Array(64).fill(3)))); // DQT
  parts.push(
    seg(0xc0, concat(Uint8Array.of(8), u16be(o.height ?? 2), u16be(o.width ?? 2), Uint8Array.of(1, 1, 0x11, 0))), // SOF0
  );
  parts.push(seg(0xc4, concat(Uint8Array.of(0), new Uint8Array(16), Uint8Array.of(0)))); // DHT
  parts.push(seg(0xda, Uint8Array.of(1, 1, 0, 0, 63, 0))); // SOS header
  // Entropy-coded data incl. a stuffed 0xFF00 and a restart marker.
  parts.push(Uint8Array.of(0x12, 0x34, 0xff, 0x00, 0x56, 0xff, 0xd0, 0x78, 0x9a));
  parts.push(Uint8Array.of(0xff, 0xd9));
  if (o.trailing) parts.push(o.trailing);
  return concat(...parts);
}

const crc32 = (b: Uint8Array): number => zlib.crc32(b) >>> 0;

function pngChunk(type: string, data: Uint8Array): Uint8Array {
  const t = enc(type);
  return concat(u32be(data.length), t, data, u32be(crc32(concat(t, data))));
}

export interface PngOpts {
  width?: number;
  height?: number;
  text?: boolean;
  exif?: boolean;
  time?: boolean;
  trailing?: Uint8Array;
  /** Fake dimensions written in IHDR (pixel data stays 1x1): for the "too many pixels" test. */
  ihdrWidth?: number;
  ihdrHeight?: number;
}

export const PNG_IDAT_RAW = Uint8Array.of(0, 10, 20, 30, 255); // filter 0 + one RGBA pixel

export function makePng(o: PngOpts = {}): Uint8Array {
  const ihdr = concat(u32be(o.ihdrWidth ?? o.width ?? 1), u32be(o.ihdrHeight ?? o.height ?? 1), Uint8Array.of(8, 6, 0, 0, 0));
  const parts: Uint8Array[] = [Uint8Array.of(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a), pngChunk('IHDR', ihdr)];
  parts.push(pngChunk('gAMA', u32be(45455)));
  if (o.text !== false) parts.push(pngChunk('tEXt', enc('Comment\0SecretText')));
  if (o.exif !== false) parts.push(pngChunk('eXIf', exifTiff({ orientation: 6, gps: true })));
  if (o.time !== false) parts.push(pngChunk('tIME', Uint8Array.of(0x07, 0xe9, 5, 4, 3, 2, 1)));
  parts.push(pngChunk('IDAT', zlib.deflateSync(PNG_IDAT_RAW)));
  parts.push(pngChunk('IEND', new Uint8Array(0)));
  if (o.trailing) parts.push(o.trailing);
  return concat(...parts);
}

export interface WebpOpts {
  width?: number;
  height?: number;
  exif?: { orientation?: number } | false;
  xmp?: boolean;
  extended?: boolean;
  trailing?: Uint8Array;
}

function riffChunk(type: string, payload: Uint8Array): Uint8Array {
  return concat(enc(type), u32le(payload.length), payload, payload.length & 1 ? Uint8Array.of(0) : new Uint8Array(0));
}

/** Lossless WebP (VP8L) in an extended (VP8X) container with EXIF / XMP chunks. */
export function makeWebp(o: WebpOpts = {}): Uint8Array {
  const w = o.width ?? 2;
  const h = o.height ?? 2;
  const extended = o.extended !== false;
  const hasExif = extended && o.exif !== false;
  const hasXmp = extended && o.xmp !== false;
  const chunks: Uint8Array[] = [];
  if (extended) {
    const flags = 0x10 | (hasExif ? 0x08 : 0) | (hasXmp ? 0x04 : 0);
    const dim = (n: number) => Uint8Array.of((n - 1) & 0xff, ((n - 1) >> 8) & 0xff, ((n - 1) >> 16) & 0xff);
    chunks.push(riffChunk('VP8X', concat(Uint8Array.of(flags, 0, 0, 0), dim(w), dim(h))));
  }
  const bits = ((w - 1) & 0x3fff) | (((h - 1) & 0x3fff) << 14);
  chunks.push(riffChunk('VP8L', concat(Uint8Array.of(0x2f), u32le(bits >>> 0), new Uint8Array(9).fill(5))));
  if (hasExif) {
    chunks.push(riffChunk('EXIF', exifTiff(o.exif && typeof o.exif === 'object' ? { ...o.exif, gps: true } : { gps: true })));
  }
  if (hasXmp) chunks.push(riffChunk('XMP ', enc('<x:xmpmeta>SecretText</x:xmpmeta>')));
  const body = concat(enc('WEBP'), ...chunks);
  return concat(enc('RIFF'), u32le(body.length), body, o.trailing ?? new Uint8Array(0));
}

/** True when `haystack` contains the ASCII `needle`. */
export function containsText(haystack: Uint8Array, needle: string): boolean {
  return Buffer.from(haystack).includes(Buffer.from(needle, 'latin1'));
}

export function containsAnySecret(bytes: Uint8Array): string | null {
  return SECRETS.find((s) => containsText(bytes, s)) ?? null;
}
