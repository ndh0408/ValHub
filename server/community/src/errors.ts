import { reasonMessages, type Reason, type ReasonParams } from './reasons.js';

export type ErrorCode =
  | 'unauthorized'
  | 'forbidden'
  | 'conflict'
  | 'suspended'
  | 'not_found'
  | 'invalid_input'
  | 'rate_limited'
  | 'riot_rejected'
  | 'riot_unavailable'
  | 'storage_full'
  | 'server_busy'
  | 'server_error';
// A key reused for a different request is a conflict, not a validation failure.

const STATUS: Record<ErrorCode, number> = {
  unauthorized: 401,
  forbidden: 403,
  conflict: 409,
  suspended: 403,
  not_found: 404,
  invalid_input: 400,
  rate_limited: 429,
  riot_rejected: 401,
  riot_unavailable: 503,
  storage_full: 507,
  server_busy: 503,
  server_error: 500,
};

/** Optional machine-readable detail of an error (all additive: old clients read `code` and `message`). */
export interface ErrorExtra {
  /** Stable reason code, see `reasons.ts`. */
  reason?: Reason;
  /** Values for the reason's placeholders (limits, field names, ...); also useful to the client UI. */
  params?: ReasonParams;
  /** English text of `message` (which stays Vietnamese for clients that predate reason codes). */
  messageEn?: string;
}

/** An error that maps 1:1 to the API error format. */
export class ApiError extends Error {
  readonly status: number;
  constructor(
    readonly code: ErrorCode,
    message: string,
    readonly retryAfter?: number,
    readonly extra: ErrorExtra = {},
  ) {
    super(message);
    this.name = 'ApiError';
    this.status = STATUS[code];
    // Legacy throws still get a stable fallback reason and English text. Specific validators supply sub-reasons.
    if (!extra.reason) {
      const fallback = reasonMessages(code, {});
      this.extra = { ...extra, reason: code, messageEn: fallback.messageEn };
    }
  }
}

/** An error with a stable reason code: Vietnamese `message`, English `messageEn`, `reason` and `params`. */
export function reasonError(code: ErrorCode, reason: Reason, params: ReasonParams = {}, retryAfter?: number): ApiError {
  const { message, messageEn } = reasonMessages(reason, params);
  return new ApiError(code, message, retryAfter, { reason, params, messageEn });
}

export function errorBody(err: ApiError): Record<string, unknown> {
  const error: Record<string, unknown> = { code: err.code, message: err.message };
  if (err.extra.messageEn !== undefined) error.messageEn = err.extra.messageEn;
  if (err.extra.reason !== undefined) error.reason = err.extra.reason;
  if (err.extra.params !== undefined && Object.keys(err.extra.params).length > 0) error.params = err.extra.params;
  if (err.retryAfter !== undefined) error.retryAfter = err.retryAfter;
  return { error };
}

export const invalid = (message: string, reason: Reason = 'invalid_input', params: ReasonParams = {}) =>
  new ApiError('invalid_input', message, undefined, { reason, params, messageEn: reasonMessages(reason, params).messageEn });
export const notFound = (message = 'Không tìm thấy.') => new ApiError('not_found', message);
export const forbidden = (message = 'Bạn không có quyền thực hiện thao tác này.') =>
  new ApiError('forbidden', message);
export const unauthorized = (message = 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.') =>
  new ApiError('unauthorized', message);
