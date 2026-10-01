# VanHub — đăng nhập và kết nối Riot, 01/10/2026

Đợt này tiếp tục COUNTRIES P1/P2 sau checkpoint `12b0bbc`. Chưa nghiệm thu toàn bộ dự án; các mục còn mở nằm trong [COMPLETION_STATUS.md](COMPLETION_STATUS.md).

## Hành vi đã triển khai

- Account lưu thêm `detectedAt` và lựa chọn giữ thủ công theo đúng cặp `manual/detected`. Dữ liệu cũ không có ngày kiểm tra vẫn đọc được và được kiểm tra ở lần re-auth kế tiếp.
- Re-auth kiểm tra riot-geo khi lần xác định thành công đã cũ ít nhất 7 ngày. Không thêm cookie PUT riêng để kiểm tra định kỳ, không gọi thêm khi token đang được dùng từ cache. Lỗi geo tạm thời giữ kết nối đã biết và thử lại ở lần re-auth sau.
- Auto cập nhật region/shard từ Riot. Manual giữ máy chủ người dùng chọn và cập nhật riêng detected region. Một cặp khác biệt mới phát `SessionRegionMismatch`; Trang chủ cho chọn tự động/giữ thủ công. Giữ thủ công không làm mất cảnh báo cho một cặp mới.
- 401 sau re-auth tại khu vực thủ công khác Riot không tự đánh dấu cookies chết, kể cả lần báo lỗi tiếp theo với cùng token. Re-auth thực sự xác nhận cookies chết vẫn yêu cầu đăng nhập lại.
- Lỗi geo mạng/429/5xx/Cloudflare khi đăng nhập không bỏ mất identity, cookies và token bootstrap. Tài khoản mới chưa xác định khu vực mở bộ chọn kết nối; request game thông thường vẫn bị chặn đến khi có vùng hợp lệ. Đăng nhập lại giữ vùng đã biết khi geo tạm thời không trả kết quả.
- Bộ chọn kết nối có nút kiểm tra lại và thời điểm kiểm tra gần nhất. Nút gọi endpoint riot-geo cố định; không suy ra kết nối từ quốc gia và không tự quét các máy chủ game.
- Lưu thủ công khác Riot yêu cầu xác nhận trước request. Kiểm tra chỉ GET XP của chính tài khoản trên host ứng viên trong allowlist, không theo redirect. 401/BAD_CLAIMS chỉ làm mới token một lần; token/host ứng viên không trở thành kết nối đã lưu trước khi người dùng đồng ý.
- Kết quả xác minh có ba trạng thái: verified; rejected (sai subject/JSON 400–404); unverified (401 sau retry hoặc lỗi dịch vụ). Unverified cần hộp xác nhận riêng, không được hiện như đã xác minh thành công. Hủy và lỗi TLS không được coi là unverified để lưu.
- Sheet dùng root navigator để thanh tab không che lựa chọn. Dropdown khu vực đã sửa tràn ngang và kiểm tra ở 360 dp/chữ 200%. Quốc gia chỉ gợi ý vùng cho lựa chọn thủ công; danh sách hiển thị region thay vì PD shard (LATAM/BR không bị hiện như NA).

## Kiểm tra

- Full Flutter suite: **4.176 passed** (`.vanhub-geo-all-tests.log`), thêm 33 trường hợp so với checkpoint 4.143.
- Flutter analyze: **0 issues** (`.vanhub-geo-analyze.log`).
- Các test mới dùng API giả: migration/ngưỡng 7 ngày/cache token, outage/retry, unknown region, mismatch event/acknowledgement, logout trong lúc geo đang chạy, đăng nhập khi geo lỗi, hết hạn token và xác minh ứng viên, 401 retry/400–404/429/5xx/HTML/TLS/cancellation, confirmation và chữ lớn.
- ARB validator: **0 errors, 0 warnings**. Extractor đã đặt các khóa bổ sung trước phần cơ học đúng thứ tự tái sinh; so JSON trước/sau xác nhận **0 giá trị hoặc metadata thay đổi**, chỉ đổi vị trí khóa. Không coi 18 bộ tên quốc gia là 18 bản dịch UI.
- `extract --check` và `parity --check`: đạt, vẫn ghi rõ 52 structural members còn mở. Sau đổi thứ tự catalog, gen-l10n/analyze và 7 test ARB/region-picker chạy lại đạt.
- APK cuối: build release **119,2 MB**, SHA-256 `CB2EF1D4D3A8DF09785B7578591B837AEA2CF35F5778FD965CD6CEE47118A115`. `apksigner verify` đạt, chứng thư **Android Debug**, artifact QA chưa phải bản ký để upload store.
- APK cuối trên QA `emulator-5582`: **10 public-flow cases đạt**, logcat không có fatal/unhandled exception trong lượt chạy. Kết quả cục bộ: `dist/review/emulator/vanhub-geo-release-smoke/results.json`.
- Emulator có cửa sổ `emulator-5580`: cài đè thành công, ba tài khoản cũ vẫn hiện metadata; mở kết nối read-only và xác nhận nút kiểm tra lại có trong accessibility tree, thanh tab không có trong sheet. Không nhấn kiểm tra/lưu/chuyển tài khoản. Ảnh/XML riêng nằm ở `dist/review/private-account-ui/geo-connections`, không đưa lên Git.
- Source và báo cáo thuộc đợt commit kết nối tiếp sau `12b0bbc`; không dùng hash `681d213` để review các thay đổi của đợt này. Đối chiếu commit nhánh mặc định bằng `git log -1`.

## Giới hạn và phần tiếp theo

Các kiểm thử trên không chứng minh Riot region transfer thật, đăng nhập/đăng xuất chủ động trên các tài khoản thật, hoặc dữ liệu cập nhật ngay trong VALORANT PC. Không tự thay đổi quốc gia, tài khoản hay khu vực thủ công trên emulator có tài khoản của chủ dự án.

COUNTRIES vẫn còn onboarding, provenance/trạng thái đầy đủ, cập nhật cấu hình geo và nối các yêu cầu quốc tế hóa. Các phần I18N W2–W7, thiết bị/a11y toàn app, Community/notifications và iOS/release còn mở, không đánh dấu hoàn thành bằng một đợt sửa kết nối.
