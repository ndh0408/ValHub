# ValVN

<img src="assets/icon/icon.png" width="96" alt="Icon ValVN" align="right">

Ứng dụng đồng hành Valorant **tiếng Việt** cho Android và iOS, viết bằng Flutter. Tính năng tương
đương ValBuddy 2.1.2:

- **Cửa hàng**: cửa hàng hằng ngày, Chợ Đêm, phụ kiện, bundle, chi tiết skin kèm video.
- **Battle Pass**: tiến độ, cột mốc hằng ngày, nhiệm vụ tuần, danh sách phần thưởng.
- **Bộ sưu tập**: đổi thẻ, danh hiệu, skin, phụ kiện súng, tổ hợp cảm xúc, preset trang bị.
- **Wishlist**: báo khi skin bạn thích xuất hiện trong cửa hàng (kể cả khi đóng app).
- **Hồ sơ**: rank, lịch sử trận, chi tiết trận, RR theo ngày, tính số trận lên hạng.
- **Trận hiện tại**: đội hình kèm rank, chọn/khóa đặc vụ, trang bị người chơi.
- **Xã hội**: bạn bè, trò chuyện, tổ đội và hàng chờ.
- Tối đa 10 tài khoản Riot, đổi qua lại nhanh.

Bạn đăng nhập tài khoản Riot **của chính mình** qua trang đăng nhập chính thức của Riot. Token chỉ
lưu trên máy (secure storage). Mọi thao tác thay đổi tài khoản đều do bạn bấm, và có hộp xác nhận
khi có thể bị phạt.

## Build

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get
flutter analyze && flutter test
flutter build apk --release
```

Chi tiết (APK/IPA từ GitHub Actions, ký release): [`docs/BUILD.md`](docs/BUILD.md).
Kiến trúc: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md). Tiến độ: [`docs/PROGRESS.md`](docs/PROGRESS.md).

## Tuyên bố miễn trừ

ValVN không được Riot Games xác nhận và không phản ánh quan điểm của Riot Games hay bất kỳ ai
tham gia sản xuất hoặc quản lý các sản phẩm của Riot Games. Riot Games và mọi tài sản liên quan
là thương hiệu hoặc thương hiệu đã đăng ký của Riot Games, Inc. Dữ liệu nội dung lấy từ
[valorant-api.com](https://valorant-api.com).
