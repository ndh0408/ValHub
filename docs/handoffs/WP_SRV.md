# Báo cáo bàn giao WP-SRV — ValVN

Ngày: 01/10/2026. Worktree: `codex-wp-srv`; nhánh: `ndh0408/codex-wp-srv`.

Đã đọc `docs/HANDOFF.md` (mục 1–3), `CLAUDE.md`, `docs/GLOBAL_AUDIT.md`, `docs/audit/AUDIT_COMMUNITY.md` và các mục GL-15/20/28/40 liên quan. Khi bắt đầu, HEAD và `claude/jolly-hawking-23o2j8` cùng ở `e6ddc356831acdd06de689f52d510cbf10e590d8`, nên bỏ qua merge đúng theo yêu cầu. Giữ nhánh hiện có của worktree.

Chỉ sửa `server/community/**`, `.github/workflows/server.yml`, cùng hai tài liệu được yêu cầu riêng: `docs/community-api.md` và báo cáo này. Không sửa Flutter, tài liệu pháp lý hoặc migration đã có; không push, gộp nhánh chính, SSH hay deploy. Docker chỉ build image và chạy kiểm tra tạm, không khởi động API/compose production.

## Từng phát hiện

“Xong” là phần máy chủ trong phạm vi WP-SRV đã có mã và kiểm tra. Các kiểm chứng CDN/host/client thật chưa thực hiện được ghi riêng; không xem test cục bộ là bằng chứng production.

