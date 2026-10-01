# Bộ chọn quốc gia dùng chung — 01/10/2026

Đợt tiếp theo sau checkpoint `6c2261f`, theo yêu cầu tiếp tục hoàn thiện và gộp/push bản mới để Claude review. Phạm vi đóng ở đợt này là bộ chọn quốc gia dùng chung và kiểm tra mã quốc gia Community; không đánh dấu hoàn tất toàn bộ COUNTRIES hoặc 18 ngôn ngữ UI.

## Thay đổi

- Cài đặt và Community cùng dùng `lib/core/geo/country_picker.dart`; adapter Community chỉ chuyển số liệu API thành `CountryActivity`. Cài đặt giữ bộ lọc hỗ trợ/khu vực và gợi ý thiết bị/tài khoản/lựa chọn. Community dùng hai tab Có hoạt động / Tất cả quốc gia, ghim quốc gia profile do server cung cấp, không lấy preference giá VP làm quốc gia Community.
- Tab Có hoạt động giữ thứ tự API và số bài/người/LFG tuần. Tab Tất cả dùng thứ tự CLDR và cho chọn cả nước chưa có hoạt động, không phụ thuộc bảng khả năng Riot hỗ trợ. API lỗi vẫn chuyển sang Tất cả được, có nút thử lại. Đọc hoạt động công khai không phát sinh đăng nhập Community.
- Community loại XK/non-ISO; model, query và scope memory cũng chặn XK/ZZ/mã không hợp lệ. ISO2 hợp lệ chưa có hoạt động vẫn chọn được. Không gửi country để thay đổi profile Riot/Community; query country chỉ là bộ lọc nội dung.
- Tìm tên bản địa/tiếng Anh, tên thay thế CLDR, ISO2/3; gấp dấu, ưu tiên tiền tố rồi tiền tố từ/chuỗi con, giữ thứ tự gốc khi cùng hạng. CLDR 48.0.0 cung cấp tên thay thế ở 18 asset; ví dụ Mỹ / Hoa Kỳ, US / United States. Bộ sinh giữ được aliases khi chạy offline, kiểm tra byte-stable đã đạt.
- Không lọc giữa lúc IME đang composing; chờ commit ký tự. Số kết quả dùng ICU và live-region debounce 300 ms; cờ trang trí không đọc, ISO luôn LTR. Không có kết quả có nút Bỏ lọc.
- Cửa sổ cao dưới 480 dp dùng trang đầy đủ có nút quay lại; màn khác dùng sheet 85%, tối đa 720 dp. Header và danh sách cùng cuộn trong RTL/landscape/chữ 200%/bàn phím.
- Nhãn nước trên scope bar và tooltip/semantics tác giả dùng CLDR thay bảng tiếng Việt. Scope bar lấy detected region của tài khoản, giữ đúng khu vực Community khi kết nối cục bộ được override thủ công.

## Kiểm tra

- `flutter analyze`: 0 issues.
- `flutter test --coverage --reporter expanded`: **4.118 passed**, log `.country-all-tests-verified.log`, coverage cục bộ `coverage/lcov.info`. Không bỏ qua bài lỗi; đã sửa test alias để kiểm tra đúng dữ liệu CLDR và sửa query loại hẳn key country không hợp lệ.
- 303 bài core/geo + Community đã đạt ở đợt chạy chọn lọc; 33 bài geo/model cuối đạt sau bổ sung kiểm tra runtime aliases và scope memory.
- Android API 35, plugin/assets thật: **4 passed**, log `.country-android-native-tests.log`. Bài mới mở Community variant, bàn phím, tìm Hoa Kỳ bằng alias, chọn Germany trong Tất cả, trả DE và giữ preference JP. Activity tổng hợp chỉ nằm trong harness kiểm thử; không gọi Riot/Community và không phải E2E đã đăng nhập.
- Công cụ l10n **35 tests passed**, analyze 0; sửa UTF-8 khi đọc stdout formatter trên Windows, tái sinh parity bằng đúng chuỗi Unicode (có tiếng Việt/CJK/Arabic/emoji), kiểm tra byte-stable và `dart format` 698 file không đổi.
- ARB validator 0 errors/0 warnings; extract/parity byte-stable. Bốn message mới được viết vào ARB, gen-l10n; không phải dịch đủ 18 UI locale.
- Bộ sinh CLDR online đạt; offline sinh lại toàn bộ asset/generated tables không đổi byte. Nội dung nguồn/availability bảng quốc gia không thay đổi ở đợt này.

## Còn mở

COUNTRIES: onboarding, bảng provenance/chi tiết trạng thái, mismatch banner và detectedAt/refresh định kỳ. I18N W2–W7, ma trận thiết bị/RTL toàn app, Community badge/unread, moderation và cấu hình release/operator còn xem `COMPLETION_STATUS.md`. Chưa kiểm chứng signed-in Riot/Community E2E hoặc iOS.

Emulator đã được mở có cửa sổ theo yêu cầu chủ dự án; giữ dữ liệu QA riêng, không xóa AVD gốc. Artifact và QA release mới sẽ được ghi trong `COMPLETION_STATUS.md`; checkpoint APK cũ không được dùng làm bằng chứng cho UI mới.
