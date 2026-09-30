# WP-COPY — Điểm nối thông điệp máy chủ

Chỉ liệt kê để Claude/WP-SRV xử lý; WP-COPY không sửa `server/**`. Client hiện không in `error.message`/`messageEn` hay `params` ra màn hình. Các reason kiểm duyệt/hạn chế đã được ánh xạ trong app; các validation cũ chưa có reason dùng câu dự phòng, vì vậy chưa thể giải thích riêng hạn mức ảnh. Cần thêm reason ổn định và tham số số an toàn cho các vị trí dưới.

| File:dòng | Lời/mã đang trả về (ngữ cảnh tối đa 5 dòng) |
|---|---|
| `server/community/src/app.ts:22` | `    throw reasonError('invalid_input', 'body_too_large');` |
| `server/community/src/app.ts:51` | `      throw reasonError('server_busy', 'server_busy', {}, 2);` |
| `server/community/src/app.ts:86` | `    const err = new ApiError('not_found', 'Không tìm thấy đường dẫn.');` |
| `server/community/src/app.ts:100` | `      err = reasonError('server_error', 'server_error');` |
| `server/community/src/context.ts:47` | `  return reasonError('suspended', s.kind === 'ban' ? 'account_banned' : 'account_restricted', {     kind: s.kind,     until: s.until === null ? null : new Date(s.until).toISOString(),     cause: s.reason,   });` |
| `server/community/src/context.ts:176` | `      throw invalid(\`${field} không phải ${what} của VALORANT.\`);` |
| `server/community/src/context.ts:242` | `      throw reasonError(         'rate_limited',         'rate_limited',         { bucket: 'requests', limit: this.tuning.userRequestLimitPerMin, windowSeconds: 60 },         bucket.retryAfterSeconds,` |
| `server/community/src/context.ts:265` | `      throw reasonError(         'rate_limited',         'rate_limited',         { bucket: name, limit, windowSeconds: Math.round(windowMs / 1000) },         retryAfter,` |
| `server/community/src/cursor.ts:19` | `  if (raw.length > 200 \|\| !/^[A-Za-z0-9_-]+$/.test(raw)) throw invalid('cursor không hợp lệ.');` |
| `server/community/src/cursor.ts:38` | `  throw invalid('cursor không hợp lệ.');` |
| `server/community/src/errors.ts:45` | `    message: string,` |
| `server/community/src/errors.ts:56` | `export function reasonError(code: ErrorCode, reason: Reason, params: ReasonParams = {}, retryAfter?: number): ApiError {   const { message, messageEn } = reasonMessages(reason, params);   return new ApiError(code, message, retryAfter, { reason, params, messageEn }); } ` |
| `server/community/src/errors.ts:58` | `  return new ApiError(code, message, retryAfter, { reason, params, messageEn });` |
| `server/community/src/errors.ts:62` | `  const error: Record<string, unknown> = { code: err.code, message: err.message };` |
| `server/community/src/errors.ts:70` | `export const invalid = (message: string) => new ApiError('invalid_input', message);` |
| `server/community/src/errors.ts:71` | `export const notFound = (message = 'Không tìm thấy.') => new ApiError('not_found', message);` |
| `server/community/src/errors.ts:73` | `  new ApiError('forbidden', message);` |
| `server/community/src/errors.ts:75` | `  new ApiError('unauthorized', message);` |
| `server/community/src/geo/languages.ts:51` | `  if (!lang) throw invalid(\`${field} phải là một trong: ${LANGUAGES.join(', ')}.\`);` |
| `server/community/src/geo/languages.ts:69` | `  if (!lang) throw invalid(\`${field} phải là một trong: ${LANGUAGES.join(', ')}, any.\`);` |
| `server/community/src/geo/languages.ts:81` | `  if (parts.length > LANGUAGES.length + 1) throw invalid('language có quá nhiều giá trị.');` |
| `server/community/src/geo/scope.ts:19` | `  if (!c) throw invalid('country phải là mã quốc gia ISO 3166-1 alpha-2 (ví dụ VN).');` |
| `server/community/src/geo/scope.ts:43` | `      throw invalid(\`scope phải là một trong: ${SCOPES.join(', ')}.\`);` |
| `server/community/src/imaging.ts:18` | `  constructor(message: string) {     super(message);     this.name = 'ImageError';   } }` |
| `server/community/src/moderation/filter.ts:1037` | `  if (r.rejected === 'complex') throw reasonError('invalid_input', 'content_too_complex');` |
| `server/community/src/moderation/filter.ts:1038` | `  if (r.rejected === 'scam' \|\| r.rejected === 'phone') throw reasonError('invalid_input', 'content_scam');` |
| `server/community/src/moderation/filter.ts:1039` | `  if (r.rejected) throw reasonError('invalid_input', 'content_inappropriate');` |
| `server/community/src/reasons.ts:62` | `  server_error: {     vi: 'Máy chủ gặp lỗi, vui lòng thử lại sau.',     en: 'The server ran into a problem, please try again later.',   }, ` |
| `server/community/src/reasons.ts:87` | `export function reasonMessages(reason: Reason, params: ReasonParams = {}): { message: string; messageEn: string } {   const r = REASONS[reason];   return { message: fillTemplate(r.vi, params), messageEn: fillTemplate(r.en, params) }; }` |
| `server/community/src/reasons.ts:89` | `  return { message: fillTemplate(r.vi, params), messageEn: fillTemplate(r.en, params) };` |
| `server/community/src/routes/account.ts:12` | `    if (!data) throw new ApiError('unauthorized', 'Tài khoản không tồn tại.');` |
| `server/community/src/routes/auth.ts:20` | `    throw invalid('consentVersion phải gồm 1-32 ký tự chữ, số, . _ -');` |
| `server/community/src/routes/auth.ts:39` | `        throw reasonError(           'rate_limited',           'rate_limited',           { bucket: bucket as string, limit: limit as number, windowSeconds: AUTH_ATTEMPTS.windowMs / 1000 },           retry as number,` |
| `server/community/src/routes/auth.ts:55` | `    if (language === null) throw invalid('language không được để trống.');` |
| `server/community/src/routes/auth.ts:58` | `    if (consentVersion === null) throw invalid('consentVersion không được để trống.');` |
| `server/community/src/routes/auth.ts:70` | `        throw new ApiError(           'riot_unavailable',           'Máy chủ Riot đang bận hoặc không phản hồi, vui lòng thử lại sau ít phút.',           identity.retryAfter,         );` |
| `server/community/src/routes/auth.ts:77` | `      throw new ApiError('riot_rejected', 'Riot từ chối phiên đăng nhập. Hãy đăng nhập lại.');` |
| `server/community/src/routes/auth.ts:136` | `    if (regionRaw === null) throw new ApiError('invalid_input', 'region không được để trống.');` |
| `server/community/src/routes/auth.ts:139` | `    if (languageRaw === null) throw invalid('language không được để trống.');` |
| `server/community/src/routes/auth.ts:141` | `    if (!updated) throw new ApiError('unauthorized', 'Tài khoản không tồn tại.');` |
| `server/community/src/routes/lfg.ts:95` | `      if (!/^\d{1,2}$/.test(q.rank)) throw invalid('rank phải là số nguyên từ 0 đến 27.');` |
| `server/community/src/routes/lfg.ts:101` | `      if (q.mic !== 'true' && q.mic !== 'false') throw invalid('mic phải là true hoặc false.');` |
| `server/community/src/routes/lfg.ts:124` | `      throw invalid('partyCode phải gồm đúng 6 chữ in hoa hoặc số.');` |
| `server/community/src/routes/lfg.ts:132` | `    if (rankMin && rankMax && rankMin > rankMax) throw invalid('rankMin không được lớn hơn rankMax.');` |
| `server/community/src/routes/lfg.ts:186` | `    if (partySize === null) throw invalid('partySize không được để trống.');` |
| `server/community/src/routes/lfg.ts:189` | `    if (slots === null) throw invalid('slots không được để trống.');` |
| `server/community/src/routes/lfg.ts:193` | `    if (status === null) throw invalid('status không được để trống.');` |
| `server/community/src/routes/media.ts:14` | `const tooLarge = () => invalid('Ảnh tối đa 2 MB.');` |
| `server/community/src/routes/media.ts:49` | `    if (!declared) throw invalid('Chỉ hỗ trợ ảnh JPEG, PNG hoặc WebP.');` |
| `server/community/src/routes/media.ts:55` | `    if (raw.length === 0) throw invalid('Không có dữ liệu ảnh.');` |
| `server/community/src/routes/media.ts:58` | `      throw invalid('Dữ liệu không phải ảnh hợp lệ hoặc không khớp content-type.');` |
| `server/community/src/routes/media.ts:66` | `      if (e instanceof ImageError) throw invalid('Không đọc được ảnh (tệp hỏng hoặc kích thước quá lớn).');` |
| `server/community/src/routes/media.ts:73` | `      throw invalid(         \`Bạn đã dùng hết dung lượng ảnh (${mb(userQuota)} MB). Hãy xóa bớt bài viết có ảnh rồi thử lại.\`,       );     }     if (x.repo.mediaBytes() + clean.bytes.length > totalCap) {` |
| `server/community/src/routes/media.ts:78` | `      throw new ApiError('storage_full', 'Kho ảnh của máy chủ đã đầy, vui lòng thử lại sau.');` |
| `server/community/src/routes/posts.ts:35` | `    throw invalid('Bài viết loại text không có payload.');` |
| `server/community/src/routes/posts.ts:37` | `  if (!isObject(raw)) throw invalid(\`Bài viết loại ${kind} cần payload.\`);` |
| `server/community/src/routes/posts.ts:40` | `    throw invalid(\`payload.offers phải có từ 1 đến ${MAX_OFFERS} mục.\`);` |
| `server/community/src/routes/posts.ts:44` | `    if (!isObject(o)) throw invalid(\`${f} không hợp lệ.\`);` |
| `server/community/src/routes/posts.ts:52` | `    if (discountCost > baseCost) throw invalid(\`${f}.discountCost không được lớn hơn baseCost.\`);` |
| `server/community/src/routes/posts.ts:155` | `        throw invalid(\`media phải là mảng tối đa ${MAX_MEDIA} key.\`);` |
| `server/community/src/routes/posts.ts:158` | `        if (typeof k !== 'string' \|\| !MEDIA_KEY_RE.test(k)) throw invalid('media chứa key không hợp lệ.');` |
| `server/community/src/routes/posts.ts:161` | `      if (new Set(media).size !== media.length) throw invalid('media có key trùng lặp.');` |
| `server/community/src/routes/posts.ts:165` | `      throw invalid('Bài viết không được để trống.');` |
| `server/community/src/routes/posts.ts:174` | `      throw invalid('Bài viết không được để trống.');` |
| `server/community/src/routes/posts.ts:181` | `        if (!m \|\| m.status !== 'active') throw invalid('Ảnh không tồn tại, hãy tải lên lại.');` |
| `server/community/src/routes/posts.ts:183` | `        if (m.post_id !== null) throw invalid('Ảnh này đã được dùng ở một bài viết khác, hãy tải lên lại.');` |
| `server/community/src/routes/posts.ts:252` | `    if (text === '') throw invalid('body không được để trống.');` |
| `server/community/src/routes/public-guard.ts:51` | `        throw reasonError(           'rate_limited',           'rate_limited',           { bucket: isMedia ? 'anonMedia' : 'anonRead', limit, windowSeconds: 60 },           r.retryAfterSeconds,` |
| `server/community/src/routes/reviews.ts:90` | `    if (cursor && (sort === 'top') !== (cursor.likes !== undefined)) throw invalid('cursor không hợp lệ.');` |
| `server/community/src/routes/skins.ts:116` | `    if (parts.length === 0) throw invalid('ids không được để trống.');` |
| `server/community/src/routes/skins.ts:117` | `    if (parts.length > MAX_IDS) throw invalid(\`ids tối đa ${MAX_IDS} UUID.\`);` |
| `server/community/src/validate.ts:43` | `    throw invalid('Nội dung yêu cầu không phải JSON hợp lệ.');` |
| `server/community/src/validate.ts:45` | `  if (!isObject(parsed)) throw invalid('Nội dung yêu cầu phải là một đối tượng JSON.');` |
| `server/community/src/validate.ts:58` | `  if (typeof v !== 'string') throw invalid(\`${field} phải là UUID.\`);` |
| `server/community/src/validate.ts:60` | `  if (!UUID_RE.test(s)) throw invalid(\`${field} phải là UUID.\`);` |
| `server/community/src/validate.ts:70` | `    throw invalid(\`${field} phải là một trong: ${allowed.join(', ')}.\`);` |
| `server/community/src/validate.ts:77` | `    throw invalid(\`${field} phải là số nguyên từ ${min} đến ${max}.\`);` |
| `server/community/src/validate.ts:98` | `  if (typeof v !== 'string') throw invalid(\`${field} phải là chuỗi.\`);` |
| `server/community/src/validate.ts:99` | `  if (v.includes('\u0000')) throw invalid(\`${field} chứa ký tự không hợp lệ.\`);` |
| `server/community/src/validate.ts:103` | `  if (len < min) throw invalid(\`${field} không được để trống.\`);` |
| `server/community/src/validate.ts:104` | `  if (len > opts.max) throw invalid(\`${field} tối đa ${opts.max} ký tự.\`);` |
| `server/community/src/validate.ts:119` | `    throw invalid(\`${field} phải có dạng YYYY-MM-DD.\`);` |
| `server/community/src/validate.ts:123` | `    throw invalid(\`${field} không phải ngày hợp lệ.\`);` |
| `server/community/src/validate.ts:131` | `  if (!/^\d{1,4}$/.test(raw)) throw invalid(\`limit phải là số nguyên từ 1 đến ${max}.\`);` |
| `server/community/src/validate.ts:133` | `  if (n < 1 \|\| n > max) throw invalid(\`limit phải là số nguyên từ 1 đến ${max}.\`);` |
| `server/community/src/validate.ts:138` | `  if (typeof v !== 'boolean') throw invalid(\`${field} phải là true hoặc false.\`);` |
| `server/community/src/validate.ts:144` | `  if (!Array.isArray(v) \|\| v.length > max) throw invalid(\`${field} phải là mảng tối đa ${max} phần tử.\`);` |
| `server/community/src/validate.ts:146` | `  if (new Set(out).size !== out.length) throw invalid(\`${field} có phần tử trùng lặp.\`);` |
