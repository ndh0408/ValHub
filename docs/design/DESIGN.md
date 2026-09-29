# Thiết kế giao diện ValVN (Figma)

File Figma: https://www.figma.com/design/AwxGtJGhawAIv4xqapRc1f
Ảnh tổng quan: `figma-screens.png` (Hệ thống thiết kế, Cửa hàng, Hồ sơ, Battle Pass, Trận hiện tại, Bộ sưu tập, Cài đặt).

## Token màu

> Cập nhật 2026-09 theo ngôn ngữ ValBuddy (`competitors/README.md`): nền **đen tuyệt đối** #000, thẻ gần đen
> #141416 (s1), #1F1F23 (s2), rãnh #2C2C31, chữ phụ xám hệ thống #8E8E93; chủ đề Sáng kiểu hệ thống iOS
> (#F2F2F7 / thẻ trắng / chữ phụ #636366). Tiêu đề tab dùng Be Vietnam Pro ExtraBold 32 (không dùng Anton);
> Anton chỉ còn cho số lớn/tên map. Bảng dưới là token Figma gốc (navy giữ làm màu nhấn `deepNavy`).

| Token | Hex | Dùng cho |
|---|---|---|
| bg | #0F1923 | Nền màn hình |
| s1 | #1A2733 | Thẻ, hàng danh sách |
| s2 | #243442 | Thẻ lồng, chip tài khoản, hàng "BẠN" |
| red | #FF4655 | Màu chủ đạo, tab đang chọn, nút chính, tiến độ |
| text | #ECE8E1 | Chữ chính |
| muted | #8B9BA8 | Chữ phụ, nhãn |
| green | #3DDC97 | Thắng, RR tăng, "Đang diễn ra" |
| Tuyển Chọn / Sang Chảnh / Cao Cấp / Độc Quyền / Siêu Cấp | #5A9FE2 / #009587 / #D1548D / #F5955B / #FAD663 | Màu độ hiếm skin |

## Chữ

- Tiêu đề màn hình: Anton 34, tên map/số lớn: Anton 34–60.
- Nội dung: Be Vietnam Pro — Bold 17–20 (tên skin, tiêu đề mục), SemiBold 13–14, Medium 11–13 (phụ).
- Nhãn nhỏ viết HOA, giãn chữ 4–8%.

## Mẫu thành phần

- Tiêu đề màn hình: tiêu đề Anton bên trái, chip tài khoản (avatar tròn gradient đỏ + Riot ID) bên phải.
- Ví: pill nền s1, chấm màu tiền tệ + số + mã tiền tệ.
- Phân đoạn (theo ValBuddy): mỗi mục là một pill xám (s2); pill đỏ đặc chữ trắng trượt sang mục được chọn
  (250 ms, easeOutCubic), rung nhẹ khi đổi; chấm đỏ báo Chợ Đêm mới. Dải ghim phía trên danh sách dùng nền
  mờ (blur 18) — chỉ cho thanh nhỏ cố định, không phủ cả danh sách.
- Thanh tab: viên nang nổi, mờ trong suốt, tách khỏi mép dưới; mục đang chọn nằm trong pill đỏ nhạt với icon +
  nhãn đỏ (`FloatingNavBar`, nhận bao nhiêu tab cũng được).
- Đếm ngược: pill có vòng tròn thời gian còn lại của chu kỳ (làm mới cửa hàng, Chợ Đêm, bundle, hết màn).
- Lọc/sắp xếp: ô tìm kiếm dạng pill, chip lọc bo tròn (chấm màu độ hiếm), nút "Sắp xếp: Độ hiếm"
  mở action sheet (iOS) / bottom sheet (Android). Lựa chọn được nhớ theo từng màn hình.
- Trạng thái trống/lỗi: icon trong đĩa tô màu 12%, tiêu đề đậm, mô tả muted, nút hành động.
- Hộp thoại xác nhận: CupertinoAlertDialog trên iOS, AlertDialog Material 3 trên Android; hành động
  nguy hiểm màu đỏ.
- Chủ đề Sáng: mọi màu chữ đạt WCAG AA (≥ 4,5:1) trên nền #F4F2EE và thẻ trắng; thẻ có viền mảnh;
  màu độ hiếm/rank dùng làm chữ được làm đậm tự động (`legibleAccent`).
- Thẻ skin: bo 16, gradient màu độ hiếm (35%) → s1, viền màu độ hiếm 35%, nhãn độ hiếm có hình thoi, tên Bold 17, giá VP, ảnh skin bên phải.
- Thẻ trận: dải màu kết quả 4px bên trái, avatar đặc vụ, "Map · Thắng/Thua", tỉ số Anton tô màu kết quả, K/D/A, ±RR.
- Thanh tiến độ: cao 6, nền #2E3F4E, phần đầy màu đỏ (hoàn thành: muted).
- Cột mốc hằng ngày: hình thoi đỏ/xám.
- Trận hiện tại: phần đầu gradient teal → nền, pill "Đang diễn ra", tên map Anton, tỉ số lớn xanh–đỏ, hàng người chơi (hàng của bạn viền đỏ + huy hiệu "BẠN"), người ẩn danh hiện "Người chơi ẩn danh" chữ muted, nút "Rời trận" viền đỏ.
- Thanh điều hướng: nền #131E29, viền trên 6% trắng, mục đang chọn màu đỏ.
- Bộ sưu tập: thẻ đang trang bị (gradient tím → đỏ, tên thẻ Anton), nhóm "TRANG BỊ" dạng danh sách
  có icon màu + giá trị hiện tại + ›, lưới 2 cột "DUYỆT BỘ SƯU TẬP" (hình thoi màu + tên + số món),
  thẻ "Giá trị bộ sưu tập" viền vàng với số VP Anton màu vàng.
- Cài đặt: nhãn nhóm viết HOA muted; nhóm nền s1 bo 16, hàng ngăn bằng viền 6% trắng; hàng tài khoản
  có dải đỏ 4px cho tài khoản đang dùng + ✓, huy hiệu vàng "Đăng nhập lại"; "+ Thêm tài khoản" chữ đỏ;
  công tắc bật màu đỏ, tắt #2E3F4E.

## Trang con, sheet và hộp thoại (2026-09, `core/ui/sub_page.dart`)

- **Trang con** (mọi màn đẩy từ một tab): `SubPageScaffold` — nút quay lại, tiêu đề lớn Be Vietnam Pro
  ExtraBold 28 bên trái (một bậc nhỏ hơn tiêu đề tab), phụ đề muted; khi cuộn, tiêu đề lớn trôi đi và
  tiêu đề nhỏ 17 hiện trên thanh. Nội dung có ảnh (map, bundle, thẻ người chơi) dùng hero tràn viền cao
  ~220, thu gọn dưới thanh, lớp phủ gradient (đen 45% ở trên cho thanh trạng thái → trong suốt → màu nền
  ở dưới); nút trên ảnh nằm trong vòng tròn đen 38%. Thanh lọc/tìm kiếm ghim dùng `GlassBar`.
  Hành động chính cố định ở đáy: `SubPageBottomBar` (viền mảnh trên, chừa vùng an toàn).
- **Sheet**: `showValSheet` — tay nắm, tiêu đề đậm 20 bên trái + phụ đề muted, nút đóng tròn nền s2 bên
  phải (kiểu "Game Details" của ValBuddy); vừa nội dung (≤ 90%) hoặc kéo được với danh sách dài.
- **Hộp thoại xác nhận**: `showConfirmDialog` (Cupertino trên iOS, Material 3 trên Android), hành động
  có hình phạt màu đỏ và luôn cần xác nhận.
- **Giá VND ước tính**: chữ nhỏ muted "≈ 268.000 ₫" cạnh giá VP (quy đổi theo gói nạp lợi nhất ở
  Việt Nam, nguồn + ngày trong sheet giải thích; tắt được trong Cài đặt).
- **Giờ địa phương**: cạnh mọi đếm ngược có giờ thật theo múi giờ máy, 24 giờ, thứ tiếng Việt
  ("Làm mới lúc 07:00 ngày mai", "Kết thúc 23:59 thứ Hai 06/10").
- **Tìm kiếm**: không phân biệt dấu/hoa thường ("thuong gioi" tìm ra "Thượng Giới").
