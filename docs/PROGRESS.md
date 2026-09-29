# Tiến độ ValVN (điểm dừng để làm tiếp)

Cập nhật: 2026-09-29. Nhánh: `claude/jolly-hawking-23o2j8`.

Trạng thái: **đủ 8 nhóm tính năng giao diện, đã tích hợp**. `flutter analyze` 0 lỗi,
917 test pass. `flutter build apk --release` thành công, ký bằng debug key vì chưa có keystore
thật: APK universal 70,6 MB, bản tách theo ABI arm64-v8a 25,6 MB, armeabi-v7a 23,5 MB,
x86_64 27,2 MB.

## Đã xong

1. **Nghiên cứu**: `docs/research/` (SUMMARY.md là nguồn chính).
2. **Nền móng lõi**: `lib/core/` (xem `docs/ARCHITECTURE.md`). Gồm đăng nhập Riot bằng WebView,
   re-auth bằng cookie, tối đa 10 tài khoản, `PvpApi` (mọi endpoint), nội dung valorant-api.com
   vi-VN có cache, thông báo cục bộ, tác vụ nền, bộ widget UI, router 5 tab.
3. **Lớp dữ liệu dùng chung**: `lib/core/domain/economy` (cửa hàng, ví, đồ sở hữu, giá, wishlist),
   `competitive` (rank, RR, lịch sử trận, chi tiết trận), `loadout` (GET/PUT v3 giữ nguyên map
   gốc, preset cục bộ, loadout trong trận), `lib/core/xmpp` (chat Riot: roster, presence, tin nhắn).
   Tài liệu API: `docs/architecture/domain-*.md`, `xmpp.md`.
4. **Giao diện theo tính năng** (`lib/features/`, sơ đồ màn hình VF §6):

   | Tính năng | Màn hình | Commit |
   |---|---|---|
   | Cửa hàng + chi tiết skin | S10–S16: Hằng ngày, Chợ Đêm, Phụ kiện, Bundle, chi tiết bundle, chi tiết skin, video | `7225db4` |
   | Battle Pass | S20 thẻ Battle Pass, cột mốc hằng ngày, nhiệm vụ tuần; S21 phần thưởng | `4964bf9` |
   | Bộ sưu tập | S30–S39: thẻ/danh hiệu, trang bị vũ khí, phụ kiện súng, tổ hợp cảm xúc, preset, duyệt bộ sưu tập | `93e52e3` |
   | Wishlist | S3A Wishlist, S3B Tất cả skin, kiểm tra wishlist trong nền | `6bb0d40` |
   | Hồ sơ | S40–S44: rank, lịch sử trận, tính lên hạng, RR theo ngày, chi tiết trận, hồ sơ người chơi | `aac5501` |
   | Trận hiện tại | S50/S51: theo dõi trận, chọn/khóa đặc vụ, đội hình kèm rank, rời trận có xác nhận, thẻ trên Hồ sơ | `7c04154`, `5c7fd9d` |
   | Xã hội | S55 Tổ đội & hàng chờ, S60 Bạn bè, S61 Trò chuyện | `32d93e3` |
   | Cài đặt | S01 Chào mừng, S04 xin quyền thông báo, S70 Cài đặt, S71 Nhật ký phiên, S72 Giới thiệu | `0d07376` |

   Màn hình nào cũng có skeleton khi tải, trạng thái trống, lỗi kèm "Thử lại" và kéo để làm mới.
   Widget test chạy ở 360dp (nhiều test ở 320dp với cỡ chữ 130%).
