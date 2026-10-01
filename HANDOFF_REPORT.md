# Bàn giao WP-DOMAIN — ValVN

Ngày chốt: 01/10/2026. Worktree `codex-wp-domain`, nhánh
`ndh0408/codex-wp-domain`.

Đã merge `claude/jolly-hawking-23o2j8` bằng commit `a7ce278`; không có xung
đột nội dung. Giữ nền tảng i18n W0, Home và máy chủ v3. Đã đọc luật, công cụ,
phạm vi và checklist trong `docs/HANDOFF.md`, `CLAUDE.md`,
`docs/GLOBAL_AUDIT.md`, các audit PRODUCT/ACCOUNTS/GLOBAL, tài liệu thiết kế
và hợp đồng cộng đồng. Đã kiểm tra hai commit DOMAIN gốc, tiếp tục hai file
dở dang thay vì làm lại phần đã hoàn thành.

## Kết quả theo phát hiện

“Xong” bên dưới chỉ khẳng định phần được giao cho WP-DOMAIN. Điểm nối cần
thay đổi đường dẫn do gói khác sở hữu được liệt kê riêng, không xem là đã
tích hợp. Không thêm phụ thuộc, dịch vụ trả phí hoặc dữ liệu mẫu vào app.

| ID | Trạng thái | Kết quả / lý do |
|---|---|---|
| PR-01 | Xong | Module thuần `performance.dart`, sổ trận riêng tài khoản của mình, schema và khử trùng/tối đa 5.000 trận. Ghi từ chi tiết trận đã mở; màn Hồ sơ → Hiệu suất không tải hàng loạt P-14. Có đặc vụ, bản đồ, chế độ, tấn công/phòng thủ, xu hướng theo thời gian và bộ lọc 7/30 ngày/toàn bộ. Hiện nguồn “Lịch sử trên thiết bị, từ …”; ẩn tỉ lệ dưới 3 trận có dữ liệu phù hợp. Không tính/hiện clutch. |
| PR-02 | Xong | Giữ sửa của commit gốc: ACS = tổng score/tổng rounds; ADR có mẫu số của trận có damage; HS% theo tổng hits; K/D và first blood theo chế độ theo vòng. DM/TDM/Escalation không làm sai số theo vòng. Thêm ngưỡng mẫu riêng ADR/HS% trên màn Hiệu suất. |
| PR-03 | Xong phần DOMAIN; một phần tích hợp toàn app | Lịch sử tối đa 365 ngày UTC, schema, khóa file để hai bên ghi không mất ngày, không ghi bản ngoại tuyến hoặc cửa hàng rỗng. Lượt tải cũ không ghi đè giá mới. Tổng hợp lần/ngày, Chợ Đêm theo BonusOfferID, lần đầu/cuối, giá và mức giảm. Chi tiết skin có dòng lịch sử thật và xóa sau xác nhận. Đã nối lượt tải trực tiếp; lượt kiểm tra nền cần WP-CORE gọi helper (bên dưới). |
| PR-04 | Xong | Giữ `maxAffordableTogether` và test của commit gốc: số skin có thể mua cùng nhau dùng tổng giá, không cộng số món mua riêng lẻ. |
| PR-05 | Bỏ qua | Kênh/công tắc thông báo thuộc WP-CORE và quyết định push; không sửa phần sở hữu đó. |
| PR-06 | Bỏ qua | Lịch nhắc reset và nhãn Cài đặt thuộc WP-CORE. |
| PR-07 | Bỏ qua | Deep link ngoài app/chia sẻ nằm trong hàng đợi HANDOFF §4; đụng app/platform và xác minh miền. |
| PR-08 | Một phần theo phạm vi giao | RR chỉ ghi file cho tài khoản của mình, người khác dùng bộ nhớ có giới hạn. Có `deleteRrHistoryFor` và `deleteRrHistoryProvider` để Claude nối Cài đặt. Luồng đăng xuất/giữ dữ liệu và nội dung chính sách thuộc WP-CORE/WP-COPY. |
| PR-09 | Một phần | Điểm cộng đồng trên thẻ cửa hàng hằng ngày, Chợ Đêm và wishlist: gọi ẩn danh, gom tối đa 50 id/lượt, chia sẻ yêu cầu đang chạy, lưu 30 phút/tối đa 500 skin. Hạn dùng tính từ lượt tải gốc; lỗi không tạo điểm giả. Không hiện chi phí Radianite: ngữ nghĩa P-7 chưa được xác minh trên tài khoản thật. Catalog tiles không được giao trong phạm vi WP-DOMAIN. |
| PR-10 | Bỏ qua | Tương phản theme thuộc gói DEVICES/A11y. |
| PR-11 | Bỏ qua | Helper/nút semantics chung và kiểm tra thiết bị thuộc DEVICES/A11y. |
| PR-12 | Bỏ qua | Rail, shell và list-detail thuộc DEVICES, đường dẫn app/core UI không được sửa. |
| PR-13 | Bỏ qua | Codemod RTL toàn app thuộc DEVICES/I18N; các widget mới dùng bố cục theo hướng khi cần. |
| PR-14 | Một phần | Bổ sung test cho thay đổi DOMAIN: ledger/performance/filter/ngưỡng mẫu, lịch sử cửa hàng/xóa/đồng thời, fallback ngoại tuyến, cache tên/RR, đổi viewer, rating, polling viewport và điều hướng. Các khoảng trống thông báo/deep link/theme/semantics toàn app thuộc gói khác. |
| PR-15 | Xong phần DOMAIN | Giữ các hàm thuần của commit gốc cho tuần RR, form, tiến độ rank, scoreboard và lọc bản đồ. View Hiệu suất và phân bố hits dùng hàm thuần có test; widget chỉ định dạng/hiển thị. |
| PR-16 | Xong | Giữ glyph recent form; thêm check/cross/dash cho strip và từng vòng, marker đồng đội/đối thủ trong kill feed ngoài màu. Widget test khẳng định glyph và marker, không chỉ kiểm tra không crash. |
| PR-17 | Một phần có chủ đích | Hiện first deaths và K/D trong chi tiết trận, có test. Không suy diễn RR base/bonus/AFK penalty, movement hoặc ability metrics khi ý nghĩa chưa xác minh. |
| PR-18 | Một phần có chủ đích | 0 RR không có kết quả P-14 được tính riêng là chưa rõ kết quả, không tự coi là hòa. Home/Hồ sơ/RR theo ngày hiển thị số trận chưa rõ. Tỉ lệ thắng sau placements chưa đổi vì thiếu xác minh trên tài khoản thật. |
| PR-19 | Xong | Giữ helper/nhãn phạm vi chuỗi trận từ commit gốc; Home ghi rõ xếp hạng, Hồ sơ ghi rõ phạm vi đang lọc. |
| PR-20 | Bỏ qua | Đồng bộ sheet/page cộng đồng và chat nằm ngoài đường dẫn được giao. |
| PR-21 | Bỏ qua | Kích thước tap/toolbar/navbar chung thuộc DEVICES/A11y. |
| PR-22 | Bỏ qua | Tối ưu blur/countdown/intrinsic cần profiling; phần chung app/core UI nằm ngoài phạm vi, không dùng thiết bị theo yêu cầu. |
| PR-23 | Xong phần Home; một phần toàn phát hiện | Home LFG chỉ poll khi foreground/tab đang mở và thẻ trong viewport, chu kỳ 3 phút; wrapper Home giữ LFG 3 phút/trending 30 phút sau thành công. Có test offscreen→onscreen. LFG list/poster và live overlay thuộc community/live_game, chưa sửa. |
| PR-24 | Xong phần Home theo phương án audit cho phép | Ghi rõ trong HOME.md việc dùng bố cục hiện tại tối đa 8 thẻ để giữ geometry cho focus/scroll anchoring, presence vẫn đọc thẻ bật; status tái sử dụng `/settings/status`. Lazy list kèm deferred presence, rail và re-tap giao DEVICES. |
| PR-25 | Bỏ qua | Chuyển parse/encode sang isolate và append-only RR cần profiling trước; không tuyên bố đã xử lý giật khung hình chưa đo. |
| PR-26 | Xong | Giữ lọc bản đồ/form từ ledger của commit gốc: không dựng vòng lặp eager tải toàn bộ chi tiết chỉ để đếm/lọc. Màn Hiệu suất cũng không gọi matchDetails. |
| PR-27 | Bỏ qua | Helper motion chung và vòng đời video thuộc hàng đợi DEVICES; không mở rộng ngoài gói. |
| PR-28 | Bỏ qua | Semantics ảnh/header/account chip/chart chung thuộc DEVICES/A11y. |
| PR-29 | Bỏ qua | Múi giờ thông báo/check nền thuộc WP-CORE. Lịch sử cửa hàng dùng ngày UTC đúng yêu cầu giao gói, không giả định múi giờ Việt Nam. |
| PR-30 | Bỏ qua | HANDOFF §1 đã quyết định giữ ML Kit chạy trên máy; không đổi community translator/pubspec. |
| AR-013 | Xong | Economy, Loadout, Battle Pass dùng bản lưu khi lỗi mạng/cần đăng nhập/bảo trì; giữ dấu và thời điểm bản lưu; lỗi khác vẫn truyền lên. Home giữ thẻ có dữ liệu đã lưu khi cần đăng nhập lại, không lặp banner lỗi khi không có bản lưu. Có test allow-list từng loại lỗi. |
| AR-014 | Xong | Tài khoản của mình mới ghi RR file/backfill; người khác LRU 20 người × 200 hàng, không file. Bộ nhớ lịch sử của mình cũng giới hạn 20. Dọn RR file người khác từ phiên bản cũ, giữ tài khoản đang có và id có preferences `keep.*` của wishlist/preset. |
| AR-015 | Xong | Provider thực mang khóa `(viewer, matchId)`; adapter API cũ watch tài khoản đang chọn. Watch sự tồn tại/needsLogin của viewer, áp dụng ẩn danh theo viewer; lỗi không được giữ 10 phút. Test đổi tài khoản từ lỗi đăng nhập sang tải cùng trận thành công. |
| AR-016 | Xong phần tên; điểm nối xóa chung còn giao CORE | Tên chuyển từ prefs sang `cache/names`, tối đa 1.000, retention 30 ngày, migration/prune, debounce và viết tuần tự. Không đọc được file vẫn gọi name-service. Xóa khi tài khoản cuối bị loại; generation chặn kết quả cũ ghi lại sau xóa. Cài đặt xóa cache cần gọi `clear()` để xóa cả bộ nhớ đang sống; dọn match cache theo chính sách đăng xuất thuộc CORE. |
| GL-10 | Xong điểm Home được giao | `storeWishlistIn` là câu đầy đủ và semantics dùng nguyên câu; các câu ghép ngoài phạm vi tiếp tục thuộc I18N W3/COPY. |
| GL-24 | Xong điểm normalizeTier được giao | Suy ra sub-tier từ id/số, không regex trên tên rank đã dịch; giữ test commit gốc. Các site price estimate chung thuộc gói khác. |
| GL-38 | Xong theo phương án tài liệu | `defaultNumber` độc lập ngôn ngữ cho tính duy nhất; I18N.md ghi rõ tên preset đã lưu là dữ liệu người dùng, không tự đổi theo locale. |

