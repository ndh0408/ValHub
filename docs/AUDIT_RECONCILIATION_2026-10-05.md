# ValHub — đối chiếu báo cáo bên ngoài và sửa lỗi chat (build 4022)

Phạm vi: báo cáo kiểm toán được chủ dự án gửi ngày 05/10, đối chiếu với code
sau checkpoint `055c77d`, các bằng chứng production đã ghi nhận và kiểm thử
sau bản sửa này. Hai bản báo cáo được dán trùng là cùng một đầu vào.
Không coi nhận định trong báo cáo là lỗi đã được chứng minh.

**Kết luận kiểm toán: cần tiếp tục hoàn thiện trước phát hành.** Nhiều mục
"chưa có" trong báo cáo sai với repository hiện tại. Tuy nhiên, kiểm tra phần
chat phát hiện lỗi cách ly bản nháp thật và đã tái hiện bằng test trước khi sửa.
Không có cơ sở để chấm lại sản phẩm bằng điểm 8.2/10 hoặc chứng nhận sẵn sàng
production từ số lượng test.

## Bản đồ khoảng trống trước khi sửa

| Phát hiện | Trạng thái ban đầu | Căn cứ / hướng xử lý |
|---|---|---|
| Bản nháp chat theo sang tài khoản khác, đăng xuất hoặc người nhận khác | ❌ REGRESSION / lỗi cách ly được tái hiện | Hai test mới thất bại trên code cũ; sửa phạm vi state của conversation |
| Review/rating/bình luận skin được ghi là không tồn tại | ✅ VERIFIED COMPLETE trong phạm vi đã thử | UI/providers/backend/tests đã có; lifecycle tài khoản thật ghi tại [deployment checkpoint](PRODUCTION_DEPLOYMENT_2026-10-05.md) |
| Chat/multi-account/LFG/Party/deep link được ghi là chưa có hoặc không có test | 🟡 PARTIAL | Có implementation và test; nghiệm thu tất cả thao tác Riot thật vẫn chưa đủ |
| i18n được ghi là chưa có hạ tầng | 🟡 PARTIAL | Hạ tầng tồn tại; cutover và bản dịch thật còn thiếu |
| Backend được ghi là chưa deploy | ✅ VERIFIED COMPLETE trong phạm vi rollout | API/backup/watchdog đã deploy và healthy, migrations/restore có bằng chứng |
| Signed store release, iPhone, HTTPS association, off-site destination | ⚠️ BLOCKED | Cần signing/access/thiết bị/domain/đích vận hành thật |
| Esports ratings và gợi ý ghép nhóm mới | 🔴 MISSING như đề xuất sản phẩm | Không phải bằng chứng các chức năng hiện có hỏng; cần dữ liệu thật và thiết kế trước khi bổ sung |

"REGRESSION" ở hàng đầu ghi nhận hành vi cách ly không đúng trên code trước
bản sửa; không khẳng định đã xác định commit nào lần đầu gây ra lỗi.

## Các nhận định cần sửa trong báo cáo

