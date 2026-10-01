# VanHub: kiểm tra tính năng và thay đổi theo phản hồi người dùng

Đây là báo cáo của đợt tiếp tục sau bàn giao Claude và các ảnh phản hồi ngày 01/10/2026. Đọc cùng [đối chiếu 37 mục gốc](QA_2026-10-01.md) và [checklist toàn dự án](COMPLETION_STATUS.md). Test xanh chỉ chứng minh phạm vi đã chạy; không đóng các tính năng quốc tế hóa hoặc nghiệm thu thiết bị còn thiếu.

## Thay đổi theo phản hồi

| Yêu cầu | Thay đổi và nơi cần review |
|---|---|
| Tên VanHub | Tên hiển thị Android/iOS, màn chào mừng, Giới thiệu, chia sẻ, thông báo, chuỗi UI và pháp lý đều dùng VanHub. Giữ appId, khóa lưu dữ liệu, scheme và URL repository để bản cập nhật tiếp tục dùng tài khoản/lịch sử hiện có. |
| Ẩn bảng nguồn dữ liệu | Bỏ thẻ ba dòng nguồn/ghi công ở Giới thiệu. Các trang pháp lý và giấy phép thư viện vẫn mở được. Không thay đổi nguồn lấy dữ liệu hay lời mô tả quyền riêng tư. |
| Cộng đồng khó hiểu, chip bị cắt | Tab nội dung có gạch dưới, một selector thể hiện phạm vi thực tế; các nước/vùng/quốc tế nằm trong sheet cuộn được. Ngôn ngữ chỉ hiện khi quốc tế. Trạng thái trống nhỏ hơn và có nút Quốc tế để xem thêm. |
| Tài khoản chữ mờ, khu vực bị cắt | Riot ID, trạng thái/cấp, khu vực và rank có dòng riêng; tên/khu vực được xuống dòng. Nút phụ trong Cài đặt nằm dưới thông tin. Đăng nhập lại dùng nút có tooltip thay badge chiếm chiều ngang. Thanh chọn tài khoản dùng hướng start cho RTL. |
| Đọc chữ toàn app | Tăng độ tương phản chữ phụ dark theme; chỉnh cỡ và khoảng cách chữ nhỏ dùng chung. Kiểm tra tương phản trên các mặt thẻ, chiều rộng 320 dp/chữ 200% và cả hai hướng chữ cho bộ lọc phụ. |
| Đổi thẻ chưa hiện trong game | Sau khi xác nhận loadout đã lưu, refresh identity của chính người chơi trong party nếu game ở MENUS. Áp dụng cho thẻ, danh hiệu, viền cấp, ẩn cấp và incognito, kể cả composite/no-op. Không refresh party cho đổi skin/phụ kiện/spray hoặc khi đang trong trận. |
| Rà các trang bị khác | Không coi Version tăng là đủ: giá trị trang bị phải khớp thao tác được yêu cầu. Test cover skin, card, title, buddy, spray, presets/composite, rollback, unknown fields và phiên đăng nhập hết hạn trong bộ domain/controller hiện có. |
| Sau đăng nhập / chuyển tài khoản | Root preload card, cấp độ từ account XP và rank; tài khoản đang dùng được tải store, wallet, missions, entitlements. Dùng chung request/cache với các màn, không trộn tài khoản; login chờ identity tối đa 2 giây, request chậm tiếp tục. Các tài khoản khác tải metadata theo nhịp 500 ms. Reauth làm mới cache; đổi vùng kết nối cũng refetch. |
| Quốc gia | [Picker chung](COUNTRY_PICKER_2026-10-01.md): tìm tên địa phương/Anh/alias CLDR/ISO2/ISO3, ưu tiên prefix, xử lý IME, không ghi đè quốc gia tài khoản khi chọn cộng đồng, tất cả quốc gia vẫn dùng được khi API hoạt động lỗi. |