5. **Tích hợp** (commit tích hợp cuối):
   - Test tích hợp toàn app `test/app/app_integration_test.dart`: đủ 5 tab dựng được khi Riot
     lỗi (hiện "Thử lại"), route chéo tính năng (`/collection/wishlist`, `/profile/friends`,
     `/profile/rankup`, trang không tồn tại), đổi tài khoản đang dùng.
   - Thông báo **"Chợ Đêm đã mở!"** (VF §6.9): gửi trong lần kiểm tra nền, mỗi Chợ Đêm một lần
     cho mỗi tài khoản, khi bật "Khi Chợ Đêm mở". Dùng chung một lần đọc storefront/ngày với
     kiểm tra wishlist.
   - Icon app gốc (chữ V đỏ #FF4655 kèm ngôi sao trên nền #0F1923, không dùng logo Riot/Valorant):
     `tool/generate_icon.py` → `assets/icon/`, sinh icon Android (kèm adaptive + monochrome) và
     iOS bằng `flutter_launcher_icons`. Icon thông báo trắng riêng `@drawable/ic_stat_valvn`.
     Màn khởi động Android/iOS nền tối (không còn chớp trắng).
   - Xóa `docs/wip/store-settings-wip.patch` (Cửa hàng và Cài đặt đã vào code).
6. **CI**: `.github/workflows/android.yml` (APK) và `ios.yml` (IPA chưa ký), xem `docs/BUILD.md`.

## Còn thiếu / hạn chế đã biết

Chưa kiểm tra trên máy thật với dữ liệu Riot thật. Đây là việc quan trọng nhất còn lại.

- **Cửa hàng**: chưa có mua hàng (cố ý không làm). Bố cục mới chỉ kiểm tra qua ảnh chụp test,
  không có ảnh mạng.
- **Battle Pass**: phần thưởng miễn phí mở ở cấp cuối chương, ≈ 4.000 XP/trận và thuật ngữ
  "Phần mở rộng" là giả định, tài liệu chưa xác nhận. Riot không trả lượng XP/KC của cột mốc,
  nên chỉ hiện "+XP, +KC".
- **Hồ sơ**: chi tiết trận không có cờ "ẩn tên", nên bảng điểm hiện tên thật. Hồ sơ người chơi
  chỉ ẩn danh khi mở bằng `?hidden=1`. Lọc theo map chỉ lọc các trận đã tải. Cột ACS ở Sinh Tử là
  tổng điểm. Mục "Bạn bè & trò chuyện" chưa có số tin chưa đọc, vì hiện số này sẽ phải mở kết nối
  chat mỗi lần vào tab Hồ sơ.
- **Trận hiện tại**: huy hiệu "Tổ đội" chỉ lấy từ tổ đội của bạn và presence của bạn bè. Tỉ số
  trực tiếp ẩn khi presence của bạn cũ hơn 2 phút (SUMMARY §13 U9). Kéo làm mới tab Hồ sơ không
  làm mới thẻ Trận hiện tại; thẻ tự làm mới mỗi 20 giây.
- **Cài đặt**: chưa có link Discord ("Góp ý & báo lỗi" mở GitHub issues). Chưa có cảnh báo tối
  ưu pin Android. "Xóa bộ nhớ đệm" chỉ xóa cache phản hồi và ảnh. Preset loadout (prefs), lịch sử
  RR (thư mục `history`) và wishlist được giữ lại (đã kiểm tra).
- **Thông báo nền**: chạy theo lịch workmanager (≥ 6 giờ, Android có thể trễ hơn khi Doze). iOS
  chạy nền không đảm bảo.
- **Phát hành**: APK đang ký bằng debug key. Muốn phát hành thật cần keystore riêng
  (`docs/BUILD.md` §4). IPA chỉ build được qua GitHub Actions (macOS).

## Cách làm tiếp

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get && flutter analyze && flutter test
flutter build apk --release                  # build/app/outputs/flutter-apk/app-release.apk
flutter build apk --release --split-per-abi  # app-{arm64-v8a,armeabi-v7a,x86_64}-release.apk
```

Đổi icon: sửa `tool/generate_icon.py`, rồi chạy
`pip install pillow && python3 tool/generate_icon.py && dart run flutter_launcher_icons`.
Sau đó **hoàn tác thay đổi của lệnh này trong `ios/Runner.xcodeproj/project.pbxproj`** (lỗi của
flutter_launcher_icons 0.14.4: nó ghi đè `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`).

Thứ tự nên làm:

1. Chạy thử trên máy Android thật với tài khoản Riot của mình: đăng nhập, đủ 5 tab, đổi tài khoản,
   trang bị (PUT), trận hiện tại, chat. Ghi lỗi từ "Nhật ký phiên" (đã ẩn token).
2. Sửa các giả định còn mở (Battle Pass, ACS Sinh Tử, cờ ẩn tên) theo dữ liệu thật.
3. Tạo keystore release, cấu hình secret CI, gắn tag `v1.0.0`.

Container mới cần cài lại Flutter 3.47.5 (`/opt/flutter`) và Android SDK
(`platform-tools`, `platforms;android-36`, `build-tools;36.0.0` tại `/opt/android-sdk`).
Quy tắc commit: chỉ commit khi analyze 0 lỗi và toàn bộ test pass.
