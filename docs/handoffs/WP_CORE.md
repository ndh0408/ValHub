# Báo cáo bàn giao WP-CORE — ValVN

Ngày: 01/10/2026. Worktree: `codex-wp-core`, nhánh hiện có `ndh0408/codex-wp-core`.

Đã gộp `claude/jolly-hawking-23o2j8` bằng commit `de5024e`; không có xung đột. Giữ nền tảng i18n W0, Trang chủ, máy chủ v3 và các thay đổi WP-CORE trước đó. Đã đọc `docs/HANDOFF.md` (§1, §2, §3, §6), `CLAUDE.md`, `docs/GLOBAL_AUDIT.md`, các audit Accounts/Global/Product và xem lịch sử bốn commit WP-CORE trước khi hoàn thiện WIP.

Không push, gộp vào nhánh chính, deploy, chạy emulator/adb hoặc thiết bị. Không sửa mã nguồn `lib/app/**`, `lib/core/domain/**`, Home/Profile/Battle Pass/Skin Detail/Community, máy chủ hay pháp lý. Các điểm nối ở những khu vực đó được ghi bên dưới.

## Từng phát hiện

“Xong” chỉ phần được giao và kiểm chứng bằng unit/widget test; không thay cho kiểm thử native/thiết bị. “Một phần” ghi rõ phần đã có và công việc còn cần chủ đường dẫn khác hoặc điều kiện bên ngoài.

