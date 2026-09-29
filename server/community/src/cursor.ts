import { invalid } from './errors.js';

export interface Cursor {
  createdAt: number;
  id: string;
}

/** Opaque cursor: base64url(JSON [createdAt, id]). */
export function encodeCursor(c: Cursor): string {
  return Buffer.from(JSON.stringify([c.createdAt, c.id]), 'utf8').toString('base64url');
}

export function decodeCursor(raw: string | undefined): Cursor | undefined {
  if (raw === undefined || raw === '') return undefined;
  if (raw.length > 200 || !/^[A-Za-z0-9_-]+$/.test(raw)) throw invalid('cursor không hợp lệ.');
  try {
    const v: unknown = JSON.parse(Buffer.from(raw, 'base64url').toString('utf8'));
    if (
      Array.isArray(v) &&
      v.length === 2 &&
      typeof v[0] === 'number' &&
      Number.isSafeInteger(v[0]) &&
      typeof v[1] === 'string' &&
      v[1].length <= 64
    ) {
      return { createdAt: v[0], id: v[1] };
    }
  } catch {
    // fall through
  }
  throw invalid('cursor không hợp lệ.');
}

/** Builds a page from `limit + 1` fetched rows. */
export function page<R extends { created_at: number; id: string }, T>(
  rows: R[],
  limit: number,
  map: (r: R) => T,
): { items: T[]; nextCursor: string | null } {
  const more = rows.length > limit;
  const slice = more ? rows.slice(0, limit) : rows;
  const last = slice[slice.length - 1];
  return {
    items: slice.map(map),
    nextCursor: more && last ? encodeCursor({ createdAt: last.created_at, id: last.id }) : null,
  };
}
