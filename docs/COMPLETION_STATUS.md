# Hoàn thiện VanHub — nhật ký triển khai Codex

Yêu cầu của chủ dự án: hoàn thiện toàn bộ yêu cầu để Claude kiểm tra sau khi hết giới hạn. Nhánh tích hợp: `ndh0408/codex-complete`; worktree `C:/Users/Admin/orca/workspaces/ValVN/codex-complete`. Đây là tiến độ đang triển khai, **chưa phải nghiệm thu toàn bộ**.

Checkpoint mới nhất: [Final gap audit / CI local 02/10](FINAL_GAP_AUDIT_2026-10-02.md).
**4.197 Flutter tests đạt trên Windows và Mac**, Windows device locale `en` cũng
đạt 4.197 với fallback vi; analyzer 0 issues. Backend 867 tests, Docker native
backup/restore smoke và 10 public-flow cases APK **4005** đạt. Bản 4005 đã cài trên
emulator có cửa sổ; không thay đổi tài khoản thật. Global cutover còn **560
production references / 52 structural members / 762 literal hits** (chủ yếu
pháp lý). Build iOS không ký trên Mac đạt: Runner.app 82,7 MB, IPA kiểm tra đã
đóng gói và manifest có trong app. Chưa test native trên iPhone/ký store. GitHub-hosted CI bị
khóa billing; CI local không giải quyết khóa tài khoản GitHub. Các đợt dưới đây
là checkpoint lịch sử. Giữ ML Kit miễn phí đã có theo xác nhận của chủ dự án;
không thêm AI/API trả phí.

Giữ nhánh chính và các báo cáo bàn giao cũ để đối chiếu. Theo yêu cầu mới của chủ dự án, gộp và push nhánh mặc định GitHub để mọi người đọc code mới nhất; chưa deploy/publish store. Không thêm chatbot/LLM hay dịch vụ AI vào ứng dụng; số liệu sản phẩm phải có nguồn thật. Báo cáo `docs/CODEX_REVIEW.md` và `docs/handoffs/` ghi trạng thái trước các sửa đổi tích hợp, không dùng chúng làm tiến độ hiện tại.

Đợt mới nhất: [Cộng đồng/bố cục/chia sẻ bài](COMMUNITY_FEATURES_2026-10-02.md), **4.195 Flutter tests đạt**, analyzer 0 issues, 1 Android native share integration và 10 public-flow cases trên APK cuối code 4003 đạt; bản mới đã cài trên emulator có cửa sổ. Global cutover còn **1.762 production references**, không đánh dấu xong quốc tế hóa. [Tài nguyên dùng chung](I18N_SHARED_2026-10-02.md) là checkpoint 4.184 tests; [bản sửa hook 02/10](WINDOWS_HOOK_FIX_2026-10-02.md) lưu bridge ngoài thư mục tạm, 14 tests đạt. Checkpoint trước: [Cài đặt](I18N_SETTINGS_2026-10-01.md), 4.178 tests; [đăng nhập/kết nối](COUNTRY_CONNECTION_2026-10-01.md), 4.176 tests; [VanHub và kiểm thử toàn tính năng](VANHUB_REVIEW_2026-10-01.md), 4.143 Flutter / 867 backend / 35 tool tests. Đối chiếu đủ 37 mục bàn giao xem [QA_2026-10-01.md](QA_2026-10-01.md); các báo cáo cũ là checkpoint, không thay nghiệm thu tổng thể.

## Yêu cầu trực tiếp của chủ dự án

Các trạng thái dưới đây tách triển khai/kiểm thử khỏi nghiệm thu toàn app. Chủ dự án nhắc lại ngày 01/10 rằng chưa đầy đủ; không kết thúc công việc ở bản đổi tên hoặc một nhóm bug.