| ID | Trạng thái | Kết quả và phần còn lại |
|---|---|---|
| AR-001 | Xong | Giữ và kiểm chứng cooldown theo tài khoản 30 giây → 10 phút, ưu tiên Retry-After, không thử ngay sau 429/Cloudflare/5xx/timeout; auth limiter dùng chung, semaphore hai re-auth, lệch lịch poll; giữ token đã xoay khi bootstrap thất bại. |
| AR-002 | Một phần | Đăng xuất mặc định xóa wishlist/preset/lịch sử; checkbox giữ dữ liệu là lựa chọn rõ ràng; thêm “Xóa dữ liệu cục bộ”. Dọn lịch sử qua API domain và xóa trực tiếp để lỗi đĩa không bị nuốt. Cần chủ tài liệu cập nhật privacy/SUMMARY/ARCHITECTURE; không sửa tài liệu pháp lý bị cấm. |
| AR-003 | Xong | Ghi `app.pendingWipe` trước, xóa cuối; startup hoàn tất lựa chọn giữ/xóa rồi sweep secure keys/prefs/files mồ côi, trước khi mở UI. Chặn ghi muộn trong cùng cache/prefs, đợi ghi file đang chạy khi xóa; đăng nhập lại mở chặn. Test lỗi xóa lịch sử giữ marker để lần khởi động sau tiếp tục. |
| AR-004 | Một phần | local_auth trước đọc/reveal/copy/điền nhanh; danh sách ghi chú chỉ dùng containsKey, không đọc giải mã hàng loạt. Đọc ghi chú được chọn và chỉ điền trên hai host đăng nhập Riot qua HTTPS. Clipboard hết hạn 45 giây nếu chưa bị thay; Android sensitive flag + FLAG_SECURE; khóa/xóa nội dung sheet khi mất foreground. Cần QA native iOS/Android; iOS clipboard chưa dùng localOnly và chưa có native snapshot mask; tài liệu mô hình mật khẩu cần chủ tài liệu cập nhật. |
| AR-005 | Xong | Host cooldown có jitter cho Cloudflare/429/5xx lặp lại; fail-fast khi host đang bị chặn, không nhân inline retry với provider retry khi bị challenge. |
| AR-006 | Một phần | PvpApi có hạn chót 45 giây cho cả session, queue, HTTP/interceptor và retry; CancelToken chấm dứt cả khi đang chờ session. Offline không inline retry. Banner dữ liệu cũ và keepAlive sau thành công thuộc UI/domain bị cấm sửa. |
| AR-007 | Xong | Job trả true sau lỗi tạm thời thay vì yêu cầu OS retry; budget chung 25 giây, timeout theo phần còn lại, bỏ account/job bước tiếp khi hết ngân sách; hủy unique task khi hết tài khoản và đăng ký lại sau login. |
| AR-008 | Xong | Bảy reset kế tiếp, ID ổn định riêng từng slot/tài khoản, dựa trên expiresAt + một phút; bản lưu cũ được tiến theo cadence 24 giờ. Lập lại trong foreground và background; công tắc tắt hủy đủ bảy ID. Đổi ngôn ngữ thông báo còn thuộc I18N W-BG. |
| AR-009 | Xong | Commit nền đã ghim host cộng đồng và bỏ communityBaseUrl từ remote config; bổ sung HTTPS/port 443/no-userinfo vào token egress guard, tắt redirect cho yêu cầu mang token (kể cả caller bật lại), không theo redirect bootstrap. Test chặn HTTP/custom port và host lạ. |
| AR-010 | Một phần | Schema, flags, UA, clientVersion và dữ liệu cấu hình đều kiểm tra; bỏ trường host và giữ cấu hình tốt gần nhất. Remote URL vẫn rỗng. Chưa bật hosting/chữ ký Ed25519 vì chưa có nguồn/khoá phát hành được chỉ định; cần chủ dự án cấu hình trước khi bật cập nhật từ xa. |
| AR-011 | Một phần | Kiểm tra định dạng clientVersion/build, giữ giá trị tốt, refresh khi bị từ chối và background khi quá 24 giờ. Fallback từ clientVersion của GLZ session chưa nối vì dữ liệu session nằm trong domain. |
| AR-012 | Xong | Nội dung đã lưu được trả ngay; refresh nền single-flight theo locale và invalidate provider khi có cập nhật. Meta riêng endpoint, không tải lại tất cả khi một endpoint lỗi; endpoint lỗi chờ sáu giờ. Test cache trả trước network đang bị treo và chỉ endpoint lỗi được thử lại. |
| AR-013 | Bỏ qua | Thuộc WP-DOMAIN theo bàn giao: fallback dữ liệu cũ khi cần đăng nhập/bảo trì. |
| AR-014 | Bỏ qua | Thuộc WP-DOMAIN: RR chỉ tài khoản của mình, LRU người khác. |
| AR-015 | Bỏ qua | Thuộc WP-DOMAIN: khóa match-details theo viewer và match ID. |
| AR-016 | Bỏ qua | Thuộc WP-DOMAIN: cache tên có TTL và lưu dưới names; WP-CORE chỉ dọn được cả đường dẫn tên cũ/mới. |
| AR-017 | Một phần | PvpApi có CancelToken cho heavy reads; limiter hủy hàng chờ, ưu tiên mutation; hủy trong lúc chờ session có test. Chủ provider domain cần nối token với ref.onDispose; không sửa đường dẫn bị cấm. |
| AR-018 | Xong | Đăng xuất gọi communityAuth.forget để quên cả phiên trong RAM, sau đó backstop xóa secure key; test đồng ý cộng đồng vẫn được xóa cùng tài khoản. |
| AR-019 | Xong | Khóa `acct.<id>.lock.reauth`, jitter trước xác nhận ownership, xóa khóa legacy khi wipe; account không tồn tại/needsLogin dừng trước lock, đọc prefs lỗi fail-closed. Lock vẫn advisory, chưa phải CAS nguyên tử. |
| AR-020 | Xong | Queue Completer cho đọc-sửa-ghi, chung giữa repository dùng cùng Prefs; đọc list từ đĩa trước sửa, bump revision. Test nhiều patch/upsert/remove không mất cập nhật. SharedPreferences không cung cấp CAS giữa isolate; xem rủi ro bên dưới. |
| AR-021 | Xong | Giữ allow-list XMPP trong commit nền; host nhận credential được kiểm tra, không nhận host tùy ý từ cấu hình. |
| AR-022 | Xong | resetOnError:false; read lỗi được ghi loại lỗi và trả null, write chỉ retry một lần rồi throw, không deleteAll để hồi phục; delete lỗi throw để giữ pendingWipe. Không log key/value. |
| AR-023 | Xong | Giữ allow-list WebView theo commit nền, chỉ HTTPS main-frame host được phép; điền nhanh kiểm tra URL lại sau khi xác thực thiết bị. |
| AR-024 | Xong | Android visibility private; tiêu đề/nội dung ẩn Riot ID, kể cả tên có dấu/có khoảng trắng; tiêu đề LFG chung. Reauth payload `/login?reauth=...`; legacy LFG dùng kênh lfg và công tắc riêng. |
| AR-025 | Một phần | NotificationService bỏ payload tài khoản đã xóa cả live tap/cold start. Helper `accountLinkDecision` có open/unknownAccount/deferLogin và test. Cần Claude nối snackbar và hàng chờ khi `/login` trong router/app bị cấm sửa. |
| AR-026 | Xong | Helper friendsLiveConsentProvider theo `acct.<id>.home.friendsLive`; không chuyển đồng ý toàn app thành đồng ý của tài khoản mới; mất account thì không cấp quyền. Nối vào Home do Claude làm theo yêu cầu helper-only. |
| AR-027 | Bỏ qua | Mức thấp, iOS backup chưa xác minh. Chưa đổi vị trí cache/backup của RR hoặc prefs; cần quyết định backup và kiểm chứng trên macOS. Android backup exclusion nền vẫn giữ nguyên. |
| AR-028 | Bỏ qua | Mức thấp, audit yêu cầu đo trước. Không có phép đo native first-frame do giới hạn không chạy thiết bị; không đổi thứ tự bootstrap/i18n/dọn dữ liệu khi chưa đo. Dọn dữ liệu phải hoàn tất trước UI để tránh xóa login mới. |
| AR-029 | Một phần | Temp file riêng, queue ghi theo key, bắt FormatException/UTF-8 hỏng, tombstone và drain trước xóa có test. keepAlive, prune trận và debounce tên thuộc domain chưa sửa. |
| AR-030 | Xong | File nối riêng từng writer/isolate, flush chỉ dòng mới; load gộp và sắp thời gian, giới hạn ring, dọn writer cũ; không overwrite log isolate khác. Test hai writer và tag Unicode. |
| AR-031 | Một phần | Múi giờ fallback UTC. ui_locales/status/content locale và mô hình region/country còn thuộc I18N/COUNTRIES, không đổi fallback shard khi chưa có mô hình mới. |
| AR-032 | Xong | Bỏ background processing iOS chưa dùng; Cài đặt có hướng dẫn tiết kiệm pin có thể làm thông báo trễ, nút mở cài đặt thông báo hệ điều hành sẵn có. Native chưa build trên Mac. |
| AR-033 | Xong | Giữ ML Kit dịch trên thiết bị theo D1; không thêm cloud AI/LLM. |
| AR-034 | Xong | Kiểm chứng commit nền: kiểm tra PUUID trước lưu jar xoay; API invalidate thừa đã bỏ. |
| GL-25 | Một phần | Các phép toán ngày trong core/util/format dùng UTC theo thành phần lịch, test DST New York ngày 23/25 giờ. Các phép tương tự trong Home/domain/server status cần chủ đường dẫn xử lý. |
| GL-26 | Xong | Fallback UTC, bỏ copy giờ Việt Nam. Nhãn Cài đặt dựa trên expiresAt của cửa hàng tài khoản hiện tại đã lưu, không gọi mạng; chưa biết giờ thì hướng dẫn mở cửa hàng. |
| GL-37 | Xong | Scrub tag Riot Unicode, test chữ Nhật và không lộ Riot ID trong log ghép. |
| GL-39 | Bỏ qua | Widget ping thuộc Social ngoài ownership WP-CORE; cần chủ UI xác định ngưỡng tuyệt đối hoặc theo shard. |
| PR-05 | Xong trong gói | Thêm bốn kênh và công tắc battlePass/rank/community/lfg, mặc định tắt, lưu settings và hủy theo category khi tắt. LFG caller cũ được chuyển kênh ở service. Chỉ thông báo cục bộ theo D2; nguồn Battle Pass/Rank nằm hàng đợi §4 của HANDOFF. |
| PR-06 | Xong | Bảy reminder được lập ở foreground/background; tắt/xóa tài khoản hủy hết; giờ Cài đặt từ expiresAt đã lưu. |
| PR-29 | Xong | NotificationService có clock tiêm được; scheduleAt không dùng now cứng trong test. Wishlist gate theo expiresAt lần kiểm tra thành công; dữ liệu legacy/thiếu expiresAt dùng UTC day fallback vì chưa có giờ được xác minh. |