## File chính và cách kiểm chứng

- Dữ liệu trận: `lib/core/domain/competitive/{performance,match_stats_store,matches,rank,rank_calc,rr_history,names}.dart`.
- Ngoại tuyến/cửa hàng: `lib/core/domain/economy/{economy_fetch,storefront,store_history}.dart`, Loadout providers, Battle Pass providers.
- Hồ sơ: `lib/features/profile/data/{performance_view,hit_distribution}.dart`, route, strings, màn Hiệu suất/chi tiết/RR theo ngày và round timeline.
- Skin/cửa hàng/wishlist: `store_history_line.dart`, `community_skin_score.dart`, `providers/community_skin_stats.dart` và ba loại thẻ tương ứng.
- Home: arrangement, wrappers preview, refresh, kiểm tra viewport, nhãn kết quả chưa rõ. `docs/design/{HOME,I18N}.md` ghi ngoại lệ được chấp nhận.
- Test mới/chỉnh trong `test/core/domain`, `test/features/{profile,home,skin_detail,battlepass}`. `test/app/app_integration_test.dart` xác nhận điều hướng Hiệu suất và cập nhật cuộn đến hàng Battle Pass có lazy sliver. Không sửa implementation app/core UI/XMPP/Cài đặt.

Các test kiểm tra giá trị cụ thể: ACS có trọng số, thiếu mẫu ẩn ADR/HS%,
side không đoán khi thiếu chứng cứ, lọc ngày/chế độ, không gọi P-14 từ
Hiệu suất; ngày UTC không trùng nhưng cùng skin ngày sau vẫn tính; ghi đồng
thời không mất ngày; không ghi từ offline/rỗng; giữ giá mới hơn; xóa đúng
tài khoản và xác nhận; người khác không đọc file history; không tạo RR file
cho khách; dọn file cũ; tên không hồi sinh sau clear; batch 50+5 và hạn dùng
30 phút từ lần tải gốc; polling không chạy dưới màn hình; glyph ngoài màu.