| Yêu cầu | Trạng thái hiện tại | Việc phải làm tiếp |
|---|---|---|
| Đọc việc Claude giao và làm hết yêu cầu | Đã tích hợp bốn WP, giữ report và đối chiếu đủ 37 mục | Đóng các mục I18N/COUNTRIES/DEVICES/Community còn mở phía dưới; chưa nghiệm thu tổng thể |
| Mở emulator cho chủ dự án xem | Cửa sổ Pixel 5580 đã cài APK code 4005; lượt 02/10 đọc hai tài khoản hiện có và đủ metadata | Không suy ra ba tài khoản của checkpoint trước còn trong trạng thái emulator mới; tiếp tục rà các luồng còn lại, QA riêng 5582 |
| Commit, push và gộp để người khác thấy code mới nhất | UI/kết nối, Settings `a4afe4e`, hook `9850063`, tài nguyên dùng chung `04e6288` đã push integration và fast-forward/push nhánh mặc định; Cộng đồng tiếp sau | Tiếp tục commit các phase còn thiếu; đối chiếu `git log -1`, không coi merge là nghiệm thu toàn dự án |
| Ẩn bảng nguồn dữ liệu | Đã bỏ card Giới thiệu và có test | Đã kiểm tra About bản cài trong lượt read-only; giữ pháp lý/giấy phép cần thiết |
| Cộng đồng rõ ràng, bộ lọc không bị cắt | Tab gọn và một scope selector; banner ngắn, lời trống theo scope/ngôn ngữ/consent, FAB contrast đạt; test 360dp/chữ 200% | Bản code 4005 đã rà read-only; tiếp tục các màn còn lại |
| Đăng bài, thích, bình luận, share | Luồng đăng/thích/bình luận/khoe shop đã có; thêm share từng bài ở feed/detail, native Android chooser + Back đạt | Link hiện mở bằng VanHub đã cài; HTTPS/trang web/đa thiết bị và server ghi thật chưa nghiệm thu |
| Tài khoản chữ dễ đọc, đủ tên/vùng/rank | Đã chia dòng, wrap Riot ID/vùng và đưa nút phụ xuống dưới; lượt 02/10 Settings/switcher đọc đủ metadata hai tài khoản hiện có | Còn kiểm tra chủ động chuyển/reauth; ba tài khoản là bằng chứng checkpoint trước |
| Trang bị cập nhật game | Đã xác nhận giá trị sau lưu và thêm refresh identity ở sảnh | Đối chiếu trực tiếp VALORANT PC đang mở; chưa có bằng chứng live |
| Đổi tên VanHub | Tên hiển thị native/UI/pháp lý đã đổi, giữ ID và dữ liệu cập nhật | Quốc tế hóa UI đầy đủ còn thiếu |
| Kiểm tra mọi chức năng | Full Flutter/backend/tool + plugin/public-route QA đã chạy | Rà real-account/offline/reauth, Social/LFG đa thiết bị, iOS và Doze; không suy ra từ unit tests |
| Tải và lưu dữ liệu ngay sau login | Warmup card/level/rank và store/wallet/missions/collection dùng cùng cache; bounded login, reauth, region, logout và retry có test | Đã xác nhận ba tài khoản đủ metadata trên bản cài; chưa tự đăng nhập/đăng xuất tài khoản thật |
| Hook failed lặp lại | [02/10: bridge ngoài thư mục tạm và launcher riêng Orca](WINDOWS_HOOK_FIX_2026-10-02.md), hai shortcut đã sao lưu/cập nhật; 14 tests và security pattern hook thật đạt, giữ cảnh báo/quyết định/exit | Đã kiểm tra launcher khi bỏ arg0 khỏi môi trường; còn xác nhận đóng/mở lại Orca thật. Mở trực tiếp executable không dùng private PATH; không tắt security hook |

## Checklist nghiệm thu

