# ValHub

Checkpoint mới nhất 05/10 build 4023: [trạng thái máy chủ / coverage / release gates](docs/DEEP_REVIEW_CHECKPOINT_2026-10-05.md). Đã sửa phản hồi status sai cấu trúc bị coi là bình thường và lỗi refresh che nút thử lại. Windows 4.396 tests mỗi cấu hình, analyzer 0; Mac 165 tests và unsigned iOS 4023; Android native 6/public 10, nâng APK giữ sáu tài khoản và kiểm tra mất mạng/retry bằng Mobile MCP. Backend 949, runtime afa7162 giữ nguyên. Coverage 89,96% dòng được instrument, còn 16 file ngoài LCOV. Cutover vẫn 1 ref / 768 literals / 52 structural; chưa nghiệm thu toàn bộ hay signed store release.

Checkpoint trước 05/10 build 4022: [đối chiếu audit và chat isolation](docs/AUDIT_RECONCILIATION_2026-10-05.md). Đã đối chiếu báo cáo bên ngoài và sửa lỗi bản nháp/callback chat lẫn giữa tài khoản hoặc người nhận. Windows 4.389 tests mỗi cấu hình, analyzer 0; Mac Social/XMPP 128, analyzer 0 và unsigned iOS build; Android native 6/public 10. Nâng APK giữ sáu accounts/active/wishlist/settings, Mobile MCP/cache/log đã kiểm tra. Backend vẫn healthy ở afa7162; i18n gate vẫn đỏ, chưa nghiệm thu toàn bộ hay signed release.

Checkpoint production 05/10: [production deployment và tài khoản thật](docs/PRODUCTION_DEPLOYMENT_2026-10-05.md). Backend `afa7162` đã deploy: API/backup/watchdog healthy, 13 migrations; bình luận và đánh giá skin sở hữu được tạo/đọc/xóa thật qua Mobile MCP. Giữ 5 người dùng/review/vote cũ và 6 tài khoản trên emulator; restore bản sao dữ liệu production đã qua. Flutter 4.386 tests mỗi cấu hình, analyzer 0; backend 949; Docker/Trivy pass. P0 i18n vẫn chặn phát hành toàn bộ; chưa có signed store release.

Checkpoint trước 04/10 build 4021: [danh mục skin / bình luận / CI local](docs/SKIN_CATALOG_AND_DISCUSSION_2026-10-04.md). Windows 4.386 tests mỗi cấu hình, analyzer 0; backend 931; Mac Community 361 và unsigned iOS build; Android public 10/native 6. Docker build/restore/Trivy đã qua sau sửa 11 HIGH. Emulator giữ 6 tài khoản, hiển thị 1.373 skin sưu tầm thật. API bình luận production còn 404; i18n cutover còn 1 ref / 768 literals / 52 structural, chưa nghiệm thu toàn bộ.

Checkpoint 04/10 build 4020: [account/ownership verification](docs/ACCOUNT_AND_OWNERSHIP_CHECKPOINT_2026-10-04.md). Windows/Mac 4,369 tests; analyzer 0; backend 917; Android public 10/native 6; unsigned iOS build succeeds. Whole-product acceptance, localization cutover and new full-catalog/comment requirements remain open.

Checkpoint trước 04/10: [Model / export riêng tư / CI local, build 4018](docs/I18N_MODELS_AND_EXPORT_2026-10-04.md).

Đã chuyển nhãn model sang resources hiện tại, bảo toàn tên bộ trang bị cũ
và chặn chia sẻ export khi đổi/gỡ tài khoản hoặc rút đồng ý lúc đang tải.
Windows hai lượt/Mac đạt **4.332 tests**, analyzer 0; backend **900 tests**.
APK 4018 qua 10 public flows; Mobile MCP/cache/log kiểm tra bốn tài khoản thật,
giữ dữ liệu, khôi phục active ban đầu và đối chiếu bốn giá VP với Riot Cost.
iOS build trên Mac, **chưa ký/chưa nghiệm thu iPhone**. Cutover còn
**35 refs / 762 literals / 52 structural**, chỉ VI UI ships; toàn bộ sản phẩm
chưa được nghiệm thu, backend chưa deploy production.

Checkpoint trước 03/10: [LFG / phiên chờ / backend, build 4017](docs/LFG_AND_SESSION_COMMIT_2026-10-03.md).

