# Review công việc Claude giao Codex — 01/10/2026

## Kết luận

**Bốn gói đã chốt phần việc trên từng nhánh và vượt qua test riêng, nhưng chưa tích hợp và chưa đáp ứng đầy đủ yêu cầu ứng dụng VALORANT toàn cầu của chủ dự án.** Không thể coi các báo cáo “hoàn tất WP” là “hoàn tất sản phẩm”. Có một lỗi xóa dữ liệu đã tái hiện, xung đột khi gộp và nhiều điểm nối chưa triển khai.

Review này đối chiếu yêu cầu gốc, prompt giao việc, báo cáo, Git và các điểm code liên quan; chạy lại phân tích/test từng nhánh. Không phải audit lại từng dòng của mọi thay đổi, không có bản đã gộp để kiểm thử tích hợp, không build/chạy native hoặc kiểm tra production trong lượt này.

## Nguồn đã đối chiếu

- Lịch sử Claude của dự án ValVN: các yêu cầu về giao diện/chức năng hơn Daily Val và ValBuddy, dữ liệu thật, hỗ trợ mọi quốc gia/thiết bị, commit GitHub; prompt nâng cấp toàn cầu ngày 30/09, gồm 37 mục và tiêu chí nghiệm thu; yêu cầu nội dung dùng ngôn ngữ người chơi VALORANT; yêu cầu giao việc còn lại cho Codex.
- Prompt tạo bốn worktree ngày 30/09 lúc 17:37–17:38 giờ Việt Nam: xác nhận Claude thực sự giao bốn gói, yêu cầu tiếp tục WIP, đọc HANDOFF/audit, test, commit và báo cáo; cấm push/gộp chính/deploy/chạy thiết bị trong các gói.
- `docs/HANDOFF.md`, `CLAUDE.md`, `docs/GLOBAL_AUDIT.md`, các báo cáo Accounts/Product/Global/Community, tài liệu I18N/COUNTRIES/DEVICES và bốn `HANDOFF_REPORT.md`.
- Nhánh chính hiện tại: `claude/jolly-hawking-23o2j8`, HEAD `e6ddc35`, cũng là tip origin được lưu cục bộ. Không fetch để xác minh trạng thái remote mới hơn.

## Bốn gói đã giao và trạng thái xác minh

| Gói | Claude giao | Tip được review | Kiểm tra chạy lại |
|---|---|---|---|
| WP-CORE | Đăng nhập/reauth, mạng, tài khoản, xóa dữ liệu, bảo vệ ghi chú, cache nội dung, nền và thông báo | `ndh0408/codex-wp-core` / `6646591` | `flutter analyze --no-pub`: 0 vấn đề; `flutter test --no-pub --reporter expanded`: 2.201 test đạt |
| WP-DOMAIN | Sửa số liệu, module Hiệu suất và sổ trận riêng, lịch sử cửa hàng, RR/cache tên/cách ly viewer, điểm cộng đồng cho thẻ skin | `ndh0408/codex-wp-domain` / `2c26eeb` | Analyze: 0 vấn đề; 2.133 test đạt |
| WP-COPY | Kiểm kê/sửa lời người chơi, VOICE, bỏ console, báo lỗi có lọc thông tin, lời pháp lý dễ đọc | `ndh0408/codex-wp-copy` / `fbc6edc` | Analyze: 0 vấn đề; 2.007 test đạt |
| WP-SRV | Gia cố auth/quyền/rate limit/media, skin votes/reviews, báo cáo, LFG, xóa/backup, CI và hợp đồng API | `ndh0408/codex-wp-srv` / `15c4151` | `npm test`: 847 test đạt; `npx tsc --noEmit`: exit 0 |

Bốn worktree sạch trước review. Mỗi nhánh đã nhận nền `e6ddc35`; tất cả có báo cáo đã commit. Các số test là test toàn nhánh, có nhiều test nền trùng nhau, **không cộng để coi là số test của sản phẩm đã gộp**. Format, build Docker, smoke vận hành và scan phụ thuộc ghi trong báo cáo bàn giao chưa được chạy lại trong lượt review này.

## Các phát hiện cần xử lý trước nghiệm thu tích hợp

### RV-01 — Cao: xóa dữ liệu đang dùng sai thư mục của lịch sử cửa hàng

Nguồn code:

- DOMAIN `lib/core/domain/economy/store_history.dart:317,332,342`: lưu `acct/<puuid>/store_history` trong `JsonFileCache.appSupport('history')`.
- CORE `lib/core/accounts/local_data.dart:41–46`: xóa lịch sử khi đăng xuất chỉ xóa `history/keep/<puuid>`; không xóa `history/acct/<puuid>/store_history`.
- CORE `lib/core/accounts/local_data.dart:61–67`: “Xóa dữ liệu cục bộ” xóa `keep` trong history, nhưng xóa `acct/<puuid>/store_history` bằng `_cache`, tức thư mục cache.
- CORE `AccountRepository` và startup sweeper cũng chỉ nhận file cache cho phần `acct/…`; chưa dọn thư mục `history/acct/…`.

**Đã tái hiện:** sao chép test startup maintenance hiện có sang `.dart_tool/codex_review/wipe_test.dart`, chỉ đổi nơi tạo/kiểm tra file store history từ cache sang history cho đúng hợp đồng DOMAIN. Chạy `flutter test --no-pub .dart_tool/codex_review/wipe_test.dart --reporter expanded`: 2 test đạt, 1 thất bại ở dòng 101, `Expected: false / Actual: true`. Marker đăng xuất đã hoàn tất nhưng lịch sử cửa hàng vẫn tồn tại.

Test gốc đạt vì fixture viết store history vào cache, khác nơi DOMAIN thực sự lưu. Đây là lỗi tích hợp xác minh được, không chỉ là suy đoán từ báo cáo.

Cần sửa: dùng chung store/provider và namespace thật; khi người dùng không giữ dữ liệu, xóa RR/match ledger/store history đúng tài khoản, phát thông báo thay đổi để UI không còn dữ liệu trong RAM. Khi giữ dữ liệu, giữ theo lựa chọn rõ ràng. Startup phải xử lý cùng chính sách, và cần test ghi muộn/UI-background để không hồi sinh dữ liệu sau xóa. Việc xóa trực tiếp cũng phải giữ pending marker nếu gặp lỗi đĩa.

### RV-02 — Cao: đồng ý xem bạn bè theo tài khoản chưa được nối vào Home

CORE có `lib/core/accounts/friends_consent.dart:8` với `friendsLiveConsentProvider(puuid)` và key theo tài khoản. Nhưng DOMAIN/Home vẫn đọc `homeFriendsConsentProvider` với key chung `f.home.friendsLive`:

- `lib/features/home/providers/home_layout_provider.dart:18,53`;
- `lib/features/home/providers/home_card_providers.dart:129`;
- `home_arrangement.dart`, `friends_home_card.dart`, `customize_home_sheet.dart`.

Gộp code tự động không thay các call site này. Cần nối cả đọc/ghi/hộp hỏi/ẩn thẻ và kiểm tra đổi từ tài khoản A sang B không kế thừa quyền kết nối Riot chat. Helper mới dùng bool còn UI cũ dùng ba trạng thái chưa hỏi/đồng ý/từ chối, nên phải xử lý hành vi hỏi lại có chủ ý.

### RV-03 — Trung bình: thiếu các điểm nối chức năng giữa gói

| Điểm nối | Hiện trạng | Việc cần hoàn thiện |
|---|---|---|
| Lịch sử cửa hàng trong nền, PR-03 | DOMAIN ghi lượt tải trực tiếp; CORE chưa gọi StoreHistoryStore sau storefront nền | Gọi recorder từ kết quả live đã có, kiểm tra tài khoản vẫn tồn tại, giữ budget/công tắc; không thêm poll |
| Xóa lịch sử RR, PR-08 | Có helper/provider trong DOMAIN, chưa có nút riêng ở Cài đặt | Nối xác nhận và hành động; không tự backfill ngay sau xóa |
| Xóa dữ liệu tạm/cache tên, AR-016 | DOMAIN giữ tên trong file và bộ nhớ; nút COPY chủ yếu gọi CacheService.clear và xóa log | Gọi NameResolver.clear hoặc invalidate phù hợp; kiểm tra tên không hiện lại từ RAM/kết quả cũ |
| Hủy heavy read, AR-017 | CORE hỗ trợ CancelToken; DOMAIN chưa truyền cancelToken từ provider | Nối ref.onDispose với token, kiểm tra đổi tài khoản/rời màn không giữ hàng chờ không cần thiết |
| Deep link tài khoản, AR-025 | Có helper accountLinkDecision; router/app chưa gọi | Xử lý tài khoản đã xóa và giữ link trong lúc đang đăng nhập |
| Khung lỗi release, CP-13 | COPY chỉ bàn giao yêu cầu; chưa có ErrorWidget.builder/bộ bắt lỗi chung | Nối main/app, hiện lời thân thiện, chỉ ghi nội bộ dữ liệu đã lọc |
| Luồng LFG mới, CS-15 | Server join trả partyCode; client vẫn gọi Riot bằng mã lấy từ danh sách rồi mới gọi join | Đổi thứ tự và parser client, test quyền/trạng thái; phát hành client trước khi tắt LFG_CODE_IN_LIST |
| Đăng xuất/đồng ý cộng đồng, CS-04/34 | Server có logout và consent version; client chưa nối đầy đủ | Nối thu hồi phiên/version/re-prompt, block/mute và luồng moderation được giao sau |