## File chính và điểm nối

- Auth/network nền: `session_manager.dart`, `reauth_client.dart`, `reauth_cooldown.dart`, `auth_traffic.dart`, `rate_limiter.dart`, `retry_policy.dart`, `pvp_api.dart`, `bootstrap_client.dart`, `login_screen.dart`, cấu hình/clientVersion/XMPP trong các commit trước.
- Tài khoản/lưu trữ: `account_providers.dart`, `account_repository.dart`, `account_maintenance.dart`, `local_data.dart`, `sign_out_dialog.dart`, `login_note.dart`, `login_note_sheet.dart`, `secret_access.dart`, `secure_store.dart`, `json_file_cache.dart`.
- Nội dung/nhật ký/ngày: `core/content/content_repository.dart`, `core/logging/session_log.dart`, `core/util/format.dart`.
- Nền/thông báo: `core/background/**`, `core/notifications/notification_service.dart`, `features/wishlist/background/**`, `features/store/providers/store_reset_reminder.dart`, `store_reset_reminder_host.dart`.
- Adapter tối thiểu ngoài danh sách ownership: `lib/main.dart` gọi maintenance trước UI; `core/settings/app_settings.dart` lưu công tắc; section tài khoản/settings strings nối checkbox và xóa dữ liệu; `core/l10n` chứa chuỗi; Android Activity/manifest/theme và iOS Info.plist đáp ứng local_auth. `pubspec.yaml/lock` chỉ thêm local_auth và các gói nền tảng bắt buộc. Không sửa dependency khác có chủ ý.
- Test cộng đồng duy nhất sửa là `test/features/community/ui/consent_test.dart`: giả lập nơi lưu lịch sử khi test đăng xuất, không đổi hợp đồng cộng đồng. Các test mới kiểm tra hành vi bảo vệ bí mật, không chỉ “không ném lỗi”.
- Claude/router: gọi `accountLinkDecision` trước điều hướng; defer trong `/login`, cảnh báo khi unknownAccount. Notification payload đã được lọc nhưng external/router links cần nối helper.
- Claude/Home: thay đồng ý toàn app bằng `friendsLiveConsentProvider(puuid)`; không tự migrate đồng ý cũ thành đồng ý mới.
- WP-DOMAIN: nối CancelToken với ref.onDispose cho heavy reads; không keepAlive lỗi; hook recorder StoreHistoryStore vào `BackgroundWishlistCheckEnv.storefront` khi module PR-03 được gộp. Hiện background không có StoreHistoryStore để gọi; sign-out đã xóa toàn bộ `acct/<id>/store_history`.

