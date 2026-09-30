/**
 * Stable machine-readable reasons for API errors (`error.reason`, with `error.params`), so a client can show a
 * message in the user's language instead of the server's text. Every entry has a Vietnamese text (kept as the
 * `message` for clients that predate reason codes) and an English text (`messageEn`). `{name}` placeholders are
 * filled from `params`. Parameter values are numbers, field names (API identifiers such as `rankTier`) or
 * enumerated codes, never free user text.
 *
 * Adding a reason: add it here, throw it with `reasonError(...)` / `invalid(...)`, and add it to the table in
 * `docs/community-api.md` ("Error reasons"). Never rename or reuse one: clients map them to translations.
 */
export const REASONS = {
  // ---- request shape --------------------------------------------------------------------------------------------
  body_invalid_json: { vi: 'Nội dung yêu cầu không phải JSON hợp lệ.', en: 'The request body is not valid JSON.' },
  body_not_object: { vi: 'Nội dung yêu cầu phải là một đối tượng JSON.', en: 'The request body must be a JSON object.' },
  body_too_large: { vi: 'Nội dung yêu cầu quá lớn.', en: 'The request body is too large.' },
  field_not_uuid: { vi: '{field} phải là UUID.', en: '{field} must be a UUID.' },
  field_not_string: { vi: '{field} phải là chuỗi.', en: '{field} must be a string.' },
  field_bad_chars: { vi: '{field} chứa ký tự không hợp lệ.', en: '{field} contains invalid characters.' },
  field_empty: { vi: '{field} không được để trống.', en: '{field} must not be empty.' },
  field_too_long: { vi: '{field} tối đa {max} ký tự.', en: '{field} must be at most {max} characters.' },
  field_not_in_list: { vi: '{field} phải là một trong: {allowed}.', en: '{field} must be one of: {allowed}.' },
  field_not_int: {
    vi: '{field} phải là số nguyên từ {min} đến {max}.',
    en: '{field} must be an integer from {min} to {max}.',
  },
  field_not_bool: { vi: '{field} phải là true hoặc false.', en: '{field} must be true or false.' },
  field_not_date: { vi: '{field} phải có dạng YYYY-MM-DD.', en: '{field} must look like YYYY-MM-DD.' },
  field_bad_date: { vi: '{field} không phải ngày hợp lệ.', en: '{field} is not a valid date.' },
  array_bad_size: {
    vi: '{field} phải là mảng tối đa {max} phần tử.',
    en: '{field} must be an array of at most {max} items.',
  },
  array_duplicates: { vi: '{field} có phần tử trùng lặp.', en: '{field} contains duplicate items.' },
  limit_out_of_range: {
    vi: 'limit phải là số nguyên từ 1 đến {max}.',
    en: 'limit must be an integer from 1 to {max}.',
  },

  // ---- content moderation ---------------------------------------------------------------------------------------
  content_inappropriate: {
    vi: 'Nội dung chứa từ ngữ không phù hợp',
    en: 'The text contains inappropriate language.',
  },
  content_scam: {
    vi: 'Không được quảng cáo mua bán tài khoản, cày thuê hoặc để lại số điện thoại.',
    en: 'Advertising account sales or boosting, or leaving a phone number, is not allowed.',
  },
  content_too_complex: {
    vi: 'Nội dung có quá nhiều ký tự rời rạc, hãy viết lại gọn hơn.',
    en: 'The text has too many isolated characters; please rewrite it more simply.',
  },

  // ---- limits and availability ----------------------------------------------------------------------------------
  rate_limited: {
    vi: 'Bạn thao tác quá nhanh, vui lòng thử lại sau.',
    en: 'You are doing that too fast, please try again later.',
  },
  server_busy: {
    vi: 'Máy chủ đang quá tải, vui lòng thử lại sau ít giây.',
    en: 'The server is busy, please try again in a few seconds.',
  },
  server_error: {
    vi: 'Máy chủ gặp lỗi, vui lòng thử lại sau.',
    en: 'The server ran into a problem, please try again later.',
  },

  // ---- sanctions ------------------------------------------------------------------------------------------------
  account_banned: {
    vi: 'Tài khoản của bạn đã bị khóa quyền sử dụng Cộng đồng.',
    en: 'Your account is banned from the Community.',
  },
  account_restricted: {
    vi: 'Quyền đăng bài, bình luận, tìm đồng đội và bình chọn của bạn đang bị hạn chế tạm thời.',
    en: 'Your posting, commenting, LFG and voting rights are temporarily restricted.',
  },
} as const;

export type Reason = keyof typeof REASONS;

export type ReasonParams = Record<string, string | number | boolean | null>;

/** Fills `{name}` placeholders; a missing parameter is left visible so the bug shows up in tests. */
export function fillTemplate(template: string, params: ReasonParams = {}): string {
  return template.replace(/\{(\w+)\}/g, (whole, name: string) => (name in params ? String(params[name]) : whole));
}

export function reasonMessages(reason: Reason, params: ReasonParams = {}): { message: string; messageEn: string } {
  const r = REASONS[reason];
  return { message: fillTemplate(r.vi, params), messageEn: fillTemplate(r.en, params) };
}