### RV-04 — Trung bình: có xung đột code khi gộp

Kiểm tra bằng `git merge-tree --write-tree --name-only` trên các cặp nhánh, không thay checkout hay refs:

- CORE + COPY: xung đột `account_strings.dart`, `notification_strings.dart`, `settings_strings.dart`.
- DOMAIN + COPY: xung đột `home_strings.dart`.
- Mọi cặp: xung đột add/add `HANDOFF_REPORT.md`.
- `profile_strings.dart`, `ios/Runner/Info.plist` và một số test có thay đổi chồng nhau nhưng Git gộp tự động trong phép kiểm tra này; vẫn cần review hành vi/nội dung.

Cần giữ logic/member mới của CORE/DOMAIN cùng giọng văn COPY, tránh chọn nguyên một phía làm mất chức năng. Chuyển bốn báo cáo về tên/đường dẫn riêng khi tích hợp. Phép kiểm tra từng cặp chưa chứng minh cả bốn gộp tuần tự và chạy đúng.

### RV-05 — Trung bình: nội dung/chính sách và tài liệu tiến độ chưa khớp hành vi mới

COPY `privacy_policy.dart:386–390` vẫn nói Wishlist được giữ sau đăng xuất. CORE đã chuyển sang xóa mặc định, có checkbox giữ dữ liệu. CORE và DOMAIN cũng bổ sung ghi chú đăng nhập/lịch sử cần mô tả đúng; SERVER có retention/erasure ledger/backup mới cần chủ tài liệu rà lại.

`docs/PROGRESS.md` trên nền vẫn ghi 960 test và trạng thái ngày 29/09; không phản ánh các gói hiện tại. Cần cập nhật ARCHITECTURE/PROGRESS/SUMMARY/API và lời xác nhận theo code đã tích hợp, sinh lại Markdown pháp lý và kiểm tra parity. Đây là đối chiếu tính nhất quán code/tài liệu, không kết luận tuân thủ pháp luật.

### RV-06 — Các giới hạn còn mở phải có người nhận việc

- CORE: iOS clipboard chưa localOnly/chưa che snapshot; bảy nhắc cửa hàng × mười tài khoản = 70 lịch, có thể vượt giới hạn iOS khoảng 64 đã nêu trong báo cáo; khóa/queue SharedPreferences chưa bảo đảm nguyên tử liên isolate; chưa QA kill engine/native/local_auth.
- SERVER: CS-08 chưa decode/re-encode hoàn chỉnh; CS-18 parser ảnh còn chạy trên event loop; CS-21 còn khoảng trống crash giữa lưu nội dung và lưu idempotency; CS-20 kiểm duyệt chưa native review; CS-31 chưa watchdog/alert; CS-32 chưa benchmark/materialize.
- CS-24 xác minh rank/region từ Riot chưa làm vì thiếu response thật; những trường này chưa được coi là dữ liệu đã xác minh. Không dùng làm đặc quyền, cần hiển thị nguồn đúng.
- CS-12 đã có mã/runbook, chưa cấu hình đích backup ngoài host, remote retention và lưu ledger mới nhất; CS-30 workflow có code nhưng chưa chạy trên GitHub/Trivy trong lượt bàn giao.
- GL-39 ngưỡng ping vẫn còn comment theo người chơi Việt Nam tại `party_widgets.dart:494–505`. CORE nói ngoài ownership, HANDOFF không chỉ định rõ gói sửa Social này. Cần gắn người nhận, chọn ngưỡng tuyệt đối có giải thích hoặc theo shard.

## Yêu cầu gốc có được giao đầy đủ không?

**Bản kế hoạch bao phủ phần lớn yêu cầu, nhưng mới giao triển khai bốn gói.** HANDOFF §4 dành các phần bên dưới cho đợt sau; chưa có kết quả triển khai của các gói đó. Yêu cầu “giao những việc còn lại” chưa được thực hiện hết chỉ bằng việc tạo bốn worktree này.