Refresh party tham chiếu [tài liệu endpoint của maintainer](https://valapidocs.techchrism.me/endpoint/refresh-player-identity). Test HTTP xác nhận GLZ POST, đường dẫn party/member của tài khoản đang sửa, không có body và có headers phiên. Refresh lỗi không biến một loadout đã lưu thành thất bại. Chưa có bằng chứng so sánh trực tiếp giao diện VALORANT đang mở trên PC với thao tác đổi thẻ mới, nên không cam kết mọi màn trong game cập nhật tức thời.

## Phạm vi hồi quy toàn app

Chạy toàn bộ `flutter test --coverage`, không chỉ history hoặc thẻ người chơi. Các nhóm được chạy gồm:

| Nhóm | Hành vi được kiểm thử bằng unit/widget/in-process integration |
|---|---|
| Riot và tài khoản | Auth/session/cookie, host và headers, retry/rate limit, chuyển tài khoản, trạng thái hết hạn, ghi chú đăng nhập, xóa/giữ dữ liệu, chặn ghi muộn sau logout. |
| Home và điều hướng | Các tab, route/deep link lạnh và đang mở, defer login, dữ liệu lỗi/offline, consent bạn bè theo tài khoản, shell/adaptive. |
| Cửa hàng và wishlist | Ví/giá, storefront, Chợ Đêm/bundle/phụ kiện, nội dung skin, lịch sử, lựa chọn mua, wishlist/background alerts và chia sẻ. |
| Bộ sưu tập | Đồ sở hữu, trang bị vũ khí/card/title/buddy/spray, preset, xác nhận lưu, lỗi/rollback và phân lập tài khoản. |
| Hồ sơ và trận | Rank/RR, lịch sử/ledger, chi tiết trận, thống kê agent/map, tính lên hạng, phiên trận và tổ đội. |
| Battle Pass | XP/pace, nhiệm vụ, phần thưởng, nguồn dữ liệu và thông báo cấp/mùa. |
| Cộng đồng/LFG | Feed/comment/review, phạm vi/quốc gia/ngôn ngữ, consent, dịch, moderation, ẩn/chặn cục bộ, join bằng mã authoritative, expired session và logout. |
| Cài đặt/pháp lý/thông báo | Tùy chọn, theme, quyền, lịch và budget, dữ liệu tạm, báo lỗi, About, Markdown khớp văn bản trong app. |
| Máy chủ | SQLite thật, auth/epoch, permissions/rate limits, posts/reviews/LFG/reports/media, erasure, migrations/quota, retention/sweeper và vận hành được cover trong 34 test files. |

Sửa thêm test sweeper phụ thuộc ngày chạy: gắn ảnh vào bài khi phiên fake-clock còn hiệu lực, rồi mới chuyển giờ để kiểm tra retention. Assert HTTP 200 để không vô tình kiểm thử một bài chưa tạo được.

## Bằng chứng đợt này

| Kiểm tra | Kết quả |
|---|---|
| Flutter toàn bộ | **4.143 passed**, không skip bài lỗi |
| Coverage dòng trong phạm vi được đo | **35.041 / 38.890 = 90.10%**. 403 source files; không thay thế native/E2E |
| Flutter analyze | **0 issues** |
| Backend | **867 passed / 34 test files**, typecheck/build đạt |
| Công cụ l10n | **35 passed**, analyze 0; extract/parity byte-stable |
| ARB | **0 errors, 0 warnings** |
| Android plugin integration | **5 passed** trên emulator 5582/API 35 |

Native harness dùng controller thật để nhập query, tránh trộn TestTextInput với IME Android; chờ ghi preference qua platform hoàn tất và layout sau khi cuộn trước khi chọn. Đã xem screenshot bàn phím Gboard thật mở trong picker; các test IME composing/commit nằm trong widget suite. Không diễn giải bài này thành kiểm chứng mọi bàn phím/OEM hoặc gõ phím vật lý E2E.

Các logs cục bộ:

- `.vanhub-all-tests-layout.log`, `coverage/lcov.info`: Flutter toàn bộ; `.vanhub-warmup-final.log`: 13 test warmup và nhóm Loadout/Battle Pass.
- `.vanhub-analyze-layout.log`: analyzer app.
- `server/community/.vanhub-tests.log`, `.vanhub-typecheck.log`, `.vanhub-build.log`: backend.
- `tool/l10n_codemod/.vanhub-*`: 35 tool tests, analyzer, extract/parity checks.
- `.vanhub-arb.log`: ARB validator.
- `.vanhub-android-native.log`: plugin integration trên emulator QA riêng.
- `.vanhub-layout-release-build.log`, `.vanhub-root-modal-release-smoke.log`: APK và public-flow native QA.

Giữ emulator có cửa sổ `emulator-5580` cho người dùng; chạy automation trên AVD mới `VanHub_QA_20261001`, `emulator-5582`, userdata/cache riêng. Sau ngắt phiên, bản sao userdata/cache/key của cửa sổ 5580 được giữ trong `dist/emulator-visible` để hai emulator không tranh file dùng chung; dữ liệu gốc vẫn ở `dist/emulator-data`. Không clear/uninstall tài khoản đang dùng trên 5580. Build release ký debug phục vụ kiểm tra; chưa là bản upload store.

## Tải sẵn dữ liệu tài khoản

`AccountDataWarmupHost` nằm trên router, chạy lúc mở app, chuyển tài khoản và resume. Các request đọc dùng lại Riverpod family theo PUUID; giữ listener đến khi request xong rồi dùng TTL/offline cache của domain. Ba nguồn identity chạy song song, store/wallet/contracts tiếp theo và entitlements dùng pool hiện có. Không đọc Social/Community trước consent, không tự trang bị hay sửa game. Tài khoản đã logout, cần đăng nhập lại hoặc chưa xác định vùng không được warmup.

Login mới dùng lại preload đã bắt đầu từ root; reauth chủ động invalidates dữ liệu cũ. Account XP, loadout, contracts, premium ownership và daily ticket chỉ keepAlive sau khi có kết quả hợp lệ hoặc offline copy: lỗi không bị giữ 5–10 phút, mở lại màn sau khi có mạng sẽ thử lại. Rank trong danh sách dùng chung `mmrProvider` với Profile và chờ content cùng MMR, tránh request trùng hoặc bỏ lỡ rank khi content chưa tải xong. Các provider riêng account theo dõi cả region để đổi kết nối không dùng RAM cache của shard trước.

13 test mới kiểm tra persistence card/level/rank mà không mở màn, request/cache dùng chung, lỗi một phần, tài khoản expired/missing/unknown region, chuyển tài khoản, reauth, login mới không duplicate, đổi region, logout khi đang tải, root/stagger, giới hạn chờ login và phục hồi loadout/missions khi mở màn sau preload offline. Đây là test bằng dữ liệu giả; chưa tự đăng nhập/đăng xuất hay thay trang bị tài khoản thật trên emulator.

Sau native/test/analyze, chạy `flutter build apk --release` với bước pub/bootstrap để sinh registrant release mới. Không chạy Flutter tooling khác đồng thời với Gradle build: registrant test có thể chứa IntegrationTestPlugin trong khi classpath release loại dev plugin. Bản build đã tạo lại registrant đúng, không sửa tay file sinh tự động.

## Lỗi hook của công cụ

Phát hiện `bash` của phiên Codex trỏ `C:/Windows/System32/bash.exe` (WSL) và lỗi `execvpe(/bin/bash) ... No such file or directory`, exit 1. Sửa bằng shim Git Bash/sh trong thư mục runtime arg0 riêng phiên, giữ command/nội dung security hooks và trả đúng exit code. Kiểm tra shell, security reminder và metrics hook đạt exit 0. Không sửa source app để che lỗi hook; shim không đưa lên Git và chỉ áp dụng phiên runtime hiện tại.

## Claude cần kiểm tra tiếp

Các mục chưa thể đóng bằng bộ test hiện tại: 18 bản dịch UI/cutover l10n, RTL/CJK toàn màn, country onboarding/provenance/refresh định kỳ, list-detail/adaptive toàn app, unread/activity Community, HTTPS App/Universal Links/domain, moderation toàn cầu, iOS native QA và cấu hình vận hành/release thật. Danh sách cụ thể và ID giữ trong [COMPLETION_STATUS.md](COMPLETION_STATUS.md), [QA_2026-10-01.md](QA_2026-10-01.md) và các audit gốc.

Đợt này không thay kết quả unit/widget bằng lời khẳng định E2E Riot/Community production. Cần kiểm tra trực tiếp đổi card/title/viền cấp ở sảnh và trong trận, loadout/game restart, store từng shard, đăng nhập lại, party/LFG đa thiết bị, background khi Doze/reboot và native sharing trên thiết bị thật.

## Phản hồi bố cục Cộng đồng mới nhất

Đã thay ba nút nội dung lớn bằng tab có gạch dưới; màn chính chỉ còn một selector thể hiện đúng quốc gia/khu vực/quốc tế mà server đang áp dụng. Các lựa chọn riêng nước, vùng khác và quốc tế nằm trong bottom sheet cuộn được, giữ preference theo từng section. Bộ lọc ngôn ngữ chỉ hiện khi phạm vi thực tế là quốc tế. Trạng thái trống dùng icon nhỏ, giảm khoảng cách và có hành động chuyển sang Quốc tế; thông tin xác minh dài chỉ hiện cho người chưa tham gia, vẫn có disclosure ở consent.

Full suite 4.143 tests và analyzer 0 issues đạt sau thay bố cục. 58 bài scope/applied-scope/consent kiểm tra query, nhớ lựa chọn, fallback phía server, không lộ nội dung cũ, chọn nước/ngôn ngữ, không tự đăng nhập/consent và sheet ở 360dp chữ 200%. Đã sửa fixture asset đọc CLDR trước fake clock để việc mở sheet hai bước không phụ thuộc IO thật trong widget test.

Lượt read-only trên emulator tài khoản đã đi qua Home, Store, Community, Collection, Profile, Battle Pass, đổi thẻ (chỉ xem), About và Settings. Ba tài khoản có cấp, rank, avatar mà không phải mở từng Profile. Không tự đăng nhập, đổi tài khoản, đồng ý consent, đăng bài, mua hay trang bị. Logcat không có fatal/unhandled trong phạm vi lượt chạy. Screenshot/XML tài khoản giữ riêng tại `dist/review/private-account-ui`; không đưa lên Git.

APK cuối sau chỉnh căn lề/màu viền: SHA-256 `FD9F07B344C44017B903661FBBE133808B20DAA364CD9E2CB43A91F81872554D`, 119.2 MB, build release thành công, apksigner xác minh đạt, chứng thư Android Debug. Đã cài đè thành công trên 5580, xem ảnh Bảng tin và mở/đóng sheet scope mà không đổi lựa chọn/tài khoản. Metadata/account smoke trước đó và visual scope trên APK cuối có artifact riêng; không coi chúng là giao dịch thật hoặc nghiệm thu mọi màn.

Sửa thêm qua kiểm tra trực quan: scope/country/language/account sheets dùng root Navigator, country page ở cửa sổ thấp cũng mở trên root, để thanh tab không che lựa chọn. 156 kiểm thử Accounts/Geo/Scope/Consent đạt sau sửa; analyze 0 issues. APK cuối chạy đủ 10 public-flow cases trên 5582. Trên 5580 đã xác nhận sheet có lựa chọn và không chứa thanh tab trong cây accessibility, đóng lại mà không đổi scope/tài khoản. Cửa sổ emulator tiếp tục mở ở Bảng tin.
