# Hoàn thiện ValHub — nhật ký triển khai Codex

Checkpoint mới nhất 03/10: [Nhãn hiển thị / xác nhận ngôn ngữ, build 4014](I18N_VIEW_CUTOVER_2026-10-03.md).

Đã chuyển nhãn enum/widget/callback sang resources hiện tại và thêm xác nhận
ngôn ngữ cho screen reader sau khi lưu. Windows hai lượt và Mac đạt **4.299
tests**, analyzer 0; backend **867 tests**. APK 4014 qua 10 public flows;
Mobile MCP/cache/log kiểm tra chuyển đủ **bốn tài khoản thật**, đúng dữ liệu
cửa hàng từng tài khoản và trả active ban đầu. iOS 4014 build trên Mac,
**chưa ký/chưa nghiệm thu iPhone**. Cutover còn **129 refs / 762 literals /
52 structural**, chỉ VI UI ships; chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Nội dung / locale / RR loading, build 4013](I18N_CONTENT_CUTOVER_2026-10-03.md).

Đã tách nhãn nội dung khỏi model, thêm lựa chọn tên vật phẩm theo app hoặc 18
locale và giữ lựa chọn cũ; sửa thứ tự ghi cài đặt và race đọc RR. Windows hai
lượt và Mac đạt **4.292 tests**, analyzer 0; backend **867 tests**. APK 4013 qua
10 public flows, đã nâng cấp emulator và giữ bốn tài khoản/wishlist/cài đặt;
Mobile MCP/cache/log thật được kiểm tra. iOS 4013 build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **195 refs / 762 literals / 52 structural**;
chỉ VI ships, chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Cộng đồng / cách ly tài khoản, build 4012](COMMUNITY_ACCOUNT_ISOLATION_2026-10-03.md).

Windows hai lượt và Mac đạt **4.265 tests**, analyzer 0; backend **867 tests**.
APK 4012 qua 10 public-flow cases, đã nâng cấp emulator có cửa sổ, giữ đủ
bốn tài khoản, wishlist và cài đặt. iOS 4012 đã build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **262 refs / 762 literal hits / 52 structural
members**, chỉ VI ships; chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Callback / cách ly tài khoản, build 4011](I18N_CALLBACK_ISOLATION_2026-10-03.md).
Đã sửa lỗi phản hồi tổ đội đến muộn và xóa mã của tài khoản khác khi chuyển;
Windows hai lượt và Mac đạt **4.246 tests**, analyzer 0. APK **4011** đã cài
trên emulator, 10 public flows đạt; bốn tài khoản/active/wishlist/cài đặt giữ
nguyên. iOS 4011 build trên Mac, **chưa ký/chưa test iPhone**. Cutover còn
**307 refs / 762 literal hits**, chưa nghiệm thu toàn bộ.


Checkpoint trước 03/10: [Render-time cutover, build 4010](I18N_RENDER_CUTOVER_2026-10-03.md).
Đã chuyển thêm **175 refs** (514 → **339**). Windows hai lượt và Mac đạt
**4.238 tests**, analyzer 0; backend 867, codemod 37, Android native 6 và public
flows 10 đạt. APK **4010** đã được kiểm tra trên emulator; bốn tài khoản/active/wishlist/
settings giữ nguyên. iOS 4010 build trên Mac nhưng **chưa ký/chưa test iPhone**.
Cutover còn đỏ, chưa nghiệm thu toàn bộ; chỉ tiếng Việt được phát hành.


Checkpoint 03/10: [Review Gemini và tích hợp ValHub](VALHUB_INTEGRATION_2026-10-03.md). Đã sửa lỗi
Gemini và gộp locale nền/bộ chọn/thông báo. Windows/Mac **4.236 tests**,
analyzer 0; backend 867, native 6, public-flow 10 cases đạt. APK/iOS không ký
**4009** đã build; bốn tài khoản, active, wishlist và settings giữ sau nâng APK.
Cutover còn **514 refs / 52 structural members**, chưa nghiệm thu toàn app.
Các số 02/10 bên dưới là checkpoint lịch sử.

Yêu cầu của chủ dự án: hoàn thiện toàn bộ yêu cầu để Claude kiểm tra sau khi hết giới hạn. Nhánh tích hợp: `ndh0408/codex-complete`; worktree `C:/Users/Admin/orca/workspaces/ValVN/codex-complete`. Đây là tiến độ đang triển khai, **chưa phải nghiệm thu toàn bộ**.

Checkpoint mới nhất: [Locale nền / bộ chọn / CI local 02/10](I18N_BACKGROUND_2026-10-02.md).
Windows hai lượt và Mac toàn bộ đều đạt **4.232 tests**, analyzer 0 issues;
backend 867 tests, 6 Android plugin tests, 10 public flows và APK/iOS không ký
**4007** đạt. Locale nền, lời thông báo, cập nhật kênh và nhắc cửa hàng đã nối
generated resources; bộ chọn UI chỉ cung cấp ngôn ngữ đã phát hành. Cutover còn
**514 production references / 52 structural members / 762 literal hits**, vẫn đỏ.
Chủ dự án đã tự login thành công; MCP/cache/log xác nhận dữ liệu thật sau login.
Wishlist add/restart/remove và chuyển ba tài khoản qua lại đạt, đã trả trạng thái
ban đầu. Thẻ tạm lưu qua Riot và giữ sau restart; chưa xác nhận trả lại thẻ cũ
vì phiên test đã thay đổi, cũng chưa đối chiếu trong VALORANT PC.

