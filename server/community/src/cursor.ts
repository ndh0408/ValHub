import { invalid, reasonError } from './errors.js';

export interface Cursor {
  createdAt: number;
  id: string;
  /** Only for orderings by like count (reviews sort=top). */
  likes?: number;
}

/** Opaque cursor: base64url(JSON [createdAt, id] or [createdAt, id, likes]). */
export function encodeCursor(c: Cursor): string {
  const arr: unknown[] = [c.createdAt, c.id];
  if (c.likes !== undefined) arr.push(c.likes);
  return Buffer.from(JSON.stringify(arr), 'utf8').toString('base64url');
}

export function decodeCursor(raw: string | undefined): Cursor | undefined {
  if (raw === undefined || raw === '') return undefined;
  if (raw.length > 200 || !/^[A-Za-z0-9_-]+$/.test(raw)) throw reasonError('invalid_input', 'cursor_invalid');
  try {
    const v: unknown = JSON.parse(Buffer.from(raw, 'base64url').toString('utf8'));
    if (
      Array.isArray(v) &&
      (v.length === 2 || v.length === 3) &&
      typeof v[0] === 'number' &&
      Number.isSafeInteger(v[0]) &&
      typeof v[1] === 'string' &&
      v[1].length <= 64 &&
      (v.length === 2 || (typeof v[2] === 'number' && Number.isSafeInteger(v[2]) && v[2] >= 0))
    ) {
      const c: Cursor = { createdAt: v[0], id: v[1] };
      if (v.length === 3) c.likes = v[2] as number;
      return c;
    }
  } catch {
    // fall through
  }
  throw reasonError('invalid_input', 'cursor_invalid');
}

/** Builds a page from `limit + 1` fetched rows. */
export function page<R extends { created_at: number; id: string }, T>(
  rows: R[],
  limit: number,
  map: (r: R) => T,
  likesOf?: (r: R) => number,
): { items: T[]; nextCursor: string | null } {
  const more = rows.length > limit;
  const slice = more ? rows.slice(0, limit) : rows;
  const last = slice[slice.length - 1];
  return {
    items: slice.map(map),
    nextCursor:
      more && last
        ? encodeCursor({ createdAt: last.created_at, id: last.id, likes: likesOf ? likesOf(last) : undefined })
        : null,
  };
}