| ID | Trạng thái | Kết quả / lý do |
|---|---|---|
| CS-01 | Xong | Kiểm tra lại nền đã có: media 200/304 có header Cloudflare no-store, JSON/lỗi no-store. Cần Claude kiểm tra CF Cache Rules và HIT sau deploy. |
| CS-02 | Xong (server) | Kế thừa sanctions/audit, Ctx kiểm tra ban/restrict, CLI ban/unban/hide/delete-content/reports/hidden; test xanh. Block/mute và kháng nghị trên Flutter nằm ngoài đường dẫn được sửa. |
| CS-03 | Xong | Kế thừa limiter trước filter, bucket theo user, bounded moderation và load shedding 503. Chưa đưa filter sang worker; HANDOFF cho phép giữ kiến trúc và đây không phải điều kiện tối thiểu của gói. |
| CS-04 | Xong | Giữ iat/epoch/logout/kid và hai khóa; siết iat/exp/ep, thêm tombstone 30 ngày. Token cũ không sống lại khi xóa rồi đăng nhập cùng mili giây. |
| CS-05 | Xong | Hoàn tất canonical base/level/chroma và suy ra weapon; migration alias, gộp có transaction ở startup/sweeper. Giữ thời điểm/origin đầu, body mới nhất, hidden/moderator, likes/reports phân biệt. Route dùng alias đã lưu cả khi catalog mất. Không hard-code UUID từ một bản catalog vào migration SQL. |
| CS-06 | Xong (server) | Người báo cáo đủ tuổi/hoạt động, không đang bị sanction: trọng số 1, hoặc 2 khi có báo cáo trước trên nội dung hiện bị moderator ẩn; tối đa góp 3 lần tự ẩn/ngày UTC. Giữ thông tin hidden/reason của tác giả cho post/review/LFG. Phản hồi report vẫn 204 rỗng; CLI eligible là số người, không phải tổng trọng số. UI kháng nghị ngoài phạm vi. |
| CS-07 | Xong | Chỉ cộng phiếu/rating công khai của tài khoản ≥24 giờ, có hoạt động và không sanction; tài khoản mới vẫn lưu được lựa chọn. MIN_RATINGS_FOR_RANK=10, C=15; tuần tính created_at đầu, không tính lần sửa. Đây là tiêu chí nội bộ, không chứng minh một người thật duy nhất. |
| CS-08 | Một phần | Đã bỏ WebP động/flag animation, giới hạn 16 MP và cạnh 8192 px; metadata stripping và fuzz giữ nguyên. Chưa thêm decoder/WASM re-encode: compressed pixel stream vẫn giữ, chưa xác minh decoder đa nền tảng ổn định. Không tuyên bố kiểm tra đầy đủ nội dung pixel. |
| CS-09 | Bỏ qua | Sửa câu đồng ý trong Flutter; ngoài gói/đường dẫn. Server không lưu PUUID như trước. |
| CS-10 | Bỏ qua | ML Kit phía client; HANDOFF cho phép công cụ dịch miễn phí trên máy, không yêu cầu xóa. Telemetry cần review phía client. |
| CS-11 | Xong | ErasureLedger append+fsync trước xóa, fsync thư mục trên Linux; lỗi/corrupt fail closed. Replay trước nghe HTTP và trước restore restart; giữ user tạo sau lần xóa. Undo archives hết hạn 14 ngày, staging bỏ dở 24 giờ. Mất cả host và ledger mới nhất vẫn có rủi ro với archive cũ. |
| CS-12 | Xong (mã/runbook) | Disk staging, online snapshot độc lập không chứa WAL/SHM, integrity/FK/media checks, health stamps, diễn tập migration+replay hàng tuần, encrypted age off-site hook; retention chạy cả khi lỗi. Docker smoke kiểm chứng mã hóa/giải mã và hook thất bại. Destination/credentials/retention remote cần operator cấu hình; chưa gửi bản sao ra ngoài. |
| CS-13 | Xong | Kế thừa IPv6 /64, bỏ XFF làm identity, trust proxy mặc định false, media limiter bất kể Authorization và map có giới hạn. Rule Cloudflare tùy chọn chưa thao tác. |
| CS-14 | Xong | Kế thừa ngưỡng NAT 300 attempts/30 rejected auth mỗi 10 phút, 600 public reads/phút, feed cache 5 giây; vẫn cần số liệu tải production để tuning. |
| CS-15 | Một phần (rollout) | Join trả joins+partyCode, chỉ party open; flag LFG_CODE_IN_LIST mặc định true giữ client cũ. False giấu code người khác; owner vẫn có code. Chặn public full/in_game filter. Phải phát hành client gọi join trước thao tác Riot rồi mới tắt flag. |
| CS-16 | Xong | UPDATE LFG kiểm tra id+owner+expires_at ngay trong SQL, đọc changes; heartbeat không hồi sinh bài bị thay thế. |
| CS-17 | Xong | Attach media cần post_id NULL/status active và đủ changes trong transaction; quota kiểm tra lại trong insert transaction sau file put; lỗi dọn file; sweeper xử lý dangling post_id. Test đua upload/attach. |
| CS-18 | Một phần | Cap 2048 segment/chunk, từ chối allocation flood sớm, kiểm tra pixel/animation và fuzz. Chưa tách sanitizer sang worker resourceLimits; parser hiện vẫn trên event loop. |
| CS-19 | Xong | Match trên NFC gốc trước loại control/bidi, hạn chế combining/newline flood. Giữ ZWJ/ZWNJ cho emoji/chữ viết và ZWSP tiếng Thái để tránh phá văn bản hợp lệ. |
| CS-20 | Một phần | Giữ DM/CC tiếng Anh khi không có ngữ cảnh Việt; chọn vi khi khai báo/script/quốc gia VN, allow-list HTTPS host, bổ sung acc/accounts for sale. Không theo gợi ý audit áp vi cho mọi Latin vì trái luật toàn cầu/GL-20. Chưa có native review và mẫu điện thoại nội địa bổ sung. |
| CS-21 | Một phần | Optional Idempotency-Key cho POST post/comment/media: hash account+route+key, so payload, replay 24 giờ, single-flight, kiểm tra auth lại, xóa cached response khi xóa nội dung/tài khoản. Còn crash window giữa commit nội dung và lưu key; chưa bảo đảm exactly-once qua crash/multi-replica. |
| CS-22 | Xong | Kế thừa bộ đếm IP hash chỉ RAM; không backup IP counters. User counters vẫn SQLite theo chính sách chống né hạn mức. |
| CS-23 | Một phần | README nêu LFG 8 ngày sau expiry và các retention khác; không tự xóa tài khoản vô hoạt động vì đó là thay đổi chính sách. Privacy/legal ngoài phạm vi vẫn cần cập nhật, nội dung giữ đến khi tác giả/moderator xóa. Ledger giữ lâu dài để replay, chưa có compaction được xác minh. |
| CS-24 | Bỏ qua | Không có response Riot thật xác minh affinity/rank; đây không nằm hàng thấp được HANDOFF giao. Region/rank/card/store vẫn client-supplied, không được dùng làm đặc quyền; không bịa dữ liệu xác minh. |
| CS-25 | Một phần | Riot redirect manual, cap response 64 KiB, không log bí mật; README ghi TLS kết thúc ở Cloudflare. Chính sách pháp lý và cấu hình Logpush/header logging cần Claude/operator review ngoài gói. |
| CS-26 | Xong | Global maximum 20 Riot verifications, cooldown theo Retry-After và bounded negative cache hash 60 giây trong RAM. Test concurrency/cooldown/hash rejection. |
| CS-27 | Xong | Riot game_name/tag_line thiếu/rỗng không tạo user: trả unavailable, không lưu tác giả tên trống. |
| CS-28 | Bỏ qua | Pin remote-config/token sink thuộc Flutter, không sửa client. |
| CS-29 | Một phần | Node 22 digest pin, CPU caps/init, keepalive 120s/headers 125s, secret _FILE. Chưa đổi shared edge network khi topology thật chưa xác minh; chưa thao tác secret mounts production. |
| CS-30 | Xong (workflow) | PR/push đúng paths, manual/weekly; npm test, tsc, npm audit production, Docker build, shell/smoke, Trivy HIGH/CRITICAL fixed. Không publish/deploy. Chưa chạy workflow GitHub hoặc scan Trivy tại máy này; billing/runner có thể cần mở lại. |
| CS-31 | Một phần | Counter lỗi theo route pattern mỗi phút; log chỉ error name, không raw error message. Loopback-only deep health: ping DB, write probe, free bytes, WAL, lag; từ chối forwarding headers. Chưa cài host watchdog/autoheal/alert. |
| CS-32 | Một phần | PRAGMA optimize trong housekeeping. Chưa materialize skin_stats/user_media_bytes hoặc bỏ index: cần EXPLAIN/benchmark dữ liệu thật trước đổi bảng/cache stats đồng bộ; không có tải production để chứng minh. |
| CS-33 | Xong (server) | Mọi ApiError có fallback reason/messageEn, validator/media/filter có reason cụ thể và params; giữ message Việt cho client cũ. Flutter localization ngoài gói. |
| CS-34 | Một phần (client) | Kế thừa consentVersion/time trong auth/export; không bắt buộc field để giữ tương thích. Phiên bản và re-prompt UI Flutter còn cần nối. |
| CS-35 | Bỏ qua mã, cập nhật runbook | Không thuộc danh sách thấp HANDOFF; README ưu tiên authenticated in-app export/delete, bỏ lời khuyên xác minh không thực hiện được qua email Riot. Chưa làm OTP client/operator hoặc audit export/delete mới. |
| CS-36 | Xong | Production bắt buộc PUBLIC_BASE_URL HTTPS thật, không credentials/query/hash/host example; .env.example bỏ placeholder. JSON no-store. |
| CS-37 | Xong | Kế thừa rate counters không xóa cùng user, tự hết hạn; test giữ nguyên. |
| CS-38 | Xong | Snapshot catalog restore trước startup, background-only refresh/unknown retry, failure backoff và cap Content-Length/stream. Test restart outage, corrupt snapshot và oversize trước đọc body. |
| CS-39 | Xong | ACCOUNT_TABLE_POLICIES và test enumerate FK/users, *_user_id/reporter_id; table mới không có policy làm test đỏ. Export/erase thêm recentCreates; test tombstone và các bảng erase. |
| CS-40 | Xong (tài liệu theo HANDOFF) | README ghi async Repo/dialect/split repo/contract suite/ETL và guard transaction cần giữ. Không đổi engine hay biến toàn Repo thành async trong gói. |
| CS-41 | Xong (tài liệu theo HANDOFF) | README ghi điểm nối async RateLimitStore/CacheStore/RevocationStore trong AppDeps, atomic TTL/counters/revocations/sweep lease và idempotency phối hợp replicas. Chưa tạo Redis adapter/interface thực thi. |
| GL-15 | Xong (server) | Mã reason ổn định và messageEn/params; những validation riêng thay chữ raw sang reason. Client map/localize vẫn ngoài scope. |
| GL-20 | Một phần | Bỏ giả định vi cho Latin unknown/en, giữ gaming abbreviations, thông báo English fallback. Chưa native review hoặc mở rộng tất cả phone formats. |
| GL-28 | Xong (server) | NFC và đếm Unicode code points, params.unit=unicode_code_points; không đếm UTF-16. Client counters/grapheme UX thuộc gói khác. |
| GL-40 | Xong (runtime) | LFG thiếu ngôn ngữ dùng author hoặc any; bỏ constant LFG_LANGUAGES chết. Không sửa migration 0003 đã áp dụng: SQL default vi cũ còn trong schema, mọi insert server gửi language rõ; writer SQL ngoài server cần gửi rõ. |