- [x] Gộp CORE/DOMAIN/COPY/SRV và giữ bốn báo cáo riêng.
- [x] RV-01: xóa/giữ RR, match ledger, store history đúng đường dẫn; dọn RAM; chặn ghi muộn; startup sweep.
- [x] RV-02: quyền Riot chat của Home theo từng tài khoản, không kế thừa đồng ý toàn app.
- [ ] RV-03 toàn bộ: recorder nền, RR/cache tên, cancellation, deferred links, release errors, LFG join, logout/consent và ẩn/chặn cục bộ đã nối; còn nghiệm thu rộng cùng quốc tế hóa/thiết bị.
- [ ] RV-05 toàn bộ: privacy và Community disclosure đã đồng bộ, Markdown sinh từ Dart; vẫn cần rà lời toàn cầu khi cutover.
- [x] I18N W1 nền công cụ: resolved extractor, ARB, manifest, parity, kiểm tra chạy lại; danh sách 52 member cần xử lý cấu trúc được giữ rõ.
- [ ] I18N W2–W4: Migrate UI bằng công cụ có sẵn, giảm thêm 1.202 references; global còn **560 references / 52 structural members**. Chưa tách hết domain, chuyển hết async call site và cutover.
- [ ] I18N W5: UI language picker, device default/upgrade pin, contentLocale/ui_locales/status, isolate thông báo.
- [ ] I18N W6: đủ 18 bản dịch UI, plural/select, glossary và fallback/status gates.
- [ ] I18N W7: RTL toàn ứng dụng, font CJK, pseudo locale và stale-string tests.
- [ ] COUNTRIES P0–P3 toàn bộ: 250 mã, tên 18 locale, auto/manual/fail closed, chọn quốc gia/giá VP/picker chung đã nối. [Đợt kết nối](COUNTRY_CONNECTION_2026-10-01.md) thêm refresh 7 ngày, mismatch/ack, login geo outage, GET XP validation/retry và root sheet; còn onboarding, provenance/trạng thái đầy đủ, remote geo và nối quốc tế hóa.
- [ ] DEVICES/A11y toàn bộ: breakpoints/rail/hinge/safe area, header theo text scale, nút đỏ đậm/chữ trắng và reduced video motion đã sửa; còn list/detail và semantic/RTL toàn màn hình.
- [ ] Notifications toàn bộ: Rank/Battle Pass dùng dữ liệu thật, kênh LFG cục bộ và category switches đã nối; lịch tối đa 60, migration 7→5 ngày; còn nguồn badge/activity Community và nghiệm thu native.
- [ ] External links/sharing toàn bộ: custom scheme/cold/warm start/defer login/account switching đã nối; share bài feed/detail đã thêm và native Android đạt. HTTPS App/Universal Links, domain association và trang người chưa cài còn thiếu.
- [ ] Server toàn bộ: native decoder, atomic idempotency, watchdog và quota counters đã làm; còn review moderation 18 ngôn ngữ/CPU text filter và các mục audit khác chưa đóng.
- [ ] Native privacy toàn bộ: iOS local-only clipboard/expiration và che snapshot đã viết; iOS backup policy/build và native QA còn thiếu.
- [x] Checkpoint hiện tại: Flutter analyze 0, toàn bộ Flutter tests xanh; server tests/typecheck/build xanh; ARB/tool checks xanh.
- [x] Android APK release build + xác minh chữ ký cho bản kiểm tra.
- [x] Native plugin smoke trên Android 15/API 35: country preference/keyboard, Keystore và 60 lịch thông báo.
- [x] APK release trên emulator: 10 public-flow cases; lỗi deep link lúc đang login được tái hiện, sửa và chạy lại đạt.
- [x] iOS release build không ký trên Mac và đóng gói IPA kiểm tra; manifest API đã có trong bundle.
- [ ] QA native/visual toàn luồng, iPhone thật, ký và nghiệm thu iOS store.
- [ ] Release/CI/store metadata/signing/domain/off-site/alert destination thật do chủ dự án cấu hình.
- [ ] Báo cáo nghiệm thu cuối từng ID, commit, test và giới hạn sau khi toàn bộ yêu cầu thực sự đạt.

## Bằng chứng checkpoint QA ban đầu 01/10/2026

Các số dưới đây thuộc checkpoint `6c2261f`; kết quả đợt tiếp theo xem báo cáo bộ chọn dùng chung phía trên.

