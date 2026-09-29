# ValVN — Kiến trúc thông tin (quyết định chốt, 29/09/2026)

Mục tiêu: gọn hơn ValBuddy, đủ hơn Daily Val, "thông minh" — màn đầu tiên đã trả lời
được câu hỏi người chơi hay hỏi nhất mà không cần bấm.

## Thanh tab: 5 tab (bỏ 6 tab)

| # | Tab | Nội dung |
|---|---|---|
| 0 | **Trang chủ** (mới) | Bảng điều khiển thông minh (xem bên dưới) |
| 1 | **Cửa hàng** | Hằng ngày · Chợ Đêm · Phụ kiện · Bundle; Wishlist + Danh mục (icon trái tim ở header) |
| 2 | **Cộng đồng** (giữa, nhấn mạnh) | Bảng tin · Tìm đồng đội · Xếp hạng skin (đánh giá kiểu Daily Val) |
| 3 | **Bộ sưu tập** | Trang bị (thẻ, danh hiệu, vũ khí, cảm xúc, bộ trang bị), duyệt bộ sưu tập, giá trị |
| 4 | **Hồ sơ** | Rank, phong độ, lịch sử đấu, RR theo ngày, máy tính lên rank, **Battle Pass**, Tổ đội & hàng chờ, Bạn bè & trò chuyện; ⚙ **Cài đặt** ở góc phải header |

- **Battle Pass** không còn là tab: thẻ tiến độ trên Trang chủ + mục trong Hồ sơ, mở
  trang đầy đủ (route `/battlepass` giữ nguyên, deep link cũ vẫn chạy).
- **Cài đặt** không còn là tab: nút ⚙ trên header Hồ sơ (và Trang chủ), route
  `/settings` giữ nguyên; thông báo đẩy trỏ vào settings vẫn chạy.
- Chip tài khoản ở mọi header giữ nguyên (chuyển tài khoản nhanh, thấy trạng thái
  trực tuyến).

## Trang chủ — bảng điều khiển thông minh

Thứ tự theo mức độ cần thiết, mỗi thẻ bấm vào mở trang chi tiết; thẻ nào không có dữ
liệu thì ẩn (không hiện ô trống):

1. **Trận hiện tại** (chỉ khi đang chọn đặc vụ / trong trận / đang tìm trận) — nổi
   lên đầu, có tỉ số trực tiếp.
2. **Cửa hàng hôm nay**: dải 4 skin nhỏ + đếm ngược làm mới; nhãn "Có skin trong
   wishlist!" nếu trùng; Chợ Đêm nếu đang mở (giảm giá cao nhất).
3. **Rank & phong độ**: rank hiện tại + RR, RR hôm nay (±), chuỗi thắng/thua, ước
   tính số trận lên rank tiếp theo.
4. **Battle Pass**: cấp n/55, XP cần mỗi ngày, số ngày còn lại, nhiệm vụ tuần sắp
   xong.
5. **Bạn bè đang chơi**: avatar những người đang trong trận/tìm trận (bấm → Bạn bè).
6. **Cộng đồng**: tin tìm đồng đội phù hợp rank của bạn (2 tin mới nhất) + skin hot
   trong tuần.
7. **Tài khoản khác**: tóm tắt các tài khoản còn lại (trực tuyến? cửa hàng có skin
   wishlist?) — dành cho người có nhiều acc.
8. **Trạng thái máy chủ** (chỉ khi có bảo trì/sự cố ở khu vực AP).

Cá nhân hóa: người dùng có thể ẩn/sắp xếp lại thẻ (giữ trong Prefs).

## Pháp lý (gọn như các app khác)

- Bỏ trang "Giấy phép phần mềm" khỏi app (file `LICENSE` trong repo giữ nguyên; dòng
  bản quyền "© 2026 Nguyễn Đức Huy" ở cuối trang Giới thiệu là đủ).
- Cài đặt → một dòng **"Giới thiệu & pháp lý"** ở cuối, bên trong: Chính sách quyền
  riêng tư, Điều khoản sử dụng, Tiêu chuẩn cộng đồng, Thông báo pháp lý (Riot), Thư
  viện bên thứ ba, Liên hệ.
- Màn chào mừng giữ một dòng nhỏ đồng ý Điều khoản & Chính sách (Apple 1.2 cho app có
  nội dung người dùng).

## Quy tắc chung cho mọi trang con

Header nhất quán (tiêu đề lớn thu gọn khi cuộn, hoặc sheet có nút đóng), ảnh hero khi
nội dung có ảnh, skeleton giống bố cục thật, trạng thái trống/lỗi có hành động, kéo để
làm mới, Hero transition từ danh sách vào chi tiết, 60 fps, không tràn ở 360 dp/chữ
200%, sáng + tối, iOS + Android.