| Nhận định được gửi | Kết quả đối chiếu | Code / bằng chứng |
|---|---|---|
| Không có Skin Reviews/Votes | Sai | `lib/features/community/ui/skins/skin_review_screen.dart`, `providers/skin_review_providers.dart`, `providers/skin_comment_providers.dart`; `server/community/src/routes/{reviews,skins,skin-comments}.ts`; tests review/provider/UI/backend; review sở hữu và comment không sở hữu đã tạo/đọc/xóa thật |
| Cần phân rating theo ngày/khu vực | Không phải yêu cầu được chấp nhận | Rating skin hiện là toàn cầu, mọi thời gian theo quyết định chủ dự án; country/region của feed vẫn riêng |
| Chưa có chat | Sai | `lib/features/social/ui/chat_screen.dart`, `lib/core/xmpp/`; Social/XMPP tests. Đường truyền Riot thật và mọi lỗi reconnect vẫn cần nghiệm thu riêng |
| Chưa có multi-account, nên thêm 2–3 account | Sai | `lib/core/accounts/account_providers.dart`, `AppConstants.maxAccounts = 10`; sáu account thật giữ qua nâng APK; không tạo kiến trúc thứ hai |
| Party/LFG không có test | Sai | `test/features/social/ui/party_screen_test.dart`; `test/features/community/{ui,providers,data}` có create/join/action/expiry/lifecycle tests. Join intent không chứng minh đã chiếm ghế trong tổ đội Riot |
| Live Game không có test | Sai | `test/features/live_game/{data,providers,ui}` kiểm tra poller, phase, controller, overlay, current game và loadout. Chưa chứng nhận trận đang chơi trên PC thật |
| Night Market không có test / đếm ngược | Sai | `store/ui/widgets/night_market_section.dart`, `night_market_card.dart`; `test/features/store/night_market_seen_test.dart` và store UI suites; đếm ngược/empty/offer/ownership đã có |
| Không có biểu đồ RR / ước tính lên hạng | Sai | `profile/ui/widgets/rr_trend_chart.dart`, `rank_up_calculator_screen.dart` và test calculator/performance. Ước tính theo quy tắc không phải MMR bí mật chính thức của Riot |
| Deep link không có test | Sai | `test/app/deep_links_test.dart`, `app_deep_link_test.dart`, `router_test.dart`; native cold/warm smoke. HTTPS App Links/Universal Links vẫn thiếu association/web fallback đã nghiệm thu |
| Chưa có hệ thống i18n | Sai một phần | `lib/core/l10n`, `lib/l10n/arb/app_vi.arb`, generated resources, codemod/check/parity, locale/content/background providers đã có. Đúng là chỉ VI UI ships, chưa có 17 bản dịch thật |
| Backend là Express/NestJS + Prisma/PostgreSQL | Sai | `server/community/package.json`: Hono + better-sqlite3 + Sharp. Migration và backup thực tế dùng SQLite; không coi đó là bằng chứng PostgreSQL/Redis/object-storage |
| Mọi Store/History request qua Community backend hoặc val-content-v1 | Sai | On-device `PvpApi` gọi Riot PD/GLZ cho dữ liệu tài khoản; Community backend phục vụ Community và verification. Không dùng content metadata làm dữ liệu sở hữu/giá riêng tài khoản |
| Chỉ mới build Android debug / chưa build iOS | Sai một phần | Android release-mode APK và unsigned iOS build đã tồn tại; build 4022 kiểm tra lại. APK vẫn ký debug, IPA chưa ký: chưa đạt store release |
| Chưa có Dockerfile/healthcheck/CI | Sai | Docker/Compose/API health/backup/watchdog và `.github/workflows/{android,ios,server,l10n}.yml` tồn tại. GitHub billing trước đó cản Actions; local CI có thể chạy |
| Đăng nhập app bằng Apple/Discord/Google đã có | Không có bằng chứng | Luồng xác thực hiện dùng Riot WebView/session. Không dùng Google sign-in thay cho quyền sở hữu Riot |
| Cần FCM/APNs để các notification hiện tại hoạt động | Chưa được chứng minh | Local scheduling/background và channel migration đã có; native test giữ giới hạn 60. Không ghi nhận push FCM/APNs production đã triển khai |
| Chưa có bảo mật/backup/observability | Quá rộng | Middleware/session ownership/rate/input/idempotency/media validation, log an toàn, metrics/deep-health/watchdog, SQLite backup/drill tồn tại; xem [endpoint audit](BACKEND_ENDPOINT_AUDIT_2026-10-03.md) và deployment checkpoint. Không phải pentest/compliance/full-host disaster recovery |
| DailyVal có 1.2 triệu active users, điểm sao hoặc ValHub 8.2/10 | Chưa xác minh | Báo cáo không cung cấp nguồn/phiên bản thị trường/thời điểm/phương pháp chấm. Không dùng các số này để quyết định release |