## Điểm nối cho Claude / WP-CORE

1. Sau P-1 trực tiếp trong `wishlist/background/wishlist_check.dart`, dùng
   `StoreHistoryStore.onDevice().record(puuid, storefront, receivedAt)`.
   Chỉ dùng tài khoản còn tồn tại và snapshot live; không thêm poll nền hoặc
   bỏ qua công tắc hiện có. Store đã có khóa file cho hai bên ghi. UI helper
   `recordStoreHistoryFor(ref, puuid, storefront, receivedAt)` đã được gọi từ
   `storefrontProvider` theo kiểu best effort.
2. Nút Cài đặt “Xóa lịch sử RR”: sau xác nhận gọi
   `ref.read(deleteRrHistoryProvider(puuid))()`; helper chỉ nhận tài khoản
   của mình, không xóa dữ liệu tài khoản khác. Không tự tải lại/backfill để
   khôi phục ngay dữ liệu vừa xóa trong cùng hành động.
3. Khi chọn xóa dữ liệu cục bộ/đăng xuất không giữ dữ liệu, phối hợp hủy tác
   vụ và gọi `RrHistoryStore.delete`, `MatchStatsStore.delete`,
   `StoreHistoryStore.delete`; các khóa trong namespace `history` lần lượt
   là `keep/<id>/rr_history`, `keep/<id>/match_stats`,
   `acct/<id>/store_history`. Đừng chỉ xóa thư mục `cache/acct`. Sweep khi
   khởi động cần dọn cả các history này theo quyết định giữ/xóa; khóa
   `store_history.json.lock` là file khóa, không chứa giá/nội dung lịch sử.