| Kiểm tra | Kết quả |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test --reporter expanded` | **4.109 passed** sau sửa deep link, không bỏ qua bài lỗi |
| Android integration tests, plugin thật | **3 passed**; dữ liệu tổng hợp, không đăng nhập Riot |
| Android APK release public-flow smoke | **10 passed**; cold/warm links, login/cancel, pháp lý, landscape chữ 200%; logcat không có fatal/unhandled exception trong phạm vi chạy |
| `dart test` trong `tool/l10n_codemod` | **34 passed** |
| Tool `dart analyze` | No issues found |
| ARB validator | 0 errors, 0 warnings |
| `extract --check`, `parity --check` | Byte-stable; 1.609 members, 1.751 message cơ học, 52 structural members |
| `verify --ci` | **Exit 1 đúng dự kiến**: còn 2.066 production references, 762 literal tiếng Việt; cutover chưa đạt |
| Backend native SQLite/Vitest | **867 passed / 34 files** |
| Backend TypeScript typecheck/build | Passed |
| `npm audit --omit=dev` | 0 reported vulnerabilities tại checkpoint |
| Docker Linux image build | Passed |
| Docker smoke: read-only root, không network ngoài, tmpfs riêng | Decoder orientation/EXIF, watchdog, snapshot, age encryption/decryption, restore/erasure replay, retention và failure-path passed |
| Compose config | Valid; không chạy stack production |
| Android build | Passed, APK 118,9 MB, debug signing fallback được kiểm tra bằng apksigner |
| `git diff --check` | Passed |

Logs cục bộ nằm ở `.native-analyze.log`, `.native-regression-tests.log`, `.android-native-tests.log`, `.release-smoke.log`, `.android-build.log`, `.apk-signature.log`, `.arb-check.log`, các log trong `tool/l10n_codemod/` và `server/community/`. Log/ảnh QA/APK không đưa vào Git; kết quả/commands và benchmark được ghi vào báo cáo.

APK sau sửa deep link để review: `dist/review/ValVN-codex-20261001.apk`. SHA-256: `48BB358E314B44C45E3CCA94ABE88889D9E0058A9833FD4CD39F055600CD9379`. Đây là APK build ở chế độ release nhưng ký bằng **Android Debug**, không phải artifact để upload store. Đã cài và chạy trên emulator Android 15/API 35, `emulator-5580`, dữ liệu QA riêng. Chưa có môi trường Mac để build iOS và chưa có phiên Riot thật để kiểm chứng signed-in E2E.

## Các hành vi đã sửa và điểm cần Claude kiểm tra

1. **Privacy/history:** RR lưu ở `history/keep/<id>`, match/store ở `history/acct/<id>`; wipe xóa file và cache RAM đúng store. Keep history là lựa chọn tường minh; pending wipe/startup sweep và fresh-account guards chặn dữ liệu bị ghi lại sau logout. Wishlist nền ghi storefront đã tải, không thêm request để tạo lịch sử.
2. **Consent/session:** Home friends consent theo PUUID; Community consent có version/time. Quên Community session hủy cache RAM và local secure key trước, logout server best effort. LFG lấy mã mới từ POST join trước khi gọi Riot; không phụ thuộc mã trên danh sách.
3. **Local Community controls:** ẩn/chặn riêng cho tài khoản trên thiết bị; feed/comment/review/LFG/detail/preview cùng lọc. Có nơi bỏ ẩn và disclosure rằng người bị ẩn vẫn xem được nội dung công khai. Không hứa server-side peer block.
4. **Notifications:** baseline Rank/Battle Pass không gây thông báo giả khi lần đầu import. Rank theo act/tier, pass theo cấp/ngày kết thúc thật; dữ liệu có sẵn phát event, không gọi Riot thêm chỉ để thông báo. Schedule tuần tự, 60 mục tối đa, thay lịch cũ được và lỗi pending probe không xóa lịch cũ.
5. **Geography:** bảng alpha-3/alpha-2 đủ 249 ISO + XK có đánh dấu non-ISO; tên/collation CLDR cho 18 locale. Chỉ ghi available khi có nguồn đã xác minh; không gán mọi nước là được hỗ trợ. Quốc gia không chọn Riot host. Local preference > account country > device locale cho giá VP; Community/LFG giữ detected region khi người dùng override kết nối thủ công.
6. **Adaptive:** rail từ 600 dp; shell không mất navigation stack khi đổi kích thước; chọn pane lớn hơn khi hinge che màn hình; safe area/cap/header theo cửa sổ và text scale. Home vẫn giữ bố cục riêng. Country picker cuộn cả header và list trong RTL landscape + 200% text + keyboard; tìm tên có/không dấu, tiếng Anh, ISO2/3.
7. **Server:** commit `b559cf1` đóng native image decode/re-encode và DB/create-response transaction; 0011 quota counters có trigger cho insert/delete/resize/transfer/cascade/rollback. Watchdog optional profile + executable hook, không có Docker socket. Access logs dùng route patterns. Xem `server/community/docs/performance.md`: timings dữ liệu tổng hợp, không quảng cáo tải production. Skin aggregate table/index removal vẫn cần phép đo riêng.
8. **I18N:** không bật 18 UI locale bằng bản sao tiếng Việt/tiếng Anh. `rewrite` dry-run có phạm vi tường minh, xử lý view-context/const/nested calls/tearoffs; giữ default/enum/map/no-context/async captures để xử lý cấu trúc. `verify --ci` vẫn đỏ vì công việc thực sự còn. Country assets 18 locale không có nghĩa UI đã dịch đủ 18.

## Bước tiếp theo

Ưu tiên W2: chuyển enum/model/error/content fallback sang dữ liệu và render-time l10n, xử lý 52 member cấu trúc; áp dụng rewrite theo work package và sửa test harness, giữ parity Việt. Tiếp theo W4–W7 mới bật lựa chọn ngôn ngữ/bản dịch/RTL. Song song cần hoàn thiện COUNTRIES/DEVICES còn mở và CS moderation, sau đó nghiệm thu toàn luồng/native. Không đánh dấu hết chỉ vì build và unit tests đã xanh.
