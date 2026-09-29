# ValVN

Ứng dụng đồng hành Valorant **toàn cầu** (vượt ValBuddy 2.1.2 và Daily Val), viết bằng **Flutter** cho iOS và Android. Đang chuyển sang **18 ngôn ngữ VALORANT** (tiếng Việt là ngôn ngữ gốc/template) và hỗ trợ mọi quốc gia — xem `docs/design/IA.md` (mục Toàn cầu) và `docs/design/I18N.md` khi có.

## Toolchain (container)

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get
flutter analyze            # phải sạch (0 issues) trước khi commit
flutter test               # unit/widget tests
flutter build apk --release
```

- Flutter stable 3.47.5, Dart 3.13.4. Android SDK ở `/opt/android-sdk`, Java 21.
- IPA chỉ build được trên macOS → workflow GitHub Actions trong `.github/workflows/`.

## Tài liệu

- `docs/research/SUMMARY.md` là nguồn tham chiếu chính (endpoint, header, auth, ID, công thức). Khi tài liệu chi tiết mâu thuẫn với SUMMARY, SUMMARY thắng.
- Chi tiết: `riot-auth.md`, `riot-endpoints.md`, `content-api.md`, `valbuddy-features.md` (sơ đồ màn hình §6, bảng thuật ngữ tiếng Việt §8), `flutter-stack.md`.
- `docs/ARCHITECTURE.md`: cấu trúc code và API nội bộ mà các tính năng dùng chung.

## Quy ước

- Mọi chuỗi hiển thị nằm trong file chuỗi của từng tính năng (`lib/features/<f>/<f>_strings.dart`) hoặc `lib/core/l10n/` — không hard-code chuỗi trong widget. Tiếng Việt là ngôn ngữ gốc (theo bảng thuật ngữ `valbuddy-features.md` §8); trong đợt i18n các file này được chuyển sang hệ thống đa ngôn ngữ theo `docs/design/I18N.md`.
- Không giả định người dùng ở Việt Nam: múi giờ, định dạng số/ngày, tiền tệ, quốc gia, máy chủ đều lấy theo thiết bị / tài khoản / lựa chọn của người dùng.
- Thuật ngữ game người chơi Việt quen dùng giữ nguyên tiếng Anh (VP, RR, K/D/A, ACS, HS%, Battle Pass, skin, bundle, wishlist...).
- Dữ liệu nội dung (tên skin, agent, map, rank...) lấy từ `https://valorant-api.com` với `language` theo ngôn ngữ app (hiện tại `vi-VN`).
- Mọi dữ liệu phải thật: không dữ liệu mẫu, không nút chết, không "sắp ra mắt"; số liệu không xác minh được thì ẩn, không bịa.
- Mỗi tính năng nằm trong `lib/features/<f>/` (data / providers / ui) và test trong `test/features/<f>/`. Code dùng chung nằm trong `lib/core/`.
- Parse JSON từ Riot một cách phòng thủ (mọi trường nullable, mảng có thể null, UUID lowercase, số đọc bằng `num`); body lỗi có thể là HTML (Cloudflare). Không bao giờ crash vì dữ liệu lạ.
- Không log, không gửi token/cookie/PUUID ra ngoài; chỉ lưu trong secure storage. Ngoại lệ duy nhất (chủ dự án đã duyệt): access token Riot được gửi tới `POST /v1/auth/riot` của máy chủ cộng đồng ValVN để xác minh Riot ID; máy chủ bỏ token ngay, không lưu PUUID (xem `docs/community-api.md`). Mọi thao tác thay đổi tài khoản (loadout, khóa đặc vụ, hàng chờ, rời trận) phải do người dùng bấm, có xác nhận nếu có hình phạt.