Checkpoint trước: [Runtime locale / CI local 02/10](I18N_RUNTIME_2026-10-02.md).
Root app đã đọc provider locale/format và lưu snapshot theo thứ tự, giữ riêng
lựa chọn tên vật phẩm tiếng Anh. Windows đạt **4.201 tests** ở cả hai lượt,
Mac đạt **25 test liên quan** và build iOS **4006** không ký; analyzer 0 issues
ở cả hai máy. APK **4006** đã đạt 10 public-flow cases và cài trên emulator có
cửa sổ; rà chỉ đọc hai tài khoản đạt. W5 vẫn partial; chỉ vi được phát hành,
tác vụ nền còn chuỗi cũ.

Checkpoint trước: [Final gap audit / CI local 02/10](FINAL_GAP_AUDIT_2026-10-02.md).
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
| Mở emulator cho chủ dự án xem | Pixel đã mở lại ở port 5554; QA riêng 5582 | Kiểm chứng bản gộp 4009 đang thực hiện; không xóa phiên owner |
| Commit, push và gộp để người khác thấy code mới nhất | UI/kết nối, Settings `a4afe4e`, hook `9850063`, tài nguyên dùng chung `04e6288` đã push integration và fast-forward/push nhánh mặc định; Cộng đồng tiếp sau | Tiếp tục commit các phase còn thiếu; đối chiếu `git log -1`, không coi merge là nghiệm thu toàn dự án |
| Ẩn bảng nguồn dữ liệu | Đã bỏ card Giới thiệu và có test | Đã kiểm tra About bản cài trong lượt read-only; giữ pháp lý/giấy phép cần thiết |
| Cộng đồng rõ ràng, bộ lọc không bị cắt | Tab gọn và một scope selector; banner ngắn, lời trống theo scope/ngôn ngữ/consent, FAB contrast đạt; test 360dp/chữ 200% | Bản code 4006 đã rà read-only; tiếp tục các màn còn lại |
| Đăng bài, thích, bình luận, share | Luồng đăng/thích/bình luận/khoe shop đã có; thêm share từng bài ở feed/detail, native Android chooser + Back đạt | Link hiện mở bằng VanHub đã cài; HTTPS/trang web/đa thiết bị và server ghi thật chưa nghiệm thu |
| Tài khoản chữ dễ đọc, đủ tên/vùng/rank | Đã chia dòng, wrap Riot ID/vùng và đưa nút phụ xuống dưới; lượt 02/10 Settings/switcher đọc đủ metadata hai tài khoản hiện có | Đổi ba tài khoản qua lại đạt trên 4007; reauth và bản gộp còn cần kiểm tra |
| Trang bị cập nhật game | Đã xác nhận giá trị sau lưu và thêm refresh identity ở sảnh | Đối chiếu trực tiếp VALORANT PC đang mở; chưa có bằng chứng live |
| Đổi tên ValHub theo yêu cầu mới | UI/resources/native/pháp lý đã đồng bộ ValHub, giữ ID tương thích | Quốc tế hóa UI đầy đủ còn thiếu |
| Kiểm tra mọi chức năng | Full Flutter/backend/tool + plugin/public-route QA đã chạy | Rà real-account/offline/reauth, Social/LFG đa thiết bị, iOS và Doze; không suy ra từ unit tests |
| Tải và lưu dữ liệu ngay sau login | Warmup card/level/rank và store/wallet/missions/collection dùng cùng cache; bounded login, reauth, region, logout và retry có test | Owner manual login đạt; MCP/cache/log xác nhận metadata và ví thật trên 4007; chưa nghiệm thu mọi lỗi/reauth/logout |
| Hook failed lặp lại | [02/10: bridge ngoài thư mục tạm và launcher riêng Orca](WINDOWS_HOOK_FIX_2026-10-02.md), hai shortcut đã sao lưu/cập nhật; 14 tests và security pattern hook thật đạt, giữ cảnh báo/quyết định/exit | Đã kiểm tra launcher khi bỏ arg0 khỏi môi trường; còn xác nhận đóng/mở lại Orca thật. Mở trực tiếp executable không dùng private PATH; không tắt security hook |

## Checklist nghiệm thu

- [x] Gộp CORE/DOMAIN/COPY/SRV và giữ bốn báo cáo riêng.
- [x] RV-01: xóa/giữ RR, match ledger, store history đúng đường dẫn; dọn RAM; chặn ghi muộn; startup sweep.
- [x] RV-02: quyền Riot chat của Home theo từng tài khoản, không kế thừa đồng ý toàn app.
- [ ] RV-03 toàn bộ: recorder nền, RR/cache tên, cancellation, deferred links, release errors, LFG join, logout/consent và ẩn/chặn cục bộ đã nối; còn nghiệm thu rộng cùng quốc tế hóa/thiết bị.
- [ ] RV-05 toàn bộ: privacy và Community disclosure đã đồng bộ, Markdown sinh từ Dart; vẫn cần rà lời toàn cầu khi cutover.
- [x] I18N W1 nền công cụ: resolved extractor, ARB, manifest, parity, kiểm tra chạy lại; danh sách 52 member cần xử lý cấu trúc được giữ rõ.
- [ ] I18N W2–W4: Migrate UI bằng công cụ có sẵn; global hiện còn **195 references / 52 structural members**. Chưa tách hết domain, chuyển hết async call site và cutover.
- [ ] I18N W5 toàn bộ: runtime/device/upgrade pin, picker cho shipped locales, snapshot nền và channel/reminder resources đã nối và test; contentLocale 18 tag/legacy migration/headless đã nối; ui_locales đã nối; announcement sau lưu đã test qua platform channel; còn locale status, pruning và nghiệm thu TalkBack/VoiceOver thực tế.
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