Esports ratings, bản đồ tương tác, gợi ý skin hay ghép nhóm là đề xuất sản
phẩm bổ sung, không được đánh tráo thành lỗi của baseline. Giữ dữ liệu thật,
thuật toán quyết định theo quy tắc và ML Kit miễn phí đã được chủ dự án cho
phép; không thêm model/API trả phí.

## Lỗi thật đã sửa

`ChatScreen` cũ giữ một `TextEditingController` xuyên suốt thay đổi tài khoản
hoặc recipient. Nội dung chưa gửi có thể xuất hiện trong conversation mới.
Ngoài ra callback gửi đã lấy từ UI cũ cần kiểm tra lại sender trước khi gửi.

State chat hiện được keyed bằng `(activePuuid, normalizedRecipient)`. Khi
sender/recipient đổi, draft và focus được hủy cùng state cũ. Trước khi gọi
XMPP, sender hiện tại và `service.puuid` phải khớp sender của màn hình.
Phản hồi sau await chỉ cập nhật UI còn mounted và đúng sender; không xóa
đoạn văn mới người dùng đã nhập trong lúc chờ.

Ba regression tests kiểm tra account switch/logout, đổi recipient và callback
gửi cũ chạy sau sender change trước rebuild. Hai test đầu được chạy trước sửa:
5 test cũ pass, 2 test mới fail. Sau sửa Social/XMPP suite đạt 128 tests trên
Windows và Mac. Không giảm assertion, xóa test hoặc đổi kiến trúc XMPP.
Không gửi chat thật tới bạn bè hay người khác để kiểm thử.

## Kiểm tra sau triển khai

Evidence local nằm trong `dist/review/deploy-2026-10-05/` (ignored, không chứa
credentials trong báo cáo). `chat-regression-before.log` chứng minh lỗi ban
đầu; `social-audit-tests.log`, `audit-flutter-test*.log`, `audit-analyze.log`,
`audit-mac-console.log`, `audit-l10n-verify.json` ghi các kết quả thực tế.

| Kiểm tra mới | Kết quả |
|---|---|
| Windows Flutter analyze | 0 issues |
| Flutter toàn bộ / `TEST_LOCALE=en` | 4.389 tests pass mỗi lượt; en là fallback test, không phải English UI |
| Social/XMPP Windows / Mac | 128 tests pass mỗi hệ thống |
| Mac analyze / iOS release-mode build | 0 issues; build 4022 thành công, privacy manifest hợp lệ; `codesign` xác nhận chưa ký |
| Source Windows/Mac | SHA-256 ba input thay đổi khớp nhau |
| Android native integration trên QA 5582 | 6 tests pass: country/keyboard/persistence, Community country, Keystore, channels, 60 schedules, About |
| Android release-mode build / public-flow QA | APK 4022 thành công; 10 cases pass trên 5582, gồm cold/warm/deferred/invalid link và landscape 200% text |
| Emulator chủ dự án / Mobile MCP + cache/log | Nâng APK bằng install-r; sáu accounts/active/wishlist/settings giữ nguyên, six country records giữ; native fatal/unhandled 0. Hierarchy đọc được toàn cầu/mọi thời gian, search và các hàng skin thật; không test chat thật |
| `flutter gen-l10n` / `l10n_check --ci` | Pass; check 0 errors/warnings |
| Codemod `verify --ci` | Exit 1: 1 production reference / 768 Vietnamese literals / cutover false; không bỏ gate |
| Backend production | API/backup/watchdog healthy, vẫn chạy `afa7162`; không rebuild backend chỉ vì frontend đổi |

Backend 949 tests/typecheck/build, npm production audit, Docker/native backup/
restore/Trivy ở [checkpoint rollout](PRODUCTION_DEPLOYMENT_2026-10-05.md) là
bằng chứng trước đó trong ngày; không ghi thành một lượt chạy mới của patch
frontend này. Mac chỉ chạy Social/XMPP suite cho patch này, không nhận là đã
chạy lại toàn bộ 4.389 tests trên Mac.