4. Khi xóa dữ liệu tạm, gọi `ref.read(nameResolverProvider).clear()` bên cạnh xóa file
   cache để xóa cả tên trong bộ nhớ đang sống. Provider đã clear khi danh
   sách tài khoản chuyển sang rỗng; CORE cần dọn match cache và orphans theo
   chính sách đã thống nhất. CORE cần invalidate store/providers khi kết
   thúc toàn bộ tài khoản để kết thúc bộ nhớ RR khách đang sống.
5. WP-COPY cập nhật nội dung giữ/xóa RR, match ledger, lịch sử cửa hàng và
   preset trong chính sách. Không gọi tần suất cửa hàng cá nhân là xác suất
   xuất hiện toàn cầu.

## Giới hạn và rủi ro cần review

- Chỉ có dữ liệu trên thiết bị từ khi từng trận/cửa hàng được ghi. Không
  backfill cửa hàng đã mất, không mặc nhiên có đủ mọi trận chơi trước đây.
  Giới hạn 5.000 trận/365 ngày làm mất phần cũ nhất; ngày nguồn thể hiện
  phần hiện còn trên thiết bị.
- Attack/defense cần `winningTeamRole` hoặc người đặt/gỡ Spike; không đoán
  từ nửa trận. Multi-kill chỉ đáng tin khi kill feed khớp tổng chính thức;
  clutch không hiển thị. ADR/HS% mới yêu cầu riêng 3 trận có dữ liệu đó.
- RR floor 0 chưa có kết quả vẫn là unknown. Bonus/AFK, placements và giá
  Radianite chưa xác minh: không bổ sung con số/ý nghĩa phỏng đoán.
- Luồng wipe an toàn khi tác vụ đang chạy cần tích hợp từ CORE. Phần DOMAIN
  đã có guard tài khoản sau await; helper store dùng được từ isolate nền,
  nhưng không tự thay đổi chính sách của gói CORE.
- RR legacy prune không xóa wishlist/preset/match ledger. Id của tài khoản
  từng giữ wishlist/preset được giữ, vì không thể xác định là khách chỉ từ
  một RR file. Match cache vẫn là LRU hiện có.
- Chưa kiểm tra trực quan trên thiết bị, emulator hoặc adb theo yêu cầu;
  Claude kiểm tra bố cục, màu/semantics và luồng thực sau review. Xu hướng
  Hiệu suất hiện là bảng thời gian với các số thật, không thêm biểu đồ giả.

## Kiểm tra cuối

Chạy qua PowerShell với PATH Flutter 3.47.5 theo HANDOFF.

- `flutter pub get`: thành công, không thêm dependency.
- `flutter analyze`: **0 issues**, exit 0 (`No issues found!`).
- `flutter test --reporter expanded`: **2.133 test đạt**, exit 0 (`All tests passed!`, 01:29).
- `dart format lib test tool`, rồi `dart format --output=none --set-exit-if-changed lib test tool`: **638 file, 0 thay đổi**, exit 0.
- `git diff --check` và `git diff --cached --check`: sạch khi chốt báo cáo.
- Không push, không merge nhánh chính, không deploy, không dùng emulator/adb.

## Commit

- `0f2823f` — commit gốc: WP-DOMAIN 1, số liệu đúng, performance/ledger, AR-015/029.
- `4f0bd5d` — WIP gốc: hai file store history/performance view chưa xong.
- `a7ce278` — merge nền tảng `claude/jolly-hawking-23o2j8` vào nhánh worktree.
- `5b637f8` — WIP: nối Hiệu suất và lịch sử cửa hàng, giới hạn dữ liệu người chơi khác.
- `b82a13e` — WIP: kiểm tra dữ liệu ngoại tuyến, quyền riêng tư và số liệu Hiệu suất.
- `9647e7e` — WIP: hoàn thiện ngưỡng mẫu, nạp tên dự phòng và kiểm tra điều hướng.
- Commit chốt chứa báo cáo này: **WP-DOMAIN: chốt kiểm tra và bàn giao dữ liệu trận, cửa hàng**. Hash của chính commit báo cáo xem bằng `git log -1 --format=%h` (không tự ghi hash vào nội dung để tránh vòng lặp hash).