## Rủi ro và giới hạn kiểm chứng

1. SharedPreferences là khóa advisory/queue theo isolate, không có compare-and-set liên isolate. Có revision + đọc fresh + kiểm tra account trước ghi, nhưng không tuyên bố loại bỏ mọi race UI/background. Tombstone của JsonFileCache/Prefs cũng theo instance/isolate; startup sweeper là lớp dọn lại sau crash/ghi muộn. Domain RR còn có thể nhận update đang chạy sau xóa: chủ domain cần chặn persistence tương ứng, nhất là khi gộp recorder mới.
2. `.timeout` dừng việc chờ, không tự hủy silent re-auth đang chạy. PvpApi hủy HTTP/hàng chờ và chấm dứt lệnh; tác vụ xoay cookie có thể hoàn tất trong nền để giữ tính nhất quán. OS có thể giết background engine giữa chừng; cookies.prev và pendingWipe hỗ trợ hồi phục, chưa thử kill trên thiết bị.
3. iOS giới hạn khoảng 64 pending local notifications. Bảy reminder × mười tài khoản có thể vượt giới hạn, chưa tính wishlist/Chợ Đêm. Cần QA và quyết định phân bổ ưu tiên trước phát hành nhiều tài khoản; lịch dùng cadence 24 giờ dự kiến cho sáu ngày sau, được lập lại khi có expiresAt mới.
4. local_auth fail-closed nếu thiết bị chưa có khóa hoặc plugin không dùng được. Cần Mac build/QA Face ID, PIN, app switcher và clipboard; Android FLAG_SECURE/sensitive extras chỉ được kiểm tra mã, chưa build/chạy native. iOS clipboard vẫn có thể đồng bộ qua Universal Clipboard trước khi timer 45 giây xóa.
5. SecureStore.readAllKeys cho startup sweeper dùng readAll của plugin nên có thể đọc giải mã dữ liệu nội bộ; UI picker đã dùng containsKey để tránh việc đó. Không trả/log các giá trị từ sweeper. Storage unavailable vẫn phải thử lại lần khởi động sau.
6. Các kênh mới không tạo dữ liệu giả hay push; nhắc Battle Pass/Rank thực tế, i18n notification rebuild, legal copy, backup exclusion iOS, đo cold start và UI ngoài ownership cần nối ở gói tương ứng.

