# VanHub

<img src="assets/icon/icon.png" width="96" alt="Icon VanHub" align="right">

Ứng dụng đồng hành **VALORANT** cho Android và iOS, viết bằng Flutter, dành cho người chơi ở mọi
quốc gia. Tiếng Việt là ngôn ngữ gốc; VanHub đang được chuyển sang 18 ngôn ngữ của VALORANT. Tính
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

VanHub không được Riot Games xác nhận và không phản ánh quan điểm của Riot Games hay bất kỳ ai
tham gia sản xuất hoặc quản lý các sản phẩm của Riot Games. Riot Games và mọi tài sản liên quan
là thương hiệu hoặc thương hiệu đã đăng ký của Riot Games, Inc. Dữ liệu nội dung lấy từ
[valorant-api.com](https://valorant-api.com).