| Yêu cầu chủ dự án | Trạng thái hiện tại | Phần còn thiếu |
|---|---|---|
| Không AI chatbot/LLM, ưu tiên miễn phí | Quy tắc và gói hiện tại giữ đúng hướng; ML Kit trên thiết bị được giữ theo quyết định D1 | Tiếp tục giữ phạm vi; không suy diễn là phải bỏ dịch miễn phí đã được chấp nhận |
| Dữ liệu thật, analytics có nguồn | DOMAIN đã có module/test, ẩn clutch và giá Radianite chưa xác minh | Nối xóa/nền, kiểm tra payload thật; sổ trận chỉ từ chi tiết trận đã mở, không mặc nhiên có toàn bộ lịch sử |
| 18 ngôn ngữ, ngôn ngữ thiết bị, đổi ngôn ngữ | Chỉ nền W0 | W1–W7; app vẫn `Locale('vi')`, supportedLocales chỉ vi, kShippedLocales chỉ vi; chưa có picker/cutover/17 bản dịch/RTL-CJK QA |
| Mọi quốc gia, tách country/region/shard, tự động/thủ công | Có tài liệu COUNTRIES, chưa code | P0–P3; Account vẫn fallback `ap` khi region thiếu, chưa có regionMode/country model/picker/bộ lọc hỗ trợ |
| Giao diện đẹp, đầy đủ cả trang con, mọi thiết bị | Có nâng cấp nền/Home và widget test; các gói Codex không chạy thiết bị theo giới hạn được giao | DEVICES/A11y, rail/list-detail, chữ lớn/RTL/CJK/landscape/tablet/foldable toàn app và review hình thật; chưa có chứng cứ vượt hai app đối chiếu |
| Home cá nhân, không spam mạng | Có Home và DOMAIN sửa giữ dữ liệu/poll theo viewport | Đồng ý bạn bè theo tài khoản, phần layout/a11y và QA thực tế |
| Thông báo đủ nhóm và deep link đúng | CORE có kênh/công tắc, lịch reset | Nguồn thông báo Battle Pass/Rank, i18n nền, ngân sách lịch iOS, deep link ngoài app/chia sẻ/cold-warm start |
| Cộng đồng/LFG toàn cầu, bảo mật/quyền dữ liệu | Server đã gia cố nhiều; có hạn chế ghi rõ | Client join/logout/consent/block/mute; kiểm duyệt/ảnh/crash recovery/vận hành thật |
| Build/cài/test toàn bộ và commit GitHub | Bốn gói có commit local, chưa gộp/push theo prompt giao | Tích hợp, test lại, build Android/iOS, QA dữ liệu Riot thật, release signing/CI/store metadata và push sau review |
| Documentation phản ánh code | Có audit/HANDOFF/report theo nhánh | Cập nhật tài liệu sản phẩm chung sau tích hợp; không dùng trạng thái cũ để nghiệm thu |

## Thứ tự tiếp tục đề nghị

1. Tạo nơi tích hợp riêng, giải quyết xung đột và giữ đủ bốn báo cáo; sửa RV-01 và nối RV-02/RV-03. Test phải dùng các store thật cùng namespace, có đổi tài khoản/xóa/ghi muộn.
2. Đồng bộ giọng văn/chính sách/docs và khung lỗi, chạy analyze/test toàn bản tích hợp. Kết quả từng nhánh xanh chưa thay cho bước này.
3. Giao I18N W1–W7 và COUNTRIES P0–P3 theo dependency; hoàn thiện DEVICES/A11y và các call site Social/Community còn sót.
4. Hoàn thiện thông báo/deep link/client cộng đồng, test native/dữ liệu Riot thật và rà giao diện tất cả trang con trên ma trận thiết bị/ngôn ngữ.
5. Chốt các giới hạn server, chạy CI/scan/restore drill ngoài production, cấu hình vận hành và release signing; sau review mới push/deploy/phát hành.

Các bước cần thông tin/quyền từ chủ dự án vẫn gồm GitHub billing nếu còn bị khóa, Apple ID/thiết bị, DNS/Cloudflare và thông tin phát hành. Tình trạng các dịch vụ này chưa được xác minh lại trong lượt review.

## Bằng chứng cục bộ

- Báo cáo nguồn: `C:/Users/Admin/orca/workspaces/ValVN/codex-wp-{core,domain,copy,srv}/HANDOFF_REPORT.md`.
- Flutter: `.codex-review-analyze.log`, `.codex-review-tests.log` trong từng worktree CORE/DOMAIN/COPY.
- Server: `server/community/.codex-review-tests.log`, `.codex-review-tsc.log` trong worktree SRV.
- Tái hiện RV-01: CORE `.dart_tool/codex_review/wipe_test.dart`, `.codex-review-wipe.log`. Chỉ là fixture review cục bộ, không sửa test gốc hoặc thêm vào suite mặc định.
- Không sửa source, gộp nhánh chính, push hoặc deploy trong lượt review; chỉ thêm báo cáo này và các tệp kiểm chứng cục bộ bị ignore ở worktree.