## Migration, dữ liệu và biến môi trường

Chỉ thêm:

- `0008_skin_aliases.sql`: ánh xạ alias/base/weapon; dữ liệu catalog điền động khi canonicalize, không cần gọi mạng bên trong SQL migration.
- `0009_revoked_accounts.sql`: epoch tombstone + expires_at/index; giữ 30 ngày, không FK user.
- `0010_idempotency.sql`: request_keys (FK cascade user), expiry/index, trigger xóa cached response khi post/comment/media bị xóa.

Startup áp migration, replay erasure ledger, restore catalog snapshot, canonicalize dữ liệu, rồi mới listen; warm catalog chạy nền. Canonicalization và merge chạy transaction; cần snapshot trước lần nâng phiên bản có dữ liệu thật. Migration cũ 0001–0007 không thay đổi.

Mới: `LFG_CODE_IN_LIST` (true), `SESSION_SECRET_FILE`, `SESSION_SECRET_PREV_FILE`, `PEPPER_FILE` (mount file; không set đồng thời value), `BACKUP_OFFSITE_CMD`, `BACKUP_AGE_RECIPIENT`. `PUBLIC_BASE_URL` nay bắt buộc HTTPS thật trong production. `BACKUP_KEEP_DAYS` giới hạn 1–14; backup health dựa `last-success`/`last-drill`. Không thêm khóa bí mật thật hoặc destination uploader vào git. Không đổi PEPPER sau launch.

