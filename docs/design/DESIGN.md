# Thiết kế giao diện ValVN (Figma)

File Figma: https://www.figma.com/design/AwxGtJGhawAIv4xqapRc1f
Ảnh tổng quan: `figma-screens.png` (Hệ thống thiết kế, Cửa hàng, Hồ sơ, Battle Pass, Trận hiện tại, Bộ sưu tập, Cài đặt).

## Token màu (Figma collection "ValVN Tokens")

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
- Phân đoạn: nền s1 bo 12, mục đang chọn nền đỏ chữ trắng, chấm đỏ báo Chợ Đêm mới.
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