Đã khóa thao tác vào tổ đội, giữ đúng tài khoản khi chờ và làm mới cache sau
khi vào; số lượt yêu cầu không còn bị ghi thành người đã vào. Backend chặn ghi
muộn bằng phiên đã thu hồi; có bản rà soát 40 endpoint. Windows hai lượt/Mac
đạt **4.319 tests**, analyzer 0; backend **900 tests**. APK 4017 qua 10 public
flows và kiểm tra Mobile MCP/cache/log với **bốn tài khoản thật**, giữ dữ liệu
và đối chiếu giá VP. iOS build trên Mac, **chưa ký/chưa nghiệm thu iPhone**.
Cutover còn **62 refs / 762 literals / 52 structural**, chỉ VI UI ships.
Backend chưa deploy production; toàn bộ sản phẩm chưa được nghiệm thu.

Checkpoint trước 03/10: [Nhãn có điều kiện / semantics, build 4016](docs/I18N_CONDITIONAL_VIEWS_2026-10-03.md).

Đã chuyển nhãn có điều kiện và semantics sang resources hiện tại,
giữ hành vi VI. Windows hai lượt và Mac đạt **4.312 tests**, analyzer 0;
backend **867 tests**. APK 4016 qua 10 public flows; Mobile MCP/cache/log kiểm
tra đủ **bốn tài khoản thật**, giữ wishlist/cài đặt, trả active ban đầu và đối
chiếu bốn giá VP với Riot Offer Cost. iOS 4016 build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **62 refs / 762 literals / 52 structural**;
chỉ VI UI ships, chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Ngày/giờ / giá / thống kê, build 4015](docs/I18N_FORMAT_CUTOVER_2026-10-03.md).

Đã chuyển ngày/giờ, hết hạn, giá và thống kê sang formatter/resources hiện tại,
giữ hành vi VI. Windows hai lượt và Mac đạt **4.307 tests**, analyzer 0;
backend **867 tests**. APK 4015 qua 10 public flows; Mobile MCP/cache/log kiểm
tra đủ **bốn tài khoản thật**, giữ wishlist/cài đặt, trả active ban đầu và đối
chiếu bốn giá VP với Riot Offer Cost. iOS 4015 build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **94 refs / 762 literals / 52 structural**;
chỉ VI UI ships, chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Nhãn hiển thị / xác nhận ngôn ngữ, build 4014](docs/I18N_VIEW_CUTOVER_2026-10-03.md).

Đã chuyển nhãn enum/widget/callback sang resources hiện tại và thêm xác nhận
ngôn ngữ cho screen reader sau khi lưu. Windows hai lượt và Mac đạt **4.299
tests**, analyzer 0; backend **867 tests**. APK 4014 qua 10 public flows;
Mobile MCP/cache/log kiểm tra chuyển đủ **bốn tài khoản thật**, đúng dữ liệu
cửa hàng từng tài khoản và trả active ban đầu. iOS 4014 build trên Mac,
**chưa ký/chưa nghiệm thu iPhone**. Cutover còn **129 refs / 762 literals /
52 structural**, chỉ VI UI ships; chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Nội dung / locale / RR loading, build 4013](docs/I18N_CONTENT_CUTOVER_2026-10-03.md).

Đã tách nhãn nội dung khỏi model, thêm lựa chọn tên vật phẩm theo app hoặc 18
locale và giữ lựa chọn cũ; sửa thứ tự ghi cài đặt và race đọc RR. Windows hai
lượt và Mac đạt **4.292 tests**, analyzer 0; backend **867 tests**. APK 4013 qua
10 public flows, đã nâng cấp emulator và giữ bốn tài khoản/wishlist/cài đặt;
Mobile MCP/cache/log thật được kiểm tra. iOS 4013 build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **195 refs / 762 literals / 52 structural**;
chỉ VI ships, chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Cộng đồng / cách ly tài khoản, build 4012](docs/COMMUNITY_ACCOUNT_ISOLATION_2026-10-03.md).

Windows hai lượt và Mac đạt **4.265 tests**, analyzer 0; backend **867 tests**.
APK 4012 qua 10 public-flow cases, đã nâng cấp emulator có cửa sổ, giữ đủ
bốn tài khoản, wishlist và cài đặt. iOS 4012 đã build trên Mac, **chưa ký/chưa
nghiệm thu iPhone**. Cutover còn **262 refs / 762 literal hits / 52 structural
members**, chỉ VI ships; chưa nghiệm thu toàn bộ.

Checkpoint trước 03/10: [Callback / cách ly tài khoản, build 4011](docs/I18N_CALLBACK_ISOLATION_2026-10-03.md).
Đã sửa lỗi phản hồi tổ đội đến muộn và xóa mã của tài khoản khác khi chuyển;
Windows hai lượt và Mac đạt **4.246 tests**, analyzer 0. APK **4011** đã cài
trên emulator, 10 public flows đạt; bốn tài khoản/active/wishlist/cài đặt giữ
nguyên. iOS 4011 build trên Mac, **chưa ký/chưa test iPhone**. Cutover còn
**307 refs / 762 literal hits**, chưa nghiệm thu toàn bộ.