## Kiểm tra cuối

Đã chạy qua PowerShell với `$env:Path="D:\Dev\Flutter\3.47.5\flutter\bin;$env:Path"`:

- `flutter pub get`: đã giải quyết local_auth và ghi lockfile trong commit WIP đầu; các lượt sau dùng `--no-pub` để kiểm tra chính dependency đã khóa.
- `flutter analyze --no-pub`: **No issues found!**, 0 errors/warnings/info (lượt cuối 4,0 giây).
- `flutter test --no-pub --reporter expanded`: **+2201 All tests passed!**, không skip/không tắt lint/test; lượt cuối khoảng 66 giây.
- `dart format lib test tool`, rồi `dart format --output=none --set-exit-if-changed lib test tool`: **643 files, 0 changed**, exit 0.
- `git diff --check`: sạch; diff từ merge `de5024e` không có đường dẫn mã nguồn bị cấm trong HANDOFF.
- Không build Android/iOS và không kiểm tra trực quan/kill engine trên thiết bị, đúng giới hạn của gói. Không chạy kiểm tra server vì không sửa server.
- Các log xác minh cuối được giữ cục bộ, bị gitignore: `.wp-core-analyze.log`, `.wp-core-full-final.log`, `.wp-core-format.log`.

## Commit

Commit nền WP-CORE đã tiếp nhận và kiểm chứng:

- `6a1187b`: Định hình lưu lượng Riot (AR-001/005/006/017).
- `43ecebf`: Lệch poll, secure storage không xóa im lặng, kiểm tra clientVersion.
- `5b7abb3`: Config an toàn, ghim host token, allow-list XMPP/WebView.
- `79b4399`: WIP dọn tài khoản/cache trước khi bị ngắt.

Commit trong đợt tiếp quản:

- `de5024e`: Gộp `claude/jolly-hawking-23o2j8`, không có xung đột.
- `9b2cc52`: WIP nối dọn tài khoản, bảo vệ ghi chú, lịch bảy ngày và cache nội dung nền.
- `7a1c708`: WIP chặn ghi muộn, hoàn thiện nhắc nền và test bảo vệ tài khoản.
- `e907d4c`: Kiểm tra khóa không giải mã ghi chú hàng loạt, ẩn đầy đủ tên Riot và test tương thích đăng xuất.
- `68968a2`: Chặn native redirect cho yêu cầu mang token Riot, kể cả caller bật followRedirects.
- Commit chứa chính báo cáo này là bước cuối; hash được thông báo ở phản hồi bàn giao để tránh tự tham chiếu hash trong nội dung commit.