Artifact local: `dist/review/ValHub-1.0.0-4022.apk` (125.600.707 bytes,
SHA-256 `EF33C965DA43F9EC31C6FDD768F804EC8F8F92E318D1CC4729077335620E5EA0`),
và `dist/review/ValHub-1.0.0-4022-unsigned.ipa` (28.045.352 bytes,
SHA-256 `EC83B01BD4271283D3BAA942E5D554851FC0355E04ADDC7780A14AC46F5365A8`).
Package/bundle ID vẫn `vn.valvn.app`; brand ValHub. Android certificate là
Android Debug; Mac codesign xác nhận app không ký. Không upload store.

`audit-owner-runtime.json` ghi status aggregate của cửa sổ log một giờ; nó
vẫn chứa năm 503 của thử ownership **trước khi sửa ở checkpoint rollout**.
Không gọi chúng là lỗi mới của 4022, cũng không xóa chúng để làm báo cáo đẹp.
Lần đọc mới `/v1/skins/top`, `/v1/skins/votes` và `/v1/lfg` trả 200. Patch
này không gửi lại review/chat hay tạo nội dung thật khác.

Scan production `lib`, `server/community/src`, Android main và iOS Runner
ghi `audit-marker-scan.json`: TODO/FIXME/HACK 0 file, GMT+7/Vietnam-only/
localhost 0; các hit khác đã phân loại, không thay tự động. `_mock` là preview
theme Settings; `stub` là comment injection test; `debugPrint` hiện ghi tên
loại lỗi, không token/body; nhiều `print` là từ `fingerprint`. VND xuất hiện
ở ví dụ/formatter/nhãn estimate hỗ trợ cấu hình, không bằng chứng hardcode
tiền của mọi người. `ValVN` là URL feedback compatibility; `http://` chủ yếu
XML/XMPP namespaces và loopback watchdog, không phải Riot token qua HTTP.
Không coi search bằng từ khóa là toàn bộ security audit.

## 🟢 VERIFIED COMPLETE

Bản sửa cách ly draft/callback được chứng minh bằng test trước/sau; các
checks mới nêu trên. Community rating/comment/ownership/global aggregation,
rollout và real-data SQLite restore có bằng chứng trong checkpoint production.

## 🟡 PARTIAL

Chat/Party/live match/friends/LFG đã có và có tests, nhưng còn nghiệm thu
Riot thật, reconnect, membership/capacity và tác động PC. Fresh-login data
prefetch, toàn bộ responsive/a11y/performance/UX và privacy acceptance còn
thiếu. Block device-local không phải server-side peer block; scope discovery
không phải ACL private/friends. Moderation có bộ lọc theo quy tắc, chưa chứng
nhận đầy đủ chất lượng 18 ngôn ngữ.

## 🔴 RELEASE BLOCKER

P0 i18n: VI UI only; W2–W7/cutover/legal/52 structural members và 17 bản dịch
thật/RTL/font/device acceptance còn mở. Không sao chép Vietnamese sang locale
khác để tạo cảm giác hoàn tất. Thiếu whole-product acceptance dù test xanh.

## ⚠️ EXTERNAL BLOCKER

Play/Apple signing/store access, physical-device acceptance, domain association
và HTTPS public fallback, off-site backup/erasure ledger/alert destinations và
full-host restore/RPO/RTO. Android debug-signed release-mode APK và unsigned
iOS build chưa phải store artifact. Không giả lập credentials/destination.

## ❌ REGRESSION

Lỗi draft isolation đã sửa và kiểm tra lại; không thấy regression còn mở trong
phạm vi đã chạy. Các luồng chưa thử vẫn chưa được chứng nhận, không ghi "done"
hay "production ready" cho toàn sản phẩm.