Checkpoint trước 03/10: [Render-time cutover, build 4010](docs/I18N_RENDER_CUTOVER_2026-10-03.md).
Đã chuyển thêm **175 refs** (514 → **339**). Windows hai lượt và Mac đạt
**4.238 tests**, analyzer 0; backend 867, codemod 37, Android native 6 và public
flows 10 đạt. APK **4010** đã được kiểm tra trên emulator; bốn tài khoản/active/wishlist/
settings giữ nguyên. iOS 4010 build trên Mac nhưng **chưa ký/chưa test iPhone**.
Cutover còn đỏ, chưa nghiệm thu toàn bộ; chỉ tiếng Việt được phát hành.


Checkpoint 03/10: [Review Gemini và tích hợp ValHub](docs/VALHUB_INTEGRATION_2026-10-03.md). Đã sửa lỗi
Gemini và gộp locale nền/bộ chọn/thông báo. Windows/Mac **4.236 tests**,
analyzer 0; backend 867, native 6, public-flow 10 cases đạt. APK/iOS không ký
**4009** đã build; bốn tài khoản, active, wishlist và settings giữ sau nâng APK.
Cutover còn **514 refs / 52 structural members**, chưa nghiệm thu toàn app.
Các số 02/10 bên dưới là checkpoint lịch sử.

<img src="assets/icon/icon.png" width="96" alt="Icon ValHub" align="right">

Ứng dụng đồng hành **VALORANT** cho Android và iOS, viết bằng Flutter, dành cho người chơi ở mọi
quốc gia. Tiếng Việt là ngôn ngữ gốc; ValHub đang được chuyển sang 18 ngôn ngữ của VALORANT. Tính
năng chính:

- **Trang chủ**: cửa hàng hôm nay, rank, Battle Pass và trận đang diễn ra ngay khi mở app.
- **Cửa hàng**: cửa hàng hằng ngày, Chợ Đêm, phụ kiện, bundle, chi tiết skin kèm video.
- **Battle Pass**: tiến độ, cột mốc hằng ngày, nhiệm vụ tuần, danh sách phần thưởng.
- **Bộ sưu tập**: đổi thẻ, danh hiệu, skin, phụ kiện súng, tổ hợp cảm xúc, preset trang bị.
- **Wishlist**: báo khi skin bạn thích xuất hiện trong cửa hàng (kể cả khi đóng app).
- **Hồ sơ**: rank, lịch sử trận, chi tiết trận, RR theo ngày, tính số trận lên hạng.
- **Trận hiện tại**: đội hình kèm rank, chọn/khóa đặc vụ, trang bị người chơi.
- **Xã hội**: bạn bè, trò chuyện, tổ đội và hàng chờ.
- **Cộng đồng**: bảng tin, tìm đồng đội, xếp hạng và đánh giá skin.
- Tối đa 10 tài khoản Riot, đổi qua lại nhanh.

Bạn đăng nhập tài khoản Riot **của chính mình** trên trang đăng nhập chính thức của Riot. Thông tin
đăng nhập chỉ lưu trên thiết bị của bạn. Mọi thao tác thay đổi tài khoản đều do bạn bấm, và có hộp
xác nhận khi có thể bị phạt.

## Build

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get
flutter analyze && flutter test
flutter build apk --release
```

Chi tiết (APK/IPA từ GitHub Actions, ký release): [`docs/BUILD.md`](docs/BUILD.md).
Kiến trúc: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md). Tiến độ: [`docs/PROGRESS.md`](docs/PROGRESS.md).

Kiểm chứng mới nhất: [Locale nền / bộ chọn / CI local 02/10](docs/I18N_BACKGROUND_2026-10-02.md).
Windows hai lượt và Mac toàn bộ đều đạt 4.232 Flutter tests; analyzer 0 issues
ở cả hai máy. Backend 867 tests, native Android 6 và public-flow 10 cases đạt.
APK review và iOS không ký 4007 đã build; APK đã cài trên emulator có cửa sổ.
Quốc tế hóa và các gate release còn thiếu; chưa tuyên bố production-ready.
GitHub Actions hiện bị khóa billing.

## Tuyên bố miễn trừ

ValHub không được Riot Games xác nhận và không phản ánh quan điểm của Riot Games hay bất kỳ ai
tham gia sản xuất hoặc quản lý các sản phẩm của Riot Games. Riot Games và mọi tài sản liên quan
là thương hiệu hoặc thương hiệu đã đăng ký của Riot Games, Inc. Dữ liệu nội dung lấy từ
[valorant-api.com](https://valorant-api.com).