Tệp dữ liệu mới: `/data/erasures.jsonl`, `/data/catalog.json`; backup `.tmp`, `last-success`, `last-drill`, tùy cấu hình thêm `.tgz.age`. Ledger chứa salted user id/thời điểm/epoch, cần quyền hạn chế và bản mới nhất độc lập archive cũ. Private age key ở ngoài host. Remote retention ≤14 ngày do operator quản lý. Replay account erasure không phải nhật ký tất cả lần xóa từng post; restore nội dung xóa lẻ vẫn cần quy trình retention/runbook.

## Tệp chính và kiểm chứng

Mã: `src/db/sqlite-repo.ts`, `src/context.ts`, `src/crypto.ts`, `src/erasures.ts`, `src/backup.ts`, `src/idempotency.ts`, `src/main.ts`, `src/content.ts`, `src/riot.ts`, `src/imaging.ts`, filter/reasons/validators/routes. Vận hành: Dockerfile, compose, backup-loop, restore, workflow. Tài liệu README và API được sửa trực tiếp các mô tả cũ (50 MP, C=5/min3, weekly edits, default vi, restore thủ công yêu cầu xóa).

Kết quả cuối trên mã ở `e8ccbb8`:

- `npm test`: **31 file / 847 test đạt**, không skip hoặc tắt test; nền ban đầu 825 test đạt.
- `npx tsc --noEmit`: **exit 0**.
- `npm run build`: **exit 0**.
- `npm audit --omit=dev`: **0 vulnerabilities**. Đây là audit npm, không phải kết quả scan CVE image.
- Docker build Node **22.23.3**, pinned digest: **đạt**; Windows host Node **24.19.0**.
- `sh -n` backup-loop/restore/ops-smoke trong container: **đạt**.
- `test/ops-smoke.sh` trên image cuối, uid 1000: **đạt**. Kiểm tra snapshot+media, health, age encrypt/decrypt giống archive, extract+drill replay xóa user/media trên copy, giữ dữ liệu nguồn, thất bại hook không cập nhật success, retention kể cả thất bại, xóa staging, từ chối symlink archive. Không chạy `restore.sh --yes` lên volume thật.
- Đã bắt và sửa hồi quy snapshot WAL/SHM nhờ smoke; unit test đảm bảo stage chỉ chứa snap.db/media/ledger.
- `git diff --check`: **đạt**; chỉ có cảnh báo chuyển LF/CRLF từ Git trên Windows. Docker chuẩn hóa LF cho ops scripts; CI Ubuntu kiểm tra shell.
- Không chạy Flutter analyze/test: không có sửa Flutter và gói yêu cầu npm/tsc. Không chạy CI GitHub, Trivy, CF probe hay đo tải production.

