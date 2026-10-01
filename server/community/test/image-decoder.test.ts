import sharp from 'sharp';
import { describe, expect, it } from 'vitest';
import { decodeImage } from '../src/image-decoder.js';
import { ImageError } from '../src/imaging.js';
import { makeJpeg, makePng, makeWebp } from './fixtures.js';
import { JPEG, PNG, WEBP } from './helpers.js';

describe('native pixel decoding', () => {
  it.each([makeJpeg(), makeWebp(), makePng({ width: 20, height: 20 })])('refuses plausible headers with invalid compressed pixels', async (input) => {
    await expect(decodeImage(input)).rejects.toBeInstanceOf(ImageError);
  });
  it.each([JPEG, PNG, WEBP])('outputs actual decodable pixels without metadata', async (input) => {
    const result = await decodeImage(input);
    const pixels = await sharp(result.bytes).raw().toBuffer({ resolveWithObject: true });
    expect(pixels.info.width).toBe(2);
    expect(pixels.info.height).toBe(3);
    expect(pixels.data.length).toBeGreaterThanOrEqual(18);
    expect((await sharp(result.bytes).metadata()).exif).toBeUndefined();
  });
  it('applies phone orientation before removing EXIF', async () => {
    const rotated = await sharp(JPEG).withExif({ IFD0: { Make: 'SecretCamera' } }).withMetadata({ orientation: 6 }).jpeg().toBuffer();
    expect((await sharp(rotated).metadata()).orientation).toBe(6);
    const result = await decodeImage(rotated);
    expect(result.width).toBe(3);
    expect(result.height).toBe(2);
    expect((await sharp(result.bytes).metadata()).exif).toBeUndefined();
  });
  it('rejects animated WebP input instead of silently dropping frames', async () => {
    // A libvips-generated two-frame animation exercises the actual decoder.
    const red = await sharp({ create: { width: 2, height: 3, channels: 4, background: '#ff0000' } }).png().toBuffer();
    const blue = await sharp({ create: { width: 2, height: 3, channels: 4, background: '#0000ff' } }).png().toBuffer();
    const animated = await sharp([red, blue], { join: { animated: true } }).webp().toBuffer();
    expect((await sharp(animated).metadata()).pages).toBe(2);
    await expect(decodeImage(animated)).rejects.toBeInstanceOf(ImageError);
  });
});
