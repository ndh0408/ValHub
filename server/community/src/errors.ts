export type ErrorCode =
  | 'unauthorized'
  | 'forbidden'
  | 'not_found'
  | 'invalid_input'
  | 'rate_limited'
  | 'riot_rejected'
  | 'server_error';

const STATUS: Record<ErrorCode, number> = {
  unauthorized: 401,
  forbidden: 403,
  not_found: 404,
  invalid_input: 400,
  rate_limited: 429,
  riot_rejected: 401,
  server_error: 500,
};

/** An error that maps 1:1 to the API error format. */
export class ApiError extends Error {
  readonly status: number;
  constructor(
    readonly code: ErrorCode,
    message: string,
    readonly retryAfter?: number,
  ) {
    super(message);
    this.name = 'ApiError';
    this.status = STATUS[code];
  }
}

export function errorBody(err: ApiError): Record<string, unknown> {
  const error: Record<string, unknown> = { code: err.code, message: err.message };
  if (err.retryAfter !== undefined) error.retryAfter = err.retryAfter;
  return { error };
}

export const invalid = (message: string) => new ApiError('invalid_input', message);
export const notFound = (message = 'Không tìm thấy.') => new ApiError('not_found', message);
export const forbidden = (message = 'Bạn không có quyền thực hiện thao tác này.') =>
  new ApiError('forbidden', message);
export const unauthorized = (message = 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.') =>
  new ApiError('unauthorized', message);