`npm ci` mặc định ban đầu lỗi node-gyp vì Windows thiếu Visual Studio C++; đã cài bằng `npm ci --ignore-scripts --no-audit --no-fund`. better-sqlite3 của lock hiện tại có prebuild và toàn bộ test native thực sự chạy; Docker/CI dùng cùng chế độ. Không đổi dependency/lock hoặc bỏ test native để né lỗi.

## Việc Claude/operator cần review tiếp

1. Review diff, rồi chạy pipeline/scan image trước deploy; kiểm tra CF cache headers thật và proxy topology. Không bật thêm API replica với limiter/cache/idempotency hiện tại.
2. Cấu hình URL/secrets, backup dir writable uid 1000, off-site uploader/age recipient/remote retention và sao chép ledger mới nhất. Diễn tập restore trên volume riêng trước dùng dữ liệu production.
3. Phát hành client nhận partyCode từ join trước thao tác Riot, nối logout/consent/reasons/kháng nghị/block; chỉ sau đó tắt LFG_CODE_IN_LIST.
4. Cập nhật pháp lý về Cloudflare, retention LFG/ledger/security logs và xác minh quyền dữ liệu. Chốt native moderation review, decoder re-encode và counters/materialization khi có phép đo.
5. Reviewer chú ý các giới hạn được ghi trong bảng: compressed image stream chưa decode, idempotency crash window, ledger/off-site durability khi host mất, canonical merge thay id của review thua collision. Không coi phần “một phần” là đã hoàn thành toàn bộ audit.

## Danh sách commit

Nền WP-SRV đã có (không tạo lại): `ac020a3` (CS-01), `66e3f19` (CS-03), `2064214` (CS-02/04/06/34), `9e07c85` (CS-13/14/22/37), `1fa4587` (canonical skin dở dang). Tip bàn giao: `e6ddc35`.

Commit Codex, đều tiếng Việt với danh tính Codex/noreply@openai.com và `commit -F`:

- `986f3f5`: WIP WP-SRV: gộp UUID skin, giữ thu hồi phiên và phát lại yêu cầu xóa.
- `48c53a0`: WIP WP-SRV: chống lạm dụng điểm, giới hạn báo cáo, sao lưu và mã lỗi đa ngôn ngữ.
- `fb5462a`: WIP WP-SRV: rà soát toàn vẹn dữ liệu, kiểm tra schema và cập nhật hợp đồng API.
- `9a244c9`: WIP WP-SRV: xác minh sao lưu trong Docker, mã hóa age và phục hồi an toàn.
- `e8ccbb8`: WIP WP-SRV: dùng alias đã lưu khi catalog gián đoạn và chặn quảng cáo bán tài khoản.
- `HEAD` (commit chứa báo cáo này): Bàn giao WP-SRV: ghi kết quả 847 test và các giới hạn cần review. Dùng `git log -1 --oneline` để lấy hash của commit báo cáo, vì hash không thể tự nhúng vào nội dung chính commit đó.
