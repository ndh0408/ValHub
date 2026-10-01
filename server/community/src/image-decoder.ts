import sharp from 'sharp';
import { ApiError } from './errors.js';
import { ImageError, MAX_PIXELS, MAX_SIDE, type SanitizedImage } from './imaging.js';
import { MAX_MEDIA_BYTES, sniffImage } from './media.js';

// Pixel work runs in libuv's native worker pool. Bound both active work and
// queued input buffers; never create an unlimited Promise queue on uploads.
sharp.concurrency(1);
sharp.cache({ memory: 32, files: 0, items: 64 });
let active = 0;
const waiting: (() => void)[] = [];

async function acquire(): Promise<void> {
  if (active < 2) { active++; return; }
  if (waiting.length >= 8) throw new ApiError('server_busy', 'Máy chủ đang xử lý nhiều ảnh. Hãy thử lại.', 2);
  await new Promise<void>((resolve) => waiting.push(resolve));
}

function release(): void {
  const next = waiting.shift();
  if (next) next(); else active--;
}

/** Fully decode pixels, apply orientation, then encode fresh static pixels.
 * Sharp strips metadata by default; do not call keepMetadata/withMetadata.
 * Structural sanitising alone cannot validate compressed image data.
 */
export async function decodeImage(input: Uint8Array): Promise<SanitizedImage> {
  const ext = sniffImage(input);
  if (ext === null || input.length > MAX_MEDIA_BYTES) throw new ImageError('invalid input');
  await acquire();
  try {
    const image = sharp(input, {
      limitInputPixels: MAX_PIXELS, failOn: 'warning', sequentialRead: true,
    }).timeout({ seconds: 5 });
    const metadata = await image.metadata();
    if (!metadata.width || !metadata.height ||
        metadata.width > MAX_SIDE || metadata.height > MAX_SIDE ||
        metadata.width * metadata.height > MAX_PIXELS ||
        (metadata.pages ?? 1) !== 1) throw new ImageError('invalid dimensions or animation');
    const pipeline = image.autoOrient().toColourspace('srgb');
    const encoded = ext === 'jpg' ? pipeline.jpeg({ quality: 85 }) :
      ext === 'png' ? pipeline.png({ compressionLevel: 6 }) : pipeline.webp({ quality: 85 });
    const { data, info } = await encoded.toBuffer({ resolveWithObject: true });
    if (data.length > MAX_MEDIA_BYTES) throw new ImageError('decoded output exceeds upload limit');
    return { bytes: data, ext, width: info.width, height: info.height };
  } catch (error) {
    if (error instanceof ImageError) throw error;
    // Decoder messages can contain user data; expose only a stable error type.
    throw new ImageError('image cannot be decoded');
  } finally {
    release();
  }
}
