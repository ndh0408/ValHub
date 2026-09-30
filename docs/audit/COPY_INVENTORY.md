# WP-COPY — Kiểm kê chuỗi nguồn

Ngày 30/09/2026, sau khi hoàn tất WP-COPY. Dẫn chiếu dòng ở trạng thái cuối gói. Danh sách dưới ghi mọi literal trong 20 file chuỗi ban đầu, file lời lỗi Cộng đồng mới và toàn bộ cây pháp lý; bao gồm cả khóa enum/UUID để không bỏ sót map và nhánh fallback. Literal đứng cạnh nhau là các phần của cùng chuỗi Dart; placeholder được giữ nguyên trong mã nguồn. Phân loại phát hiện và quyết định sửa ở [AUDIT_COPY.md](AUDIT_COPY.md).

| File | Số literal (gồm khóa/siêu dữ liệu) |
|---|---:|
| `lib/core/domain/competitive/competitive_strings.dart` | 26 |
| `lib/core/domain/economy/economy_strings.dart` | 14 |
| `lib/core/domain/loadout/loadout_strings.dart` | 4 |
| `lib/core/l10n/account_strings.dart` | 59 |
| `lib/core/l10n/auth_strings.dart` | 25 |
| `lib/core/l10n/common_strings.dart` | 123 |
| `lib/core/l10n/community_error_strings.dart` | 10 |
| `lib/core/l10n/content_strings.dart` | 129 |
| `lib/core/l10n/notification_strings.dart` | 12 |
| `lib/features/battlepass/battlepass_strings.dart` | 85 |
| `lib/features/collection/collection_strings.dart` | 170 |
| `lib/features/community/community_strings.dart` | 627 |
| `lib/features/home/home_strings.dart` | 92 |
| `lib/features/live_game/live_game_strings.dart` | 78 |
| `lib/features/profile/profile_strings.dart` | 153 |
| `lib/features/settings/legal/legal_strings.dart` | 18 |
| `lib/features/settings/settings_strings.dart` | 165 |
| `lib/features/skin_detail/skin_detail_strings.dart` | 18 |
| `lib/features/social/social_strings.dart` | 162 |
| `lib/features/store/store_strings.dart` | 74 |
| `lib/features/wishlist/wishlist_strings.dart` | 67 |
| `lib/features/settings/legal/community_guidelines.dart` | 83 |
| `lib/features/settings/legal/legal_document.dart` | 13 |
| `lib/features/settings/legal/legal_documents.dart` | 8 |
| `lib/features/settings/legal/legal_info.dart` | 9 |
| `lib/features/settings/legal/legal_notice.dart` | 45 |
| `lib/features/settings/legal/privacy_policy.dart` | 391 |
| `lib/features/settings/legal/terms_of_service.dart` | 257 |

| File:dòng | Phân loại sau rà | Literal nguồn |
|---|---|---|
| `lib/core/domain/competitive/competitive_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Người chơi ẩn danh'` |
| `lib/core/domain/competitive/competitive_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Người chơi'` |
| `lib/core/domain/competitive/competitive_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Thắng'` |
| `lib/core/domain/competitive/competitive_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Thua'` |
| `lib/core/domain/competitive/competitive_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Hòa'` |
| `lib/core/domain/competitive/competitive_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'–'` |
| `lib/core/domain/competitive/competitive_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Không ước tính được'` |
| `lib/core/domain/competitive/competitive_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đang xử lý trận đấu…'` |
| `lib/core/domain/competitive/competitive_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $n trận phân hạng'` |
| `lib/core/domain/competitive/competitive_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'Hạ toàn đội'` |
| `lib/core/domain/competitive/competitive_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'Spike phát nổ'` |
| `lib/core/domain/competitive/competitive_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Gỡ Spike'` |
| `lib/core/domain/competitive/competitive_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'Hết giờ'` |
| `lib/core/domain/competitive/competitive_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Đầu hàng'` |
| `lib/core/domain/competitive/competitive_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Tấn công'` |
| `lib/core/domain/competitive/competitive_strings.dart:37` | Nội dung/placeholder — đã rà theo VOICE | `'Phòng thủ'` |
| `lib/core/domain/competitive/competitive_strings.dart:42` | Nội dung/placeholder — đã rà theo VOICE | `'Sắt'` |
| `lib/core/domain/competitive/competitive_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'Đồng'` |
| `lib/core/domain/competitive/competitive_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Bạc'` |
| `lib/core/domain/competitive/competitive_strings.dart:45` | Nội dung/placeholder — đã rà theo VOICE | `'Vàng'` |
| `lib/core/domain/competitive/competitive_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Bạch Kim'` |
| `lib/core/domain/competitive/competitive_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'Kim Cương'` |
| `lib/core/domain/competitive/competitive_strings.dart:48` | Nội dung/placeholder — đã rà theo VOICE | `'Thượng Nhân'` |
| `lib/core/domain/competitive/competitive_strings.dart:49` | Nội dung/placeholder — đã rà theo VOICE | `'Bất Tử'` |
| `lib/core/domain/competitive/competitive_strings.dart:55` | Nội dung/placeholder — đã rà theo VOICE | `'Radiant'` |
| `lib/core/domain/competitive/competitive_strings.dart:58` | Nội dung/placeholder — đã rà theo VOICE | `'${_e5Divisions[i ~/ 3]} ${i % 3 + 1}'` |
| `lib/core/domain/economy/economy_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'cửa hàng hằng ngày'` |
| `lib/core/domain/economy/economy_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm'` |
| `lib/core/domain/economy/economy_strings.dart:11` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'bundle'` |
| `lib/core/domain/economy/economy_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'bundle $name'` |
| `lib/core/domain/economy/economy_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Đang có trong $place!'` |
| `lib/core/domain/economy/economy_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Giá niêm yết'` |
| `lib/core/domain/economy/economy_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Giá đã thấy trong cửa hàng'` |
| `lib/core/domain/economy/economy_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Giá từ bảng giá Riot'` |
| `lib/core/domain/economy/economy_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Giá ước tính theo phiên bản'` |
| `lib/core/domain/economy/economy_strings.dart:22` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa rõ giá'` |
| `lib/core/domain/economy/economy_strings.dart:25` | Nội dung/placeholder — đã rà theo VOICE | `'Giá trị bộ sưu tập'` |
| `lib/core/domain/economy/economy_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Tổng giá trị wishlist'` |
| `lib/core/domain/economy/economy_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Không tính skin phần thưởng'` |
| `lib/core/domain/economy/economy_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Có giá ước tính (≈)'` |
| `lib/core/domain/loadout/loadout_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Không thể lưu trang bị'` |
| `lib/core/domain/loadout/loadout_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Riot chưa lưu thay đổi của bạn nên trang bị vẫn như cũ. Hãy thử lại.'` |
| `lib/core/domain/loadout/loadout_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Thay đổi này không áp dụng được cho trang bị hiện tại.'` |
| `lib/core/domain/loadout/loadout_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Bộ trang bị $n'` |
| `lib/core/l10n/account_strings.dart:3` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản'` |
| `lib/core/l10n/account_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'$switcherTitle ($count/$max)'` |
| `lib/core/l10n/account_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Chạm để chuyển tài khoản'` |
| `lib/core/l10n/account_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm tài khoản ($count/$max)'` |
| `lib/core/l10n/account_strings.dart:11` | Nội dung/placeholder — đã rà theo VOICE | `'TÀI KHOẢN ($count/$max)'` |
| `lib/core/l10n/account_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Đã đạt tối đa $max tài khoản.'` |
| `lib/core/l10n/account_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa chuyển được tài khoản. Hãy thử lại.'` |
| `lib/core/l10n/account_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Chuyển sang $account'` |
| `lib/core/l10n/account_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Cần đăng nhập lại'` |
| `lib/core/l10n/account_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Đang dùng'` |
| `lib/core/l10n/account_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa tài khoản'` |
| `lib/core/l10n/account_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa $account khỏi thiết bị này? Wishlist của tài khoản vẫn được giữ lại.'` |
| `lib/core/l10n/account_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng xuất tất cả tài khoản'` |
| `lib/core/l10n/account_strings.dart:22` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng xuất và xóa mọi tài khoản khỏi thiết bị này? Wishlist vẫn được giữ lại.'` |
| `lib/core/l10n/account_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $level'` |
| `lib/core/l10n/account_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Trực tuyến'` |
| `lib/core/l10n/account_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Ngoại tuyến'` |
| `lib/core/l10n/account_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chọn đặc vụ'` |
| `lib/core/l10n/account_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'Đang đấu'` |
| `lib/core/l10n/account_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa rõ trạng thái'` |
| `lib/core/l10n/account_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'$count đang trực tuyến'` |
| `lib/core/l10n/account_strings.dart:35` | Nội dung/placeholder — đã rà theo VOICE | `'Thông tin đăng nhập'` |
| `lib/core/l10n/account_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa lưu thông tin đăng nhập'` |
| `lib/core/l10n/account_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ lưu trên thiết bị này, được khóa an toàn. Dùng để xem lại hoặc điền '` |
| `lib/core/l10n/account_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'nhanh khi bạn đăng nhập lại.'` |
| `lib/core/l10n/account_strings.dart:40` | Nội dung/placeholder — đã rà theo VOICE | `'Tên đăng nhập Riot'` |
| `lib/core/l10n/account_strings.dart:41` | Nội dung/placeholder — đã rà theo VOICE | `'Mật khẩu'` |
| `lib/core/l10n/account_strings.dart:42` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện mật khẩu'` |
| `lib/core/l10n/account_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'Ẩn mật khẩu'` |
| `lib/core/l10n/account_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Sao chép tên đăng nhập'` |
| `lib/core/l10n/account_strings.dart:45` | Nội dung/placeholder — đã rà theo VOICE | `'Sao chép mật khẩu'` |
| `lib/core/l10n/account_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Đã lưu thông tin đăng nhập'` |
| `lib/core/l10n/account_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa thông tin đăng nhập'` |
| `lib/core/l10n/account_strings.dart:48` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa thông tin'` |
| `lib/core/l10n/account_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa tên đăng nhập và mật khẩu đã lưu của tài khoản này?'` |
| `lib/core/l10n/account_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Điền tài khoản đã lưu'` |
| `lib/core/l10n/account_strings.dart:54` | Nội dung/placeholder — đã rà theo VOICE | `'Điền tài khoản đã lưu'` |
| `lib/core/l10n/account_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn tài khoản để điền vào trang đăng nhập Riot'` |
| `lib/core/l10n/account_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'Đã điền xong. Hãy bấm Đăng nhập.'` |
| `lib/core/l10n/account_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Trang đăng nhập chưa tải xong. Đợi một chút rồi thử lại.'` |
| `lib/core/l10n/account_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Người chơi'` |
| `lib/core/l10n/account_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'PC'` |
| `lib/core/l10n/account_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'PlayStation'` |
| `lib/core/l10n/account_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'Xbox'` |
| `lib/core/l10n/account_strings.dart:68` | Nội dung/placeholder — đã rà theo VOICE | `'Châu Á - Thái Bình Dương'` |
| `lib/core/l10n/account_strings.dart:69` | Nội dung/placeholder — đã rà theo VOICE | `'Bắc Mỹ'` |
| `lib/core/l10n/account_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Châu Âu'` |
| `lib/core/l10n/account_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'Hàn Quốc'` |
| `lib/core/l10n/account_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Mỹ Latinh'` |
| `lib/core/l10n/account_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'Brazil'` |
| `lib/core/l10n/account_strings.dart:78` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ap'` |
| `lib/core/l10n/account_strings.dart:79` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'na'` |
| `lib/core/l10n/account_strings.dart:80` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'eu'` |
| `lib/core/l10n/account_strings.dart:81` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'kr'` |
| `lib/core/l10n/account_strings.dart:82` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'latam'` |
| `lib/core/l10n/account_strings.dart:83` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'br'` |
| `lib/core/l10n/account_strings.dart:84` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa rõ máy chủ'` |
| `lib/core/l10n/account_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'$count/$max tài khoản'` |
| `lib/core/l10n/account_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa tài khoản hoặc sửa thông tin đăng nhập trong Cài đặt.'` |
| `lib/core/l10n/auth_strings.dart:3` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng nhập Riot'` |
| `lib/core/l10n/auth_strings.dart:4` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng nhập bằng tài khoản Riot'` |
| `lib/core/l10n/auth_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đăng nhập trên trang chính thức của Riot. ValVN chỉ lưu mật khẩu khi '` |
| `lib/core/l10n/auth_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'bạn tự chọn lưu thông tin đăng nhập; dữ liệu đăng nhập và thông tin đã '` |
| `lib/core/l10n/auth_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'lưu chỉ nằm trên thiết bị của bạn.'` |
| `lib/core/l10n/auth_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy bật "Duy trì đăng nhập" để không phải đăng nhập lại.'` |
| `lib/core/l10n/auth_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Nếu đăng nhập bằng Google hoặc Facebook không được, hãy dùng tên '` |
| `lib/core/l10n/auth_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'đăng nhập Riot.'` |
| `lib/core/l10n/auth_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tải tài khoản…'` |
| `lib/core/l10n/auth_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chuẩn bị trang đăng nhập…'` |
| `lib/core/l10n/auth_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Không thể hoàn tất đăng nhập'` |
| `lib/core/l10n/auth_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Riot chưa xác nhận đăng nhập của bạn. Hãy thử lại.'` |
| `lib/core/l10n/auth_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đã từ chối lần đăng nhập này. Hãy thử lại.'` |
| `lib/core/l10n/auth_strings.dart:22` | Nội dung/placeholder — đã rà theo VOICE | `'Lần đăng nhập này không hợp lệ. Hãy đăng nhập lại từ đầu.'` |
| `lib/core/l10n/auth_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'Không lưu được đăng nhập trên thiết bị này, nên bạn sẽ phải đăng nhập '` |
| `lib/core/l10n/auth_strings.dart:25` | Nội dung/placeholder — đã rà theo VOICE | `'lại khi hết hạn.'` |
| `lib/core/l10n/auth_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Không tải được trang đăng nhập của Riot. Kiểm tra mạng rồi thử lại.'` |
| `lib/core/l10n/auth_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản khác'` |
| `lib/core/l10n/auth_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn vừa đăng nhập một tài khoản khác với tài khoản cần đăng nhập lại. '` |
| `lib/core/l10n/auth_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm tài khoản này như một tài khoản mới?'` |
| `lib/core/l10n/auth_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm tài khoản mới'` |
| `lib/core/l10n/auth_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản này đã được thêm'` |
| `lib/core/l10n/auth_strings.dart:34` | Nội dung/placeholder — đã rà theo VOICE | `'Đã đăng nhập lại'` |
| `lib/core/l10n/auth_strings.dart:35` | Nội dung/placeholder — đã rà theo VOICE | `'Đã mở liên kết trong trình duyệt.'` |
| `lib/core/l10n/auth_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Trang chính thức · auth.riotgames.com'` |
| `lib/core/l10n/common_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'ValVN'` |
| `lib/core/l10n/common_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Trợ thủ VALORANT của bạn'` |
| `lib/core/l10n/common_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Trang chủ'` |
| `lib/core/l10n/common_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng'` |
| `lib/core/l10n/common_strings.dart:11` | Nội dung/placeholder — đã rà theo VOICE | `'Battle Pass'` |
| `lib/core/l10n/common_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng'` |
| `lib/core/l10n/common_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Bộ sưu tập'` |
| `lib/core/l10n/common_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Hồ sơ'` |
| `lib/core/l10n/common_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Cài đặt'` |
| `lib/core/l10n/common_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Thử lại'` |
| `lib/core/l10n/common_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Hủy'` |
| `lib/core/l10n/common_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'OK'` |
| `lib/core/l10n/common_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Đóng'` |
| `lib/core/l10n/common_strings.dart:22` | Nội dung/placeholder — đã rà theo VOICE | `'Xong'` |
| `lib/core/l10n/common_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Quay lại'` |
| `lib/core/l10n/common_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'Lưu'` |
| `lib/core/l10n/common_strings.dart:25` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa'` |
| `lib/core/l10n/common_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Xác nhận'` |
| `lib/core/l10n/common_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Sao chép'` |
| `lib/core/l10n/common_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Chia sẻ'` |
| `lib/core/l10n/common_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới'` |
| `lib/core/l10n/common_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm kiếm…'` |
| `lib/core/l10n/common_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Xem tất cả'` |
| `lib/core/l10n/common_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'Tải thêm'` |
| `lib/core/l10n/common_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Mở cài đặt'` |
| `lib/core/l10n/common_strings.dart:34` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng nhập lại'` |
| `lib/core/l10n/common_strings.dart:35` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa tìm kiếm'` |
| `lib/core/l10n/common_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ lọc'` |
| `lib/core/l10n/common_strings.dart:37` | Nội dung/placeholder — đã rà theo VOICE | `'Lọc'` |
| `lib/core/l10n/common_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Sắp xếp'` |
| `lib/core/l10n/common_strings.dart:41` | Nội dung/placeholder — đã rà theo VOICE | `'Sắp xếp: $option'` |
| `lib/core/l10n/common_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Độ hiếm'` |
| `lib/core/l10n/common_strings.dart:45` | Nội dung/placeholder — đã rà theo VOICE | `'Tên A–Z'` |
| `lib/core/l10n/common_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Vũ khí'` |
| `lib/core/l10n/common_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'Giá giảm dần'` |
| `lib/core/l10n/common_strings.dart:48` | Nội dung/placeholder — đã rà theo VOICE | `'Giá tăng dần'` |
| `lib/core/l10n/common_strings.dart:49` | Nội dung/placeholder — đã rà theo VOICE | `'Mới nhất'` |
| `lib/core/l10n/common_strings.dart:52` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tải…'` |
| `lib/core/l10n/common_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Kéo để làm mới'` |
| `lib/core/l10n/common_strings.dart:54` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có gì để xem'` |
| `lib/core/l10n/common_strings.dart:55` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có gì ở đây.'` |
| `lib/core/l10n/common_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Đã sao chép'` |
| `lib/core/l10n/common_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'Vật phẩm chưa rõ tên'` |
| `lib/core/l10n/common_strings.dart:58` | Nội dung/placeholder — đã rà theo VOICE | `'≈'` |
| `lib/core/l10n/common_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'–'` |
| `lib/core/l10n/common_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Cập nhật lúc $time'` |
| `lib/core/l10n/common_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Không có mạng — đang hiển thị bản đã lưu ($time).'` |
| `lib/core/l10n/common_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Có gì đó trục trặc. Hãy thử lại.'` |
| `lib/core/l10n/common_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Riot phản hồi quá lâu. Kiểm tra kết nối rồi thử lại.'` |
| `lib/core/l10n/common_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'Không kết nối được mạng. Kiểm tra Wi-Fi hoặc dữ liệu di động rồi thử lại.'` |
| `lib/core/l10n/common_strings.dart:75` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đang bận. Hãy thử lại sau ít phút.'` |
| `lib/core/l10n/common_strings.dart:77` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đang bận. Hãy thử lại sau $duration.'` |
| `lib/core/l10n/common_strings.dart:79` | Nội dung/placeholder — đã rà theo VOICE | `'Máy chủ VALORANT đang bảo trì. Hãy quay lại sau.'` |
| `lib/core/l10n/common_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng nhập Riot của bạn đã hết hạn. Hãy đăng nhập lại để tiếp tục.'` |
| `lib/core/l10n/common_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'Cần đăng nhập lại'` |
| `lib/core/l10n/common_strings.dart:83` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy nội dung này.'` |
| `lib/core/l10n/common_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đang gặp trục trặc. Hãy thử lại sau ít phút.'` |
| `lib/core/l10n/common_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'Không tải được thông tin skin, đặc vụ và bản đồ. Kiểm tra mạng rồi thử '` |
| `lib/core/l10n/common_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `'lại.'` |
| `lib/core/l10n/common_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa đăng nhập tài khoản nào.'` |
| `lib/core/l10n/common_strings.dart:93` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy màn hình này.'` |
| `lib/core/l10n/common_strings.dart:94` | Nội dung/placeholder — đã rà theo VOICE | `'Về Trang chủ'` |
| `lib/core/l10n/common_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Bảo trì máy chủ'` |
| `lib/core/l10n/common_strings.dart:98` | Nội dung/placeholder — đã rà theo VOICE | `'Sự cố máy chủ'` |
| `lib/core/l10n/common_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'vừa xong'` |
| `lib/core/l10n/common_strings.dart:102` | Nội dung/placeholder — đã rà theo VOICE | `'hôm qua'` |
| `lib/core/l10n/common_strings.dart:103` | Nội dung/placeholder — đã rà theo VOICE | `'Hôm nay'` |
| `lib/core/l10n/common_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'Hôm qua'` |
| `lib/core/l10n/common_strings.dart:105` | Nội dung/placeholder — đã rà theo VOICE | `'$n phút trước'` |
| `lib/core/l10n/common_strings.dart:106` | Nội dung/placeholder — đã rà theo VOICE | `'$n giờ trước'` |
| `lib/core/l10n/common_strings.dart:107` | Nội dung/placeholder — đã rà theo VOICE | `'$n ngày trước'` |
| `lib/core/l10n/common_strings.dart:108` | Nội dung/placeholder — đã rà theo VOICE | `'$n ngày'` |
| `lib/core/l10n/common_strings.dart:109` | Nội dung/placeholder — đã rà theo VOICE | `'$n giờ'` |
| `lib/core/l10n/common_strings.dart:110` | Nội dung/placeholder — đã rà theo VOICE | `'$n phút'` |
| `lib/core/l10n/common_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'$n giây'` |
| `lib/core/l10n/common_strings.dart:113` | Nội dung/placeholder — đã rà theo VOICE | `'ngày mai'` |
| `lib/core/l10n/common_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'hôm nay'` |
| `lib/core/l10n/common_strings.dart:115` | Nội dung/placeholder — đã rà theo VOICE | `'hằng ngày'` |
| `lib/core/l10n/common_strings.dart:118` | Nội dung/placeholder — đã rà theo VOICE | `'$time $day'` |
| `lib/core/l10n/common_strings.dart:122` | Nội dung/placeholder — đã rà theo VOICE | `'Thứ Hai'` |
| `lib/core/l10n/common_strings.dart:123` | Nội dung/placeholder — đã rà theo VOICE | `'Thứ Ba'` |
| `lib/core/l10n/common_strings.dart:124` | Nội dung/placeholder — đã rà theo VOICE | `'Thứ Tư'` |
| `lib/core/l10n/common_strings.dart:125` | Nội dung/placeholder — đã rà theo VOICE | `'Thứ Năm'` |
| `lib/core/l10n/common_strings.dart:126` | Nội dung/placeholder — đã rà theo VOICE | `'Thứ Sáu'` |
| `lib/core/l10n/common_strings.dart:127` | Nội dung/placeholder — đã rà theo VOICE | `'Thứ Bảy'` |
| `lib/core/l10n/common_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Chủ Nhật'` |
| `lib/core/l10n/common_strings.dart:132` | Nội dung/placeholder — đã rà theo VOICE | `'Giá quy đổi ước tính'` |
| `lib/core/l10n/common_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'Giá ước tính — chạm để xem cách tính'` |
| `lib/core/l10n/common_strings.dart:135` | Nội dung/placeholder — đã rà theo VOICE | `'Số tiền “≈ …” cạnh giá VP là ước tính, quy đổi theo gói VP có lợi '` |
| `lib/core/l10n/common_strings.dart:136` | Nội dung/placeholder — đã rà theo VOICE | `'nhất. Bạn trả bằng VP trong game; số tiền thật tùy gói nạp, kênh '` |
| `lib/core/l10n/common_strings.dart:137` | Nội dung/placeholder — đã rà theo VOICE | `'thanh toán, thuế và khuyến mãi lúc bạn mua.'` |
| `lib/core/l10n/common_strings.dart:139` | Nội dung/placeholder — đã rà theo VOICE | `'Gói có lợi nhất: $vp = $price'` |
| `lib/core/l10n/common_strings.dart:143` | Nội dung/placeholder — đã rà theo VOICE | `'Theo bảng giá gói VP ở khu vực $country'` |
| `lib/core/l10n/common_strings.dart:144` | Nội dung/placeholder — đã rà theo VOICE | `'Theo giá gói VP do bạn nhập'` |
| `lib/core/l10n/common_strings.dart:145` | Nội dung/placeholder — đã rà theo VOICE | `'Xem nguồn bảng giá'` |
| `lib/core/l10n/common_strings.dart:146` | Nội dung/placeholder — đã rà theo VOICE | `'Cập nhật bảng giá: $date'` |
| `lib/core/l10n/common_strings.dart:147` | Nội dung/placeholder — đã rà theo VOICE | `'Các gói VP'` |
| `lib/core/l10n/common_strings.dart:148` | Nội dung/placeholder — đã rà theo VOICE | `'Mở trang nguồn'` |
| `lib/core/l10n/common_strings.dart:149` | Nội dung/placeholder — đã rà theo VOICE | `'Nhập giá gói VP của bạn'` |
| `lib/core/l10n/common_strings.dart:150` | Nội dung/placeholder — đã rà theo VOICE | `'Sửa giá bạn đã nhập'` |
| `lib/core/l10n/common_strings.dart:151` | Nội dung/placeholder — đã rà theo VOICE | `'Ẩn giá quy đổi'` |
| `lib/core/l10n/common_strings.dart:152` | Nội dung/placeholder — đã rà theo VOICE | `'Đã ẩn giá quy đổi. Bật lại trong Cài đặt.'` |
| `lib/core/l10n/common_strings.dart:154` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có bảng giá đã xác minh cho khu vực của bạn. Nhập giá của một gói '` |
| `lib/core/l10n/common_strings.dart:155` | Nội dung/placeholder — đã rà theo VOICE | `'VP bạn từng mua để xem giá quy đổi ước tính.'` |
| `lib/core/l10n/common_strings.dart:158` | Nội dung/placeholder — đã rà theo VOICE | `'Giá gói VP của bạn'` |
| `lib/core/l10n/common_strings.dart:160` | Nội dung/placeholder — đã rà theo VOICE | `'Nhập số tiền bạn thực trả cho một gói VP (xem trong cửa hàng của game '` |
| `lib/core/l10n/common_strings.dart:161` | Nội dung/placeholder — đã rà theo VOICE | `'hoặc hóa đơn). ValVN dùng giá này để ước tính giá quy đổi cho mọi món '` |
| `lib/core/l10n/common_strings.dart:162` | Nội dung/placeholder — đã rà theo VOICE | `'đồ; giá chỉ lưu trên thiết bị này.'` |
| `lib/core/l10n/common_strings.dart:163` | Nội dung/placeholder — đã rà theo VOICE | `'Mã tiền tệ'` |
| `lib/core/l10n/common_strings.dart:164` | Nội dung/placeholder — đã rà theo VOICE | `'Ví dụ: VND, USD, EUR, JPY'` |
| `lib/core/l10n/common_strings.dart:165` | Nội dung/placeholder — đã rà theo VOICE | `'Số VP của gói'` |
| `lib/core/l10n/common_strings.dart:166` | Nội dung/placeholder — đã rà theo VOICE | `'Giá gói'` |
| `lib/core/l10n/common_strings.dart:167` | Nội dung/placeholder — đã rà theo VOICE | `'Lưu giá'` |
| `lib/core/l10n/common_strings.dart:168` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa giá đã nhập'` |
| `lib/core/l10n/common_strings.dart:170` | Nội dung/placeholder — đã rà theo VOICE | `'Nhập mã tiền tệ gồm 3 chữ cái, ví dụ VND hoặc USD.'` |
| `lib/core/l10n/common_strings.dart:171` | Nội dung/placeholder — đã rà theo VOICE | `'Nhập một số lớn hơn 0.'` |
| `lib/core/l10n/common_strings.dart:172` | Nội dung/placeholder — đã rà theo VOICE | `'Đã lưu giá gói VP của bạn.'` |
| `lib/core/l10n/common_strings.dart:173` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa giá bạn nhập.'` |
| `lib/core/l10n/common_strings.dart:175` | Nội dung/placeholder — đã rà theo VOICE | `'Ví dụ ước tính: $vp ≈ $price'` |
| `lib/core/l10n/common_strings.dart:179` | Nội dung/placeholder — đã rà theo VOICE | `'ValVN không được Riot Games xác nhận và không phản ánh quan điểm của '` |
| `lib/core/l10n/common_strings.dart:180` | Nội dung/placeholder — đã rà theo VOICE | `'Riot Games hay bất kỳ ai tham gia sản xuất hoặc quản lý các sản phẩm '` |
| `lib/core/l10n/common_strings.dart:181` | Nội dung/placeholder — đã rà theo VOICE | `'của Riot Games. Riot Games và mọi tài sản liên quan là thương hiệu hoặc '` |
| `lib/core/l10n/common_strings.dart:182` | Nội dung/placeholder — đã rà theo VOICE | `'thương hiệu đã đăng ký của Riot Games, Inc.'` |
| `lib/core/l10n/community_error_strings.dart:5` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'content_inappropriate'` |
| `lib/core/l10n/community_error_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa đăng được vì có từ ngữ không phù hợp. Hãy sửa nội dung rồi thử lại.'` |
| `lib/core/l10n/community_error_strings.dart:6` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'content_scam'` |
| `lib/core/l10n/community_error_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng không cho phép quảng cáo mua bán tài khoản, cày thuê hay để lại số điện thoại. Hãy bỏ những nội dung này rồi thử lại.'` |
| `lib/core/l10n/community_error_strings.dart:7` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'content_too_complex'` |
| `lib/core/l10n/community_error_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Nội dung có quá nhiều ký tự rời rạc. Hãy viết gọn hơn rồi thử lại.'` |
| `lib/core/l10n/community_error_strings.dart:9` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'account_banned'` |
| `lib/core/l10n/community_error_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản này đã bị khóa quyền dùng Cộng đồng. Nếu cho rằng có nhầm lẫn, hãy liên hệ ValVN trong Giới thiệu & pháp lý.'` |
| `lib/core/l10n/community_error_strings.dart:10` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'account_restricted'` |
| `lib/core/l10n/community_error_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản này đang bị hạn chế đăng bài, bình luận, tìm đồng đội và bình chọn. Hãy thử lại sau hoặc liên hệ ValVN trong Giới thiệu & pháp lý.'` |
| `lib/core/l10n/content_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'VP'` |
| `lib/core/l10n/content_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'KC'` |
| `lib/core/l10n/content_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'RP'` |
| `lib/core/l10n/content_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'VALORANT Point'` |
| `lib/core/l10n/content_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Kingdom Credit'` |
| `lib/core/l10n/content_strings.dart:11` | Nội dung/placeholder — đã rà theo VOICE | `'Radianite'` |
| `lib/core/l10n/content_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Huy hiệu đặc vụ'` |
| `lib/core/l10n/content_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Tuyển Chọn'` |
| `lib/core/l10n/content_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Sang Chảnh'` |
| `lib/core/l10n/content_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Cao Cấp'` |
| `lib/core/l10n/content_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Độc Quyền'` |
| `lib/core/l10n/content_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Siêu Cấp'` |
| `lib/core/l10n/content_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Phiên bản $shortName'` |
| `lib/core/l10n/content_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Phiên bản giới hạn'` |
| `lib/core/l10n/content_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'Skin'` |
| `lib/core/l10n/content_strings.dart:25` | Nội dung/placeholder — đã rà theo VOICE | `'Biến thể'` |
| `lib/core/l10n/content_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Phụ kiện súng'` |
| `lib/core/l10n/content_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Hình phun sơn'` |
| `lib/core/l10n/content_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Thẻ người chơi'` |
| `lib/core/l10n/content_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'Danh hiệu'` |
| `lib/core/l10n/content_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'Flex'` |
| `lib/core/l10n/content_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Khung cấp'` |
| `lib/core/l10n/content_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'Đặc vụ'` |
| `lib/core/l10n/content_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Hợp đồng'` |
| `lib/core/l10n/content_strings.dart:34` | Nội dung/placeholder — đã rà theo VOICE | `'Tiền tệ'` |
| `lib/core/l10n/content_strings.dart:37` | Nội dung/placeholder — đã rà theo VOICE | `'Phần thưởng Battle Pass'` |
| `lib/core/l10n/content_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Hợp đồng đặc vụ'` |
| `lib/core/l10n/content_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'Vé sự kiện'` |
| `lib/core/l10n/content_strings.dart:40` | Nội dung/placeholder — đã rà theo VOICE | `'Không bán'` |
| `lib/core/l10n/content_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'Không có danh hiệu'` |
| `lib/core/l10n/content_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Mặc định'` |
| `lib/core/l10n/content_strings.dart:45` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa xếp hạng'` |
| `lib/core/l10n/content_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Không có'` |
| `lib/core/l10n/content_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'Cơ bản'` |
| `lib/core/l10n/content_strings.dart:48` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $n'` |
| `lib/core/l10n/content_strings.dart:51` | Nội dung/placeholder — đã rà theo VOICE | `'Súng phụ'` |
| `lib/core/l10n/content_strings.dart:52` | Nội dung/placeholder — đã rà theo VOICE | `'SMG'` |
| `lib/core/l10n/content_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Shotgun'` |
| `lib/core/l10n/content_strings.dart:54` | Nội dung/placeholder — đã rà theo VOICE | `'Súng trường'` |
| `lib/core/l10n/content_strings.dart:55` | Nội dung/placeholder — đã rà theo VOICE | `'Súng bắn tỉa'` |
| `lib/core/l10n/content_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Vũ khí hạng nặng'` |
| `lib/core/l10n/content_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'Cận chiến'` |
| `lib/core/l10n/content_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'VFX'` |
| `lib/core/l10n/content_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Hiệu ứng hình ảnh'` |
| `lib/core/l10n/content_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Animation'` |
| `lib/core/l10n/content_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Hoạt ảnh'` |
| `lib/core/l10n/content_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Finisher'` |
| `lib/core/l10n/content_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Đòn kết liễu'` |
| `lib/core/l10n/content_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'KillCounter'` |
| `lib/core/l10n/content_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'Bộ đếm hạ gục'` |
| `lib/core/l10n/content_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'SoundEffects'` |
| `lib/core/l10n/content_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'Hiệu ứng âm thanh'` |
| `lib/core/l10n/content_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Transformation'` |
| `lib/core/l10n/content_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Biến hình'` |
| `lib/core/l10n/content_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'KillBanner'` |
| `lib/core/l10n/content_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Biểu ngữ hạ gục'` |
| `lib/core/l10n/content_strings.dart:68` | Nội dung/placeholder — đã rà theo VOICE | `'KillEffect'` |
| `lib/core/l10n/content_strings.dart:68` | Nội dung/placeholder — đã rà theo VOICE | `'Hiệu ứng hạ gục'` |
| `lib/core/l10n/content_strings.dart:69` | Nội dung/placeholder — đã rà theo VOICE | `'InspectAndKill'` |
| `lib/core/l10n/content_strings.dart:69` | Nội dung/placeholder — đã rà theo VOICE | `'Hiệu ứng ngắm súng & hạ gục'` |
| `lib/core/l10n/content_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Voiceover'` |
| `lib/core/l10n/content_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Lồng tiếng'` |
| `lib/core/l10n/content_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'SongShuffle'` |
| `lib/core/l10n/content_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'Đổi bài nhạc'` |
| `lib/core/l10n/content_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Randomizer'` |
| `lib/core/l10n/content_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Ngẫu nhiên hóa'` |
| `lib/core/l10n/content_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'AttackerDefenderSwap'` |
| `lib/core/l10n/content_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'Đổi theo phe công/thủ'` |
| `lib/core/l10n/content_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'TopFrag'` |
| `lib/core/l10n/content_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'Hiệu ứng top frag'` |
| `lib/core/l10n/content_strings.dart:75` | Nội dung/placeholder — đã rà theo VOICE | `'HeartbeatAndMapSensor'` |
| `lib/core/l10n/content_strings.dart:75` | Nội dung/placeholder — đã rà theo VOICE | `'Cảm biến nhịp tim & bản đồ'` |
| `lib/core/l10n/content_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'FishAnimation'` |
| `lib/core/l10n/content_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'Hoạt ảnh cá'` |
| `lib/core/l10n/content_strings.dart:81` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'competitive'` |
| `lib/core/l10n/content_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'Thi đấu xếp hạng'` |
| `lib/core/l10n/content_strings.dart:82` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'unrated'` |
| `lib/core/l10n/content_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'Đấu thường'` |
| `lib/core/l10n/content_strings.dart:83` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'swiftplay'` |
| `lib/core/l10n/content_strings.dart:83` | Nội dung/placeholder — đã rà theo VOICE | `'Siêu Tốc'` |
| `lib/core/l10n/content_strings.dart:84` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'spikerush'` |
| `lib/core/l10n/content_strings.dart:84` | Nội dung/placeholder — đã rà theo VOICE | `'Đặt Spike Nhanh'` |
| `lib/core/l10n/content_strings.dart:85` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'deathmatch'` |
| `lib/core/l10n/content_strings.dart:85` | Nội dung/placeholder — đã rà theo VOICE | `'Sinh Tử'` |
| `lib/core/l10n/content_strings.dart:86` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'hurm'` |
| `lib/core/l10n/content_strings.dart:86` | Nội dung/placeholder — đã rà theo VOICE | `'Sinh Tử Đội'` |
| `lib/core/l10n/content_strings.dart:87` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ggteam'` |
| `lib/core/l10n/content_strings.dart:87` | Nội dung/placeholder — đã rà theo VOICE | `'Tăng Tiến'` |
| `lib/core/l10n/content_strings.dart:88` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'onefa'` |
| `lib/core/l10n/content_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'Nhân bản'` |
| `lib/core/l10n/content_strings.dart:89` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'premier'` |
| `lib/core/l10n/content_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `'Premier'` |
| `lib/core/l10n/content_strings.dart:90` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'custom'` |
| `lib/core/l10n/content_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'Chơi tự do'` |
| `lib/core/l10n/content_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `''` |
| `lib/core/l10n/content_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `'Chơi tự do'` |
| `lib/core/l10n/content_strings.dart:92` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'dodgeball'` |
| `lib/core/l10n/content_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Knockout'` |
| `lib/core/l10n/content_strings.dart:93` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'fortcollins'` |
| `lib/core/l10n/content_strings.dart:93` | Nội dung/placeholder — đã rà theo VOICE | `'Retake'` |
| `lib/core/l10n/content_strings.dart:94` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'skirmish2v2'` |
| `lib/core/l10n/content_strings.dart:94` | Nội dung/placeholder — đã rà theo VOICE | `'Skirmish: 2v2'` |
| `lib/core/l10n/content_strings.dart:95` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'skirmishascension1v1'` |
| `lib/core/l10n/content_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'Skirmish: Thăng Hoa 1v1'` |
| `lib/core/l10n/content_strings.dart:96` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'skirmishascension2v2'` |
| `lib/core/l10n/content_strings.dart:96` | Nội dung/placeholder — đã rà theo VOICE | `'Skirmish: Thăng Hoa 2v2'` |
| `lib/core/l10n/content_strings.dart:97` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'valaram'` |
| `lib/core/l10n/content_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Tất Cả Ngẫu Nhiên Một Khu Đặt Spike'` |
| `lib/core/l10n/content_strings.dart:98` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'abilitydraftarena'` |
| `lib/core/l10n/content_strings.dart:98` | Nội dung/placeholder — đã rà theo VOICE | `'Gauntlet: Glitched'` |
| `lib/core/l10n/content_strings.dart:99` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'snowball'` |
| `lib/core/l10n/content_strings.dart:99` | Nội dung/placeholder — đã rà theo VOICE | `'Trận Chiến Cầu Tuyết'` |
| `lib/core/l10n/content_strings.dart:100` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'newmap'` |
| `lib/core/l10n/content_strings.dart:100` | Nội dung/placeholder — đã rà theo VOICE | `'Summit'` |
| `lib/core/l10n/content_strings.dart:105` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'competitive'` |
| `lib/core/l10n/content_strings.dart:105` | Nội dung/placeholder — đã rà theo VOICE | `'Xếp hạng'` |
| `lib/core/l10n/content_strings.dart:106` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'valaram'` |
| `lib/core/l10n/content_strings.dart:106` | Nội dung/placeholder — đã rà theo VOICE | `'Ngẫu nhiên 1 khu'` |
| `lib/core/l10n/content_strings.dart:111` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'dbe8757e-9e92-4ed4-b39f-9dfc589691d4'` |
| `lib/core/l10n/content_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'Đối đầu'` |
| `lib/core/l10n/content_strings.dart:112` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'1b47567f-8f7b-444b-aae3-b0c634622d10'` |
| `lib/core/l10n/content_strings.dart:112` | Nội dung/placeholder — đã rà theo VOICE | `'Khởi tranh'` |
| `lib/core/l10n/content_strings.dart:113` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'4ee40330-ecdd-4f2f-98a8-eb1243428373'` |
| `lib/core/l10n/content_strings.dart:113` | Nội dung/placeholder — đã rà theo VOICE | `'Kiểm soát'` |
| `lib/core/l10n/content_strings.dart:114` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'5fc02f99-4091-4486-a531-98459a3e95e9'` |
| `lib/core/l10n/content_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'Hộ vệ'` |
| `lib/core/l10n/content_strings.dart:118` | Nội dung/placeholder — đã rà theo VOICE | `'Tên vật phẩm'` |
| `lib/core/l10n/content_strings.dart:119` | Nội dung/placeholder — đã rà theo VOICE | `'Tiếng Việt'` |
| `lib/core/l10n/content_strings.dart:120` | Nội dung/placeholder — đã rà theo VOICE | `'Tiếng Anh'` |
| `lib/core/l10n/notification_strings.dart:3` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới cửa hàng'` |
| `lib/core/l10n/notification_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Nhắc khi cửa hàng hằng ngày làm mới'` |
| `lib/core/l10n/notification_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Wishlist'` |
| `lib/core/l10n/notification_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Báo khi skin trong wishlist xuất hiện trong cửa hàng'` |
| `lib/core/l10n/notification_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm'` |
| `lib/core/l10n/notification_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Báo khi Chợ Đêm mở'` |
| `lib/core/l10n/notification_strings.dart:11` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản'` |
| `lib/core/l10n/notification_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Nhắc khi một tài khoản cần đăng nhập lại'` |
| `lib/core/l10n/notification_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm đã mở!'` |
| `lib/core/l10n/notification_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Lật $cards thẻ ưu đãi của $account ngay.'` |
| `lib/core/l10n/notification_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Cần đăng nhập lại'` |
| `lib/core/l10n/notification_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng nhập lại $account để tiếp tục nhận thông báo wishlist.'` |
| `lib/features/battlepass/battlepass_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Battle Pass'` |
| `lib/features/battlepass/battlepass_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Phần thưởng'` |
| `lib/features/battlepass/battlepass_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Premium'` |
| `lib/features/battlepass/battlepass_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Miễn phí'` |
| `lib/features/battlepass/battlepass_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $level / $count'` |
| `lib/features/battlepass/battlepass_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'$xp / $total XP'` |
| `lib/features/battlepass/battlepass_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Lên cấp $level'` |
| `lib/features/battlepass/battlepass_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Tổng XP'` |
| `lib/features/battlepass/battlepass_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Đã hoàn thành Battle Pass'` |
| `lib/features/battlepass/battlepass_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'Phần kết thúc sau $days ngày'` |
| `lib/features/battlepass/battlepass_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Phần kết thúc sau $time'` |
| `lib/features/battlepass/battlepass_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Phần này đã kết thúc'` |
| `lib/features/battlepass/battlepass_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'Kết thúc lúc $wall'` |
| `lib/features/battlepass/battlepass_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới lúc $wall'` |
| `lib/features/battlepass/battlepass_strings.dart:34` | Nội dung/placeholder — đã rà theo VOICE | `'Nhiệm vụ mới lúc $wall'` |
| `lib/features/battlepass/battlepass_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có thông tin Battle Pass của Phần hiện tại. Hãy thử lại sau.'` |
| `lib/features/battlepass/battlepass_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'Xem tất cả phần thưởng'` |
| `lib/features/battlepass/battlepass_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'$unlocked/$total đã mở khóa'` |
| `lib/features/battlepass/battlepass_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'$xp XP / ngày'` |
| `lib/features/battlepass/battlepass_strings.dart:48` | Nội dung/placeholder — đã rà theo VOICE | `'Cần mỗi ngày để kịp hoàn thành'` |
| `lib/features/battlepass/battlepass_strings.dart:51` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $days ngày'` |
| `lib/features/battlepass/battlepass_strings.dart:54` | Nội dung/placeholder — đã rà theo VOICE | `'Nhiệm vụ tuần còn +$xp XP'` |
| `lib/features/battlepass/battlepass_strings.dart:58` | Nội dung/placeholder — đã rà theo VOICE | `'Còn cần $xp XP'` |
| `lib/features/battlepass/battlepass_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'≈ $n trận $queue'` |
| `lib/features/battlepass/battlepass_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Đấu thường'` |
| `lib/features/battlepass/battlepass_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'Ước tính khoảng 4.000 XP mỗi trận, chưa tính nhiệm vụ.'` |
| `lib/features/battlepass/battlepass_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Vé sự kiện'` |
| `lib/features/battlepass/battlepass_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Kết thúc sau $time'` |
| `lib/features/battlepass/battlepass_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'Nhiệm vụ hằng ngày'` |
| `lib/features/battlepass/battlepass_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'Phần thưởng ngày'` |
| `lib/features/battlepass/battlepass_strings.dart:77` | Nội dung/placeholder — đã rà theo VOICE | `'$dailyCaption$dot$reset'` |
| `lib/features/battlepass/battlepass_strings.dart:78` | Nội dung/placeholder — đã rà theo VOICE | `'Cột mốc'` |
| `lib/features/battlepass/battlepass_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'Đã đạt $done/$total cột mốc'` |
| `lib/features/battlepass/battlepass_strings.dart:86` | Nội dung/placeholder — đã rà theo VOICE | `'Cột mốc tiếp theo: $charges/$needed'` |
| `lib/features/battlepass/battlepass_strings.dart:87` | Nội dung/placeholder — đã rà theo VOICE | `'Mỗi cột mốc: +XP, +KC'` |
| `lib/features/battlepass/battlepass_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `'Thắng vòng để tiến tới cột mốc (Sinh Tử không tính).'` |
| `lib/features/battlepass/battlepass_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới sau $time'` |
| `lib/features/battlepass/battlepass_strings.dart:93` | Nội dung/placeholder — đã rà theo VOICE | `'Đã hoàn thành tất cả cột mốc hôm nay'` |
| `lib/features/battlepass/battlepass_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Cột mốc $index: $charges/$needed'` |
| `lib/features/battlepass/battlepass_strings.dart:98` | Nội dung/placeholder — đã rà theo VOICE | `'×2'` |
| `lib/features/battlepass/battlepass_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'$charges/$needed'` |
| `lib/features/battlepass/battlepass_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'Thưởng gấp đôi đang chờ: $n'` |
| `lib/features/battlepass/battlepass_strings.dart:106` | Nội dung/placeholder — đã rà theo VOICE | `'Cột mốc hôm nay chưa sẵn sàng. Hãy vào game hoặc làm mới tại đây.'` |
| `lib/features/battlepass/battlepass_strings.dart:108` | Nội dung/placeholder — đã rà theo VOICE | `'Cột mốc của ngày trước đã hết hạn. Hãy vào game hoặc làm mới tại đây.'` |
| `lib/features/battlepass/battlepass_strings.dart:110` | Nội dung/placeholder — đã rà theo VOICE | `'Cột mốc hôm nay chưa sẵn sàng. Hãy vào game để bắt đầu ngày mới.'` |
| `lib/features/battlepass/battlepass_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới cột mốc'` |
| `lib/features/battlepass/battlepass_strings.dart:112` | Nội dung/placeholder — đã rà theo VOICE | `'Đã làm mới cột mốc hằng ngày.'` |
| `lib/features/battlepass/battlepass_strings.dart:113` | Nội dung/placeholder — đã rà theo VOICE | `'Không thể làm mới cột mốc. Hãy thử lại sau.'` |
| `lib/features/battlepass/battlepass_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'Nhiệm vụ hằng tuần'` |
| `lib/features/battlepass/battlepass_strings.dart:120` | Nội dung/placeholder — đã rà theo VOICE | `'$progress / $target'` |
| `lib/features/battlepass/battlepass_strings.dart:123` | Nội dung/placeholder — đã rà theo VOICE | `'+$xp XP'` |
| `lib/features/battlepass/battlepass_strings.dart:124` | Nội dung/placeholder — đã rà theo VOICE | `'Nhiệm vụ mới (chưa có mô tả)'` |
| `lib/features/battlepass/battlepass_strings.dart:125` | Nội dung/placeholder — đã rà theo VOICE | `'Đã hoàn thành'` |
| `lib/features/battlepass/battlepass_strings.dart:129` | Nội dung/placeholder — đã rà theo VOICE | `'$done/$total hoàn thành'` |
| `lib/features/battlepass/battlepass_strings.dart:130` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện chưa có nhiệm vụ hằng tuần.'` |
| `lib/features/battlepass/battlepass_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'Đã hoàn thành tất cả nhiệm vụ'` |
| `lib/features/battlepass/battlepass_strings.dart:134` | Nội dung/placeholder — đã rà theo VOICE | `'Đã hoàn thành tất cả nhiệm vụ hằng tuần'` |
| `lib/features/battlepass/battlepass_strings.dart:137` | Nội dung/placeholder — đã rà theo VOICE | `'Nhiệm vụ mới sau $time'` |
| `lib/features/battlepass/battlepass_strings.dart:141` | Nội dung/placeholder — đã rà theo VOICE | `'Chương $n'` |
| `lib/features/battlepass/battlepass_strings.dart:142` | Nội dung/placeholder — đã rà theo VOICE | `'Phần mở rộng'` |
| `lib/features/battlepass/battlepass_strings.dart:145` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $n'` |
| `lib/features/battlepass/battlepass_strings.dart:148` | Nội dung/placeholder — đã rà theo VOICE | `'$reached/$total'` |
| `lib/features/battlepass/battlepass_strings.dart:149` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện tại'` |
| `lib/features/battlepass/battlepass_strings.dart:150` | Nội dung/placeholder — đã rà theo VOICE | `'Phần thưởng miễn phí'` |
| `lib/features/battlepass/battlepass_strings.dart:151` | Nội dung/placeholder — đã rà theo VOICE | `'Tiếp theo'` |
| `lib/features/battlepass/battlepass_strings.dart:152` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp'` |
| `lib/features/battlepass/battlepass_strings.dart:153` | Nội dung/placeholder — đã rà theo VOICE | `'Loại'` |
| `lib/features/battlepass/battlepass_strings.dart:154` | Nội dung/placeholder — đã rà theo VOICE | `'Loại phần thưởng'` |
| `lib/features/battlepass/battlepass_strings.dart:155` | Nội dung/placeholder — đã rà theo VOICE | `'Trạng thái'` |
| `lib/features/battlepass/battlepass_strings.dart:156` | Nội dung/placeholder — đã rà theo VOICE | `'Đã mở khóa'` |
| `lib/features/battlepass/battlepass_strings.dart:157` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa mở khóa'` |
| `lib/features/battlepass/battlepass_strings.dart:158` | Nội dung/placeholder — đã rà theo VOICE | `'Cần Premium'` |
| `lib/features/battlepass/battlepass_strings.dart:160` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa mua Premium: chỉ nhận được phần thưởng Miễn phí. '` |
| `lib/features/battlepass/battlepass_strings.dart:161` | Nội dung/placeholder — đã rà theo VOICE | `'Mua Premium trong game để mở khóa các cấp đã đạt.'` |
| `lib/features/battlepass/battlepass_strings.dart:162` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có phần thưởng nào cho Battle Pass này.'` |
| `lib/features/battlepass/battlepass_strings.dart:163` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có phần thưởng'` |
| `lib/features/battlepass/battlepass_strings.dart:166` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả'` |
| `lib/features/battlepass/battlepass_strings.dart:167` | Nội dung/placeholder — đã rà theo VOICE | `'Đã mở khóa'` |
| `lib/features/battlepass/battlepass_strings.dart:168` | Nội dung/placeholder — đã rà theo VOICE | `'Còn khóa'` |
| `lib/features/battlepass/battlepass_strings.dart:169` | Nội dung/placeholder — đã rà theo VOICE | `'Không có phần thưởng nào trong mục này.'` |
| `lib/features/battlepass/battlepass_strings.dart:170` | Nội dung/placeholder — đã rà theo VOICE | `'Xem tất cả'` |
| `lib/features/battlepass/battlepass_strings.dart:171` | Nội dung/placeholder — đã rà theo VOICE | `'Tiến độ nhiệm vụ tuần'` |
| `lib/features/battlepass/battlepass_strings.dart:172` | Nội dung/placeholder — đã rà theo VOICE | `'Phần thưởng'` |
| `lib/features/battlepass/battlepass_strings.dart:175` | Nội dung/placeholder — đã rà theo VOICE | `' · '` |
| `lib/features/battlepass/battlepass_strings.dart:179` | Nội dung/placeholder — đã rà theo VOICE | `'${levelOf(level, count)}$dot${unlockedCount(unlocked, count)}'` |
| `lib/features/collection/collection_strings.dart:1` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'../../core/domain/economy/economy_strings.dart'` |
| `lib/features/collection/collection_strings.dart:2` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'../../core/domain/loadout/loadout_strings.dart'` |
| `lib/features/collection/collection_strings.dart:3` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'../../core/l10n/content_strings.dart'` |
| `lib/features/collection/collection_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Bộ sưu tập'` |
| `lib/features/collection/collection_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Trang bị'` |
| `lib/features/collection/collection_strings.dart:11` | Nội dung/placeholder — đã rà theo VOICE | `'Hiển thị với người chơi khác'` |
| `lib/features/collection/collection_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Duyệt bộ sưu tập'` |
| `lib/features/collection/collection_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Thẻ người chơi'` |
| `lib/features/collection/collection_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Danh hiệu'` |
| `lib/features/collection/collection_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Trang bị vũ khí'` |
| `lib/features/collection/collection_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ hợp cảm xúc'` |
| `lib/features/collection/collection_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Bộ trang bị đã lưu'` |
| `lib/features/collection/collection_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Wishlist'` |
| `lib/features/collection/collection_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Khung cấp'` |
| `lib/features/collection/collection_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Tự động theo cấp'` |
| `lib/features/collection/collection_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Ẩn cấp tài khoản'` |
| `lib/features/collection/collection_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Người chơi khác sẽ không thấy cấp tài khoản của bạn.'` |
| `lib/features/collection/collection_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'Chế độ ẩn danh'` |
| `lib/features/collection/collection_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Ẩn tên của bạn với người chơi không cùng tổ đội trong trận.'` |
| `lib/features/collection/collection_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Thẻ đang dùng'` |
| `lib/features/collection/collection_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Chạm để đổi thẻ'` |
| `lib/features/collection/collection_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có'` |
| `lib/features/collection/collection_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'$n bộ'` |
| `lib/features/collection/collection_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'Trống'` |
| `lib/features/collection/collection_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'$n skin'` |
| `lib/features/collection/collection_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'$n món'` |
| `lib/features/collection/collection_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'$rowTitle: '` |
| `lib/features/collection/collection_strings.dart:40` | Nội dung/placeholder — đã rà theo VOICE | `'Tính trên $n skin'` |
| `lib/features/collection/collection_strings.dart:42` | Nội dung/placeholder — đã rà theo VOICE | `'$n skin phần thưởng không được tính'` |
| `lib/features/collection/collection_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Đang hiển thị trang bị đã lưu. Kéo để làm mới '` |
| `lib/features/collection/collection_strings.dart:45` | Nội dung/placeholder — đã rà theo VOICE | `'trước khi thay đổi.'` |
| `lib/features/collection/collection_strings.dart:48` | Nội dung/placeholder — đã rà theo VOICE | `'Đổi thẻ người chơi'` |
| `lib/features/collection/collection_strings.dart:49` | Nội dung/placeholder — đã rà theo VOICE | `'Đổi danh hiệu'` |
| `lib/features/collection/collection_strings.dart:51` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện ở sảnh chờ, bảng điểm và khi bạn hạ gục đối thủ.'` |
| `lib/features/collection/collection_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện dưới tên của bạn ở sảnh chờ và trong trận.'` |
| `lib/features/collection/collection_strings.dart:54` | Nội dung/placeholder — đã rà theo VOICE | `'Thẻ đang dùng: $name'` |
| `lib/features/collection/collection_strings.dart:55` | Nội dung/placeholder — đã rà theo VOICE | `'Thẻ chưa rõ tên'` |
| `lib/features/collection/collection_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'$n thẻ đã sở hữu'` |
| `lib/features/collection/collection_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'$n danh hiệu đã sở hữu'` |
| `lib/features/collection/collection_strings.dart:58` | Nội dung/placeholder — đã rà theo VOICE | `'Ảnh ở sảnh chờ'` |
| `lib/features/collection/collection_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Xem trước'` |
| `lib/features/collection/collection_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm thẻ người chơi…'` |
| `lib/features/collection/collection_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm danh hiệu…'` |
| `lib/features/collection/collection_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Trang bị'` |
| `lib/features/collection/collection_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'Đang dùng'` |
| `lib/features/collection/collection_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'Đã trang bị $name'` |
| `lib/features/collection/collection_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Đang lưu…'` |
| `lib/features/collection/collection_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy kết quả phù hợp.'` |
| `lib/features/collection/collection_strings.dart:68` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa tìm kiếm'` |
| `lib/features/collection/collection_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'Trang bị vũ khí'` |
| `lib/features/collection/collection_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn skin'` |
| `lib/features/collection/collection_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'$custom/$total vũ khí đang dùng skin'` |
| `lib/features/collection/collection_strings.dart:75` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm vũ khí, skin hoặc phụ kiện…'` |
| `lib/features/collection/collection_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'Đang dùng: $skin'` |
| `lib/features/collection/collection_strings.dart:78` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có skin nào'` |
| `lib/features/collection/collection_strings.dart:78` | Nội dung/placeholder — đã rà theo VOICE | `'$n skin đã sở hữu'` |
| `lib/features/collection/collection_strings.dart:80` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm skin…'` |
| `lib/features/collection/collection_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'Sắp xếp'` |
| `lib/features/collection/collection_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'Độ hiếm'` |
| `lib/features/collection/collection_strings.dart:83` | Nội dung/placeholder — đã rà theo VOICE | `'Tên'` |
| `lib/features/collection/collection_strings.dart:84` | Nội dung/placeholder — đã rà theo VOICE | `'Vũ khí'` |
| `lib/features/collection/collection_strings.dart:85` | Nội dung/placeholder — đã rà theo VOICE | `'Giá'` |
| `lib/features/collection/collection_strings.dart:86` | Nội dung/placeholder — đã rà theo VOICE | `'Phiên bản'` |
| `lib/features/collection/collection_strings.dart:87` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ lọc'` |
| `lib/features/collection/collection_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $owned/$total'` |
| `lib/features/collection/collection_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `'$owned/$total biến thể'` |
| `lib/features/collection/collection_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy vũ khí này.'` |
| `lib/features/collection/collection_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `'Khác'` |
| `lib/features/collection/collection_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa có skin nào cho vũ khí này.'` |
| `lib/features/collection/collection_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'Tùy chỉnh skin'` |
| `lib/features/collection/collection_strings.dart:96` | Nội dung/placeholder — đã rà theo VOICE | `'Biến thể'` |
| `lib/features/collection/collection_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp độ'` |
| `lib/features/collection/collection_strings.dart:98` | Nội dung/placeholder — đã rà theo VOICE | `'Phụ kiện súng'` |
| `lib/features/collection/collection_strings.dart:99` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa gắn phụ kiện'` |
| `lib/features/collection/collection_strings.dart:100` | Nội dung/placeholder — đã rà theo VOICE | `'Đổi'` |
| `lib/features/collection/collection_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa mở khóa'` |
| `lib/features/collection/collection_strings.dart:102` | Nội dung/placeholder — đã rà theo VOICE | `'Xem video'` |
| `lib/features/collection/collection_strings.dart:103` | Nội dung/placeholder — đã rà theo VOICE | `'Xem video cấp này'` |
| `lib/features/collection/collection_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa sở hữu skin này.'` |
| `lib/features/collection/collection_strings.dart:105` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy skin này.'` |
| `lib/features/collection/collection_strings.dart:106` | Nội dung/placeholder — đã rà theo VOICE | `'Vũ khí cận chiến không gắn được phụ kiện.'` |
| `lib/features/collection/collection_strings.dart:107` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $n · $type'` |
| `lib/features/collection/collection_strings.dart:110` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn phụ kiện súng'` |
| `lib/features/collection/collection_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'Gỡ phụ kiện'` |
| `lib/features/collection/collection_strings.dart:112` | Nội dung/placeholder — đã rà theo VOICE | `'Đã gỡ phụ kiện'` |
| `lib/features/collection/collection_strings.dart:113` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $free/$total'` |
| `lib/features/collection/collection_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm phụ kiện…'` |
| `lib/features/collection/collection_strings.dart:115` | Nội dung/placeholder — đã rà theo VOICE | `'Chuyển phụ kiện?'` |
| `lib/features/collection/collection_strings.dart:117` | Nội dung/placeholder — đã rà theo VOICE | `'$buddy đang gắn trên $from. Chuyển sang $to?'` |
| `lib/features/collection/collection_strings.dart:118` | Nội dung/placeholder — đã rà theo VOICE | `'Chuyển'` |
| `lib/features/collection/collection_strings.dart:119` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa có phụ kiện súng nào.'` |
| `lib/features/collection/collection_strings.dart:121` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa gắn được phụ kiện này. Hãy làm mới hoặc chọn phụ kiện khác.'` |
| `lib/features/collection/collection_strings.dart:122` | Nội dung/placeholder — đã rà theo VOICE | `'Cho $weapon'` |
| `lib/features/collection/collection_strings.dart:125` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ hợp cảm xúc'` |
| `lib/features/collection/collection_strings.dart:127` | Nội dung/placeholder — đã rà theo VOICE | `'Chạm vào một ô để chọn hình phun sơn hoặc Flex.'` |
| `lib/features/collection/collection_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Trên'` |
| `lib/features/collection/collection_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Phải'` |
| `lib/features/collection/collection_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Dưới'` |
| `lib/features/collection/collection_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Trái'` |
| `lib/features/collection/collection_strings.dart:130` | Nội dung/placeholder — đã rà theo VOICE | `'${slot + 1}'` |
| `lib/features/collection/collection_strings.dart:131` | Nội dung/placeholder — đã rà theo VOICE | `'Ô ${slotName(slot).toLowerCase()}'` |
| `lib/features/collection/collection_strings.dart:132` | Nội dung/placeholder — đã rà theo VOICE | `'Các ô trên vòng'` |
| `lib/features/collection/collection_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'Hình phun sơn'` |
| `lib/features/collection/collection_strings.dart:134` | Nội dung/placeholder — đã rà theo VOICE | `'Flex'` |
| `lib/features/collection/collection_strings.dart:135` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm hình phun sơn…'` |
| `lib/features/collection/collection_strings.dart:136` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm Flex…'` |
| `lib/features/collection/collection_strings.dart:137` | Nội dung/placeholder — đã rà theo VOICE | `'Trống'` |
| `lib/features/collection/collection_strings.dart:138` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa có hình phun sơn nào.'` |
| `lib/features/collection/collection_strings.dart:139` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa có Flex nào.'` |
| `lib/features/collection/collection_strings.dart:142` | Nội dung/placeholder — đã rà theo VOICE | `'Bộ trang bị đã lưu'` |
| `lib/features/collection/collection_strings.dart:143` | Nội dung/placeholder — đã rà theo VOICE | `'Lưu trang bị hiện tại'` |
| `lib/features/collection/collection_strings.dart:144` | Nội dung/placeholder — đã rà theo VOICE | `'Tên bộ trang bị'` |
| `lib/features/collection/collection_strings.dart:145` | Nội dung/placeholder — đã rà theo VOICE | `'Ví dụ: Leo rank'` |
| `lib/features/collection/collection_strings.dart:146` | Nội dung/placeholder — đã rà theo VOICE | `'Áp dụng'` |
| `lib/features/collection/collection_strings.dart:147` | Nội dung/placeholder — đã rà theo VOICE | `'Đổi tên'` |
| `lib/features/collection/collection_strings.dart:148` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa'` |
| `lib/features/collection/collection_strings.dart:149` | Nội dung/placeholder — đã rà theo VOICE | `'Tùy chọn'` |
| `lib/features/collection/collection_strings.dart:150` | Nội dung/placeholder — đã rà theo VOICE | `'Lưu ngày $date'` |
| `lib/features/collection/collection_strings.dart:151` | Nội dung/placeholder — đã rà theo VOICE | `'Đã lưu “$name”'` |
| `lib/features/collection/collection_strings.dart:152` | Nội dung/placeholder — đã rà theo VOICE | `'Đã áp dụng “$name”'` |
| `lib/features/collection/collection_strings.dart:154` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ qua $n vật phẩm bạn không còn sở hữu.'` |
| `lib/features/collection/collection_strings.dart:155` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa “$name”'` |
| `lib/features/collection/collection_strings.dart:156` | Nội dung/placeholder — đã rà theo VOICE | `'Hoàn tác'` |
| `lib/features/collection/collection_strings.dart:157` | Nội dung/placeholder — đã rà theo VOICE | `'Áp dụng “$name”?'` |
| `lib/features/collection/collection_strings.dart:159` | Nội dung/placeholder — đã rà theo VOICE | `'Skin, phụ kiện súng, tổ hợp cảm xúc, thẻ và danh hiệu đang dùng sẽ được '` |
| `lib/features/collection/collection_strings.dart:160` | Nội dung/placeholder — đã rà theo VOICE | `'thay bằng bộ này.'` |
| `lib/features/collection/collection_strings.dart:161` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có bộ trang bị'` |
| `lib/features/collection/collection_strings.dart:163` | Nội dung/placeholder — đã rà theo VOICE | `'Lưu trang bị đang dùng để đổi nhanh giữa các bộ skin, thẻ và tổ hợp '` |
| `lib/features/collection/collection_strings.dart:164` | Nội dung/placeholder — đã rà theo VOICE | `'cảm xúc sau này.'` |
| `lib/features/collection/collection_strings.dart:166` | Nội dung/placeholder — đã rà theo VOICE | `'Đã đạt tối đa 50 bộ trang bị. Hãy xóa bớt để lưu thêm.'` |
| `lib/features/collection/collection_strings.dart:168` | Nội dung/placeholder — đã rà theo VOICE | `'Bộ trang bị chỉ được lưu trên thiết bị này, cho tài khoản đang chọn.'` |
| `lib/features/collection/collection_strings.dart:171` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn khung cấp'` |
| `lib/features/collection/collection_strings.dart:174` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản cấp $level'` |
| `lib/features/collection/collection_strings.dart:175` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có khung cấp nào cho cấp của bạn.'` |
| `lib/features/collection/collection_strings.dart:176` | Nội dung/placeholder — đã rà theo VOICE | `'Từ cấp $level'` |
| `lib/features/collection/collection_strings.dart:179` | Nội dung/placeholder — đã rà theo VOICE | `'Duyệt bộ sưu tập'` |
| `lib/features/collection/collection_strings.dart:180` | Nội dung/placeholder — đã rà theo VOICE | `'Skin'` |
| `lib/features/collection/collection_strings.dart:181` | Nội dung/placeholder — đã rà theo VOICE | `'Phụ kiện súng'` |
| `lib/features/collection/collection_strings.dart:182` | Nội dung/placeholder — đã rà theo VOICE | `'Hình phun sơn'` |
| `lib/features/collection/collection_strings.dart:183` | Nội dung/placeholder — đã rà theo VOICE | `'Thẻ người chơi'` |
| `lib/features/collection/collection_strings.dart:184` | Nội dung/placeholder — đã rà theo VOICE | `'Danh hiệu'` |
| `lib/features/collection/collection_strings.dart:185` | Nội dung/placeholder — đã rà theo VOICE | `'Flex'` |
| `lib/features/collection/collection_strings.dart:186` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm kiếm…'` |
| `lib/features/collection/collection_strings.dart:190` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'skin'` |
| `lib/features/collection/collection_strings.dart:190` | Nội dung/placeholder — đã rà theo VOICE | `'Mọi skin bạn sở hữu, tính giá trị theo giá cửa hàng'` |
| `lib/features/collection/collection_strings.dart:191` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'buddy'` |
| `lib/features/collection/collection_strings.dart:191` | Nội dung/placeholder — đã rà theo VOICE | `'Phụ kiện súng đã sở hữu và số bản sao'` |
| `lib/features/collection/collection_strings.dart:192` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'spray'` |
| `lib/features/collection/collection_strings.dart:192` | Nội dung/placeholder — đã rà theo VOICE | `'Hình phun sơn bạn có thể gắn vào tổ hợp cảm xúc'` |
| `lib/features/collection/collection_strings.dart:193` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'card'` |
| `lib/features/collection/collection_strings.dart:193` | Nội dung/placeholder — đã rà theo VOICE | `'Thẻ người chơi đã mở khóa, chạm để xem và trang bị'` |
| `lib/features/collection/collection_strings.dart:194` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'title'` |
| `lib/features/collection/collection_strings.dart:194` | Nội dung/placeholder — đã rà theo VOICE | `'Danh hiệu bạn có thể hiển thị dưới tên'` |
| `lib/features/collection/collection_strings.dart:195` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'flex'` |
| `lib/features/collection/collection_strings.dart:195` | Nội dung/placeholder — đã rà theo VOICE | `'Flex đã sở hữu'` |
| `lib/features/collection/collection_strings.dart:198` | Nội dung/placeholder — đã rà theo VOICE | `'$count skin · $value'` |
| `lib/features/collection/collection_strings.dart:200` | Nội dung/placeholder — đã rà theo VOICE | `'Đang lọc: $count skin · $value'` |
| `lib/features/collection/collection_strings.dart:201` | Nội dung/placeholder — đã rà theo VOICE | `'$count vật phẩm'` |
| `lib/features/collection/collection_strings.dart:203` | Nội dung/placeholder — đã rà theo VOICE | `'Đang lọc: $count/$total vật phẩm'` |
| `lib/features/collection/collection_strings.dart:204` | Nội dung/placeholder — đã rà theo VOICE | `'×$n'` |
| `lib/features/collection/collection_strings.dart:205` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa có vật phẩm nào ở mục này.'` |
| `lib/features/collection/collection_strings.dart:206` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có vật phẩm'` |
| `lib/features/collection/collection_strings.dart:207` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy'` |
| `lib/features/collection/collection_strings.dart:208` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ lọc phiên bản'` |
| `lib/features/collection/collection_strings.dart:209` | Nội dung/placeholder — đã rà theo VOICE | `'Tính theo giá cửa hàng'` |
| `lib/features/collection/collection_strings.dart:210` | Nội dung/placeholder — đã rà theo VOICE | `'Xem các skin'` |
| `lib/features/collection/collection_strings.dart:211` | Nội dung/placeholder — đã rà theo VOICE | `'$n skin đã sở hữu'` |
| `lib/features/collection/collection_strings.dart:213` | Nội dung/placeholder — đã rà theo VOICE | `'Đã mở $owned/$total cấp'` |
| `lib/features/collection/collection_strings.dart:214` | Nội dung/placeholder — đã rà theo VOICE | `'Đang xem'` |
| `lib/features/collection/collection_strings.dart:219` | Nội dung/placeholder — đã rà theo VOICE | `'${LoadoutStrings.saveFailed}. $detail'` |
| `lib/features/community/community_strings.dart:4` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng'` |
| `lib/features/community/community_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Bảng tin'` |
| `lib/features/community/community_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm đồng đội'` |
| `lib/features/community/community_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Xếp hạng skin'` |
| `lib/features/community/community_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa kết nối được Cộng đồng'` |
| `lib/features/community/community_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa kết nối được Cộng đồng ValVN. Hãy thử lại sau ít phút.'` |
| `lib/features/community/community_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng nhập để tham gia'` |
| `lib/features/community/community_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm tài khoản Riot để đăng bài, tìm đồng đội và bình chọn skin.'` |
| `lib/features/community/community_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'ValVN xác minh Riot ID của bạn một lần khi bạn tham gia. Cộng đồng '` |
| `lib/features/community/community_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'không lưu mật khẩu hay dữ liệu đăng nhập Riot của bạn.'` |
| `lib/features/community/community_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn'` |
| `lib/features/community/community_strings.dart:22` | Nội dung/placeholder — đã rà theo VOICE | `'Người chơi'` |
| `lib/features/community/community_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Tùy chọn khác'` |
| `lib/features/community/community_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'#$tag'` |
| `lib/features/community/community_strings.dart:25` | Nội dung/placeholder — đã rà theo VOICE | `'$name#$tag'` |
| `lib/features/community/community_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `' · '` |
| `lib/features/community/community_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'$i/$n'` |
| `lib/features/community/community_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'$n/$max'` |
| `lib/features/community/community_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'Thử lại'` |
| `lib/features/community/community_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa tải thêm được bài. Hãy thử lại.'` |
| `lib/features/community/community_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Có gì đó trục trặc. Hãy thử lại.'` |
| `lib/features/community/community_strings.dart:35` | Nội dung/placeholder — đã rà theo VOICE | `'Không kết nối được Cộng đồng ValVN. Kiểm tra mạng rồi thử lại.'` |
| `lib/features/community/community_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng ValVN phản hồi quá lâu. Hãy thử lại.'` |
| `lib/features/community/community_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng ValVN đang gặp sự cố. Hãy thử lại sau ít phút.'` |
| `lib/features/community/community_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'Kết nối Cộng đồng đã hết hạn. Hãy thử lại.'` |
| `lib/features/community/community_strings.dart:41` | Nội dung/placeholder — đã rà theo VOICE | `'Riot chưa xác minh được tài khoản của bạn. Hãy đăng nhập lại tài khoản '` |
| `lib/features/community/community_strings.dart:42` | Nội dung/placeholder — đã rà theo VOICE | `'Riot rồi thử lại.'` |
| `lib/features/community/community_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đang gặp sự cố'` |
| `lib/features/community/community_strings.dart:45` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đang gặp sự cố. Hãy thử lại sau ít phút.'` |
| `lib/features/community/community_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đang gặp sự cố. Hãy thử lại sau $duration.'` |
| `lib/features/community/community_strings.dart:49` | Nội dung/placeholder — đã rà theo VOICE | `'Kho ảnh của Cộng đồng đã đầy. Bạn vẫn đăng bài được, nhưng chưa thể kèm '` |
| `lib/features/community/community_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'ảnh. Hãy thử lại sau.'` |
| `lib/features/community/community_strings.dart:52` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa thể thực hiện việc này. Hãy xem Tiêu chuẩn cộng đồng hoặc liên hệ ValVN.'` |
| `lib/features/community/community_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Nội dung này không còn tồn tại.'` |
| `lib/features/community/community_strings.dart:55` | Nội dung/placeholder — đã rà theo VOICE | `'Nội dung chưa được chấp nhận. Hãy kiểm tra lại rồi thử lại.'` |
| `lib/features/community/community_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng đang nhận quá nhiều yêu cầu. Hãy thử lại sau ít phút.'` |
| `lib/features/community/community_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng đang nhận quá nhiều yêu cầu. Hãy thử lại sau $duration.'` |
| `lib/features/community/community_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Ảnh quá lớn (tối đa 2 MB). Hãy chọn ảnh khác.'` |
| `lib/features/community/community_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy chọn ảnh JPEG, PNG hoặc WebP.'` |
| `lib/features/community/community_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa mở được thư viện ảnh. Hãy thử lại.'` |
| `lib/features/community/community_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa hoàn tất'` |
| `lib/features/community/community_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy đợi một chút'` |
| `lib/features/community/community_strings.dart:68` | Nội dung/placeholder — đã rà theo VOICE | `'Bảng tin còn trống'` |
| `lib/features/community/community_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy là người đầu tiên chia sẻ cửa hàng, Chợ Đêm hay khoảnh khắc của '` |
| `lib/features/community/community_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'bạn!'` |
| `lib/features/community/community_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng bài'` |
| `lib/features/community/community_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'Viết bài'` |
| `lib/features/community/community_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đang nghĩ gì về VALORANT hôm nay?'` |
| `lib/features/community/community_strings.dart:75` | Nội dung/placeholder — đã rà theo VOICE | `'Bài viết mới'` |
| `lib/features/community/community_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng'` |
| `lib/features/community/community_strings.dart:77` | Nội dung/placeholder — đã rà theo VOICE | `'Đang đăng…'` |
| `lib/features/community/community_strings.dart:78` | Nội dung/placeholder — đã rà theo VOICE | `'Đã đăng bài!'` |
| `lib/features/community/community_strings.dart:79` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm ảnh'` |
| `lib/features/community/community_strings.dart:80` | Nội dung/placeholder — đã rà theo VOICE | `'$n/$max ảnh'` |
| `lib/features/community/community_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ ảnh'` |
| `lib/features/community/community_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy viết gì đó hoặc thêm ảnh.'` |
| `lib/features/community/community_strings.dart:83` | Nội dung/placeholder — đã rà theo VOICE | `'Tối đa $max ký tự.'` |
| `lib/features/community/community_strings.dart:84` | Nội dung/placeholder — đã rà theo VOICE | `'Tối đa $max ảnh.'` |
| `lib/features/community/community_strings.dart:85` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tải ảnh lên…'` |
| `lib/features/community/community_strings.dart:86` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ bài viết?'` |
| `lib/features/community/community_strings.dart:87` | Nội dung/placeholder — đã rà theo VOICE | `'Nội dung bạn vừa viết sẽ không được lưu.'` |
| `lib/features/community/community_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ'` |
| `lib/features/community/community_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `'Viết tiếp'` |
| `lib/features/community/community_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng hôm nay'` |
| `lib/features/community/community_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm'` |
| `lib/features/community/community_strings.dart:93` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng ngày $date'` |
| `lib/features/community/community_strings.dart:94` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm ngày $date'` |
| `lib/features/community/community_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'Tổng $amount'` |
| `lib/features/community/community_strings.dart:96` | Nội dung/placeholder — đã rà theo VOICE | `'$name, $price'` |
| `lib/features/community/community_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ đính kèm'` |
| `lib/features/community/community_strings.dart:99` | Nội dung/placeholder — đã rà theo VOICE | `'Thích'` |
| `lib/features/community/community_strings.dart:100` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ thích'` |
| `lib/features/community/community_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'$n lượt thích'` |
| `lib/features/community/community_strings.dart:102` | Nội dung/placeholder — đã rà theo VOICE | `'$n bình luận'` |
| `lib/features/community/community_strings.dart:103` | Nội dung/placeholder — đã rà theo VOICE | `'Bình luận'` |
| `lib/features/community/community_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'Xem ảnh'` |
| `lib/features/community/community_strings.dart:105` | Nội dung/placeholder — đã rà theo VOICE | `'Ảnh $i/$n'` |
| `lib/features/community/community_strings.dart:107` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa bài viết'` |
| `lib/features/community/community_strings.dart:108` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa bài viết?'` |
| `lib/features/community/community_strings.dart:110` | Nội dung/placeholder — đã rà theo VOICE | `'Bài viết và toàn bộ bình luận sẽ bị xóa vĩnh viễn.'` |
| `lib/features/community/community_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa.'` |
| `lib/features/community/community_strings.dart:112` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa'` |
| `lib/features/community/community_strings.dart:113` | Nội dung/placeholder — đã rà theo VOICE | `'Báo cáo'` |
| `lib/features/community/community_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'Báo cáo nội dung'` |
| `lib/features/community/community_strings.dart:115` | Nội dung/placeholder — đã rà theo VOICE | `'Vì sao bạn báo cáo nội dung này?'` |
| `lib/features/community/community_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'Gửi báo cáo?'` |
| `lib/features/community/community_strings.dart:118` | Nội dung/placeholder — đã rà theo VOICE | `'Nội dung bị nhiều người báo cáo sẽ được ẩn khỏi Cộng đồng.'` |
| `lib/features/community/community_strings.dart:119` | Nội dung/placeholder — đã rà theo VOICE | `'Gửi'` |
| `lib/features/community/community_strings.dart:120` | Nội dung/placeholder — đã rà theo VOICE | `'Cảm ơn bạn! Báo cáo đã được gửi.'` |
| `lib/features/community/community_strings.dart:124` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'spam'` |
| `lib/features/community/community_strings.dart:124` | Nội dung/placeholder — đã rà theo VOICE | `'Spam hoặc quảng cáo'` |
| `lib/features/community/community_strings.dart:125` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'harassment'` |
| `lib/features/community/community_strings.dart:125` | Nội dung/placeholder — đã rà theo VOICE | `'Quấy rối, xúc phạm'` |
| `lib/features/community/community_strings.dart:126` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'inappropriate'` |
| `lib/features/community/community_strings.dart:126` | Nội dung/placeholder — đã rà theo VOICE | `'Nội dung không phù hợp'` |
| `lib/features/community/community_strings.dart:127` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'scam'` |
| `lib/features/community/community_strings.dart:127` | Nội dung/placeholder — đã rà theo VOICE | `'Lừa đảo, mua bán tài khoản'` |
| `lib/features/community/community_strings.dart:128` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'other'` |
| `lib/features/community/community_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Lý do khác'` |
| `lib/features/community/community_strings.dart:132` | Nội dung/placeholder — đã rà theo VOICE | `'Bài viết'` |
| `lib/features/community/community_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'Bình luận'` |
| `lib/features/community/community_strings.dart:134` | Nội dung/placeholder — đã rà theo VOICE | `'Bình luận · $n'` |
| `lib/features/community/community_strings.dart:135` | Nội dung/placeholder — đã rà theo VOICE | `'Viết bình luận…'` |
| `lib/features/community/community_strings.dart:136` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có bình luận. Hãy mở lời trước nhé!'` |
| `lib/features/community/community_strings.dart:137` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa bình luận'` |
| `lib/features/community/community_strings.dart:138` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa bình luận?'` |
| `lib/features/community/community_strings.dart:139` | Nội dung/placeholder — đã rà theo VOICE | `'Bình luận này sẽ bị xóa vĩnh viễn.'` |
| `lib/features/community/community_strings.dart:140` | Nội dung/placeholder — đã rà theo VOICE | `'Gửi bình luận'` |
| `lib/features/community/community_strings.dart:141` | Nội dung/placeholder — đã rà theo VOICE | `'Bài viết này đã bị xóa hoặc ẩn.'` |
| `lib/features/community/community_strings.dart:144` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa ai tìm đồng đội'` |
| `lib/features/community/community_strings.dart:146` | Nội dung/placeholder — đã rà theo VOICE | `'Tạo tin để người chơi khác vào tổ đội của bạn chỉ với một chạm.'` |
| `lib/features/community/community_strings.dart:147` | Nội dung/placeholder — đã rà theo VOICE | `'Tạo tin tìm đồng đội'` |
| `lib/features/community/community_strings.dart:148` | Nội dung/placeholder — đã rà theo VOICE | `'Tạo tin'` |
| `lib/features/community/community_strings.dart:149` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả'` |
| `lib/features/community/community_strings.dart:150` | Nội dung/placeholder — đã rà theo VOICE | `'Khu vực'` |
| `lib/features/community/community_strings.dart:151` | Nội dung/placeholder — đã rà theo VOICE | `'Cần $n người'` |
| `lib/features/community/community_strings.dart:152` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $t'` |
| `lib/features/community/community_strings.dart:153` | Nội dung/placeholder — đã rà theo VOICE | `'Đã hết hạn'` |
| `lib/features/community/community_strings.dart:154` | Nội dung/placeholder — đã rà theo VOICE | `'Vào tổ đội'` |
| `lib/features/community/community_strings.dart:155` | Nội dung/placeholder — đã rà theo VOICE | `'Vào tổ đội này?'` |
| `lib/features/community/community_strings.dart:157` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn sẽ rời tổ đội hiện tại trong VALORANT để vào tổ đội của $name.'` |
| `lib/features/community/community_strings.dart:158` | Nội dung/placeholder — đã rà theo VOICE | `'Vào'` |
| `lib/features/community/community_strings.dart:159` | Nội dung/placeholder — đã rà theo VOICE | `'Đã vào tổ đội! Mở VALORANT để chơi cùng nhau.'` |
| `lib/features/community/community_strings.dart:161` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy mở VALORANT trên máy tính hoặc console rồi thử lại.'` |
| `lib/features/community/community_strings.dart:163` | Nội dung/placeholder — đã rà theo VOICE | `'Mã tổ đội không còn hiệu lực hoặc tổ đội đã đủ người.'` |
| `lib/features/community/community_strings.dart:164` | Nội dung/placeholder — đã rà theo VOICE | `'Tin của bạn'` |
| `lib/features/community/community_strings.dart:165` | Nội dung/placeholder — đã rà theo VOICE | `'Gỡ tin'` |
| `lib/features/community/community_strings.dart:166` | Nội dung/placeholder — đã rà theo VOICE | `'Gỡ tin tìm đồng đội?'` |
| `lib/features/community/community_strings.dart:167` | Nội dung/placeholder — đã rà theo VOICE | `'Người khác sẽ không thấy tin này nữa.'` |
| `lib/features/community/community_strings.dart:168` | Nội dung/placeholder — đã rà theo VOICE | `'Đã gỡ tin.'` |
| `lib/features/community/community_strings.dart:169` | Nội dung/placeholder — đã rà theo VOICE | `'Đã đăng tin tìm đồng đội!'` |
| `lib/features/community/community_strings.dart:170` | Nội dung/placeholder — đã rà theo VOICE | `'Tự làm mới mỗi 20 giây'` |
| `lib/features/community/community_strings.dart:171` | Nội dung/placeholder — đã rà theo VOICE | `'Mã tổ đội: $code'` |
| `lib/features/community/community_strings.dart:173` | Nội dung/placeholder — đã rà theo VOICE | `'Khu vực: $region · $lfgExpiryNote'` |
| `lib/features/community/community_strings.dart:174` | Nội dung/placeholder — đã rà theo VOICE | `'$noParty\n$reason'` |
| `lib/features/community/community_strings.dart:177` | Nội dung/placeholder — đã rà theo VOICE | `'Chế độ'` |
| `lib/features/community/community_strings.dart:178` | Nội dung/placeholder — đã rà theo VOICE | `'Số người cần'` |
| `lib/features/community/community_strings.dart:179` | Nội dung/placeholder — đã rà theo VOICE | `'Ghi chú'` |
| `lib/features/community/community_strings.dart:180` | Nội dung/placeholder — đã rà theo VOICE | `'VD: cần 1 người Kiểm soát, có mic, vui vẻ là chính'` |
| `lib/features/community/community_strings.dart:181` | Nội dung/placeholder — đã rà theo VOICE | `'Mã tổ đội'` |
| `lib/features/community/community_strings.dart:182` | Nội dung/placeholder — đã rà theo VOICE | `'VD: A1B2C3'` |
| `lib/features/community/community_strings.dart:183` | Nội dung/placeholder — đã rà theo VOICE | `'Tạo mã tổ đội'` |
| `lib/features/community/community_strings.dart:184` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tạo mã…'` |
| `lib/features/community/community_strings.dart:185` | Nội dung/placeholder — đã rà theo VOICE | `'Đã tạo mã từ tổ đội hiện tại của bạn.'` |
| `lib/features/community/community_strings.dart:186` | Nội dung/placeholder — đã rà theo VOICE | `'Mã gồm đúng 6 chữ cái in hoa hoặc chữ số.'` |
| `lib/features/community/community_strings.dart:187` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy nhập hoặc tạo mã tổ đội.'` |
| `lib/features/community/community_strings.dart:189` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy tổ đội. Hãy mở VALORANT rồi thử lại, hoặc nhập mã thủ '` |
| `lib/features/community/community_strings.dart:190` | Nội dung/placeholder — đã rà theo VOICE | `'công.'` |
| `lib/features/community/community_strings.dart:191` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng tin'` |
| `lib/features/community/community_strings.dart:192` | Nội dung/placeholder — đã rà theo VOICE | `'Tin tự hết hạn sau 30 phút.'` |
| `lib/features/community/community_strings.dart:193` | Nội dung/placeholder — đã rà theo VOICE | `'Giảm'` |
| `lib/features/community/community_strings.dart:194` | Nội dung/placeholder — đã rà theo VOICE | `'Tăng'` |
| `lib/features/community/community_strings.dart:198` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'competitive'` |
| `lib/features/community/community_strings.dart:198` | Nội dung/placeholder — đã rà theo VOICE | `'Xếp hạng'` |
| `lib/features/community/community_strings.dart:199` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'unrated'` |
| `lib/features/community/community_strings.dart:199` | Nội dung/placeholder — đã rà theo VOICE | `'Đấu thường'` |
| `lib/features/community/community_strings.dart:200` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'swiftplay'` |
| `lib/features/community/community_strings.dart:200` | Nội dung/placeholder — đã rà theo VOICE | `'Siêu Tốc'` |
| `lib/features/community/community_strings.dart:201` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'spikerush'` |
| `lib/features/community/community_strings.dart:201` | Nội dung/placeholder — đã rà theo VOICE | `'Đặt Spike Nhanh'` |
| `lib/features/community/community_strings.dart:202` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'deathmatch'` |
| `lib/features/community/community_strings.dart:202` | Nội dung/placeholder — đã rà theo VOICE | `'Sinh Tử'` |
| `lib/features/community/community_strings.dart:203` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'teamdeathmatch'` |
| `lib/features/community/community_strings.dart:203` | Nội dung/placeholder — đã rà theo VOICE | `'Sinh Tử Đội'` |
| `lib/features/community/community_strings.dart:204` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'premier'` |
| `lib/features/community/community_strings.dart:204` | Nội dung/placeholder — đã rà theo VOICE | `'Premier'` |
| `lib/features/community/community_strings.dart:205` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'custom'` |
| `lib/features/community/community_strings.dart:205` | Nội dung/placeholder — đã rà theo VOICE | `'Chơi tự do'` |
| `lib/features/community/community_strings.dart:206` | Nội dung/placeholder — đã rà theo VOICE | `'Khác'` |
| `lib/features/community/community_strings.dart:211` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ap'` |
| `lib/features/community/community_strings.dart:211` | Nội dung/placeholder — đã rà theo VOICE | `'Châu Á - Thái Bình Dương'` |
| `lib/features/community/community_strings.dart:212` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'na'` |
| `lib/features/community/community_strings.dart:212` | Nội dung/placeholder — đã rà theo VOICE | `'Bắc Mỹ'` |
| `lib/features/community/community_strings.dart:213` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'eu'` |
| `lib/features/community/community_strings.dart:213` | Nội dung/placeholder — đã rà theo VOICE | `'Châu Âu'` |
| `lib/features/community/community_strings.dart:214` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'kr'` |
| `lib/features/community/community_strings.dart:214` | Nội dung/placeholder — đã rà theo VOICE | `'Hàn Quốc'` |
| `lib/features/community/community_strings.dart:215` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'latam'` |
| `lib/features/community/community_strings.dart:215` | Nội dung/placeholder — đã rà theo VOICE | `'Mỹ Latinh'` |
| `lib/features/community/community_strings.dart:216` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'br'` |
| `lib/features/community/community_strings.dart:216` | Nội dung/placeholder — đã rà theo VOICE | `'Brazil'` |
| `lib/features/community/community_strings.dart:217` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa rõ máy chủ'` |
| `lib/features/community/community_strings.dart:221` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có lượt bình chọn'` |
| `lib/features/community/community_strings.dart:223` | Nội dung/placeholder — đã rà theo VOICE | `'Thả tim cho skin bạn thích nhất để đưa nó lên bảng xếp hạng!'` |
| `lib/features/community/community_strings.dart:224` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả'` |
| `lib/features/community/community_strings.dart:225` | Nội dung/placeholder — đã rà theo VOICE | `'Tuần này'` |
| `lib/features/community/community_strings.dart:226` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả vũ khí'` |
| `lib/features/community/community_strings.dart:227` | Nội dung/placeholder — đã rà theo VOICE | `'$n lượt thích'` |
| `lib/features/community/community_strings.dart:228` | Nội dung/placeholder — đã rà theo VOICE | `'#$n'` |
| `lib/features/community/community_strings.dart:229` | Nội dung/placeholder — đã rà theo VOICE | `'Hạng $n: $name'` |
| `lib/features/community/community_strings.dart:230` | Nội dung/placeholder — đã rà theo VOICE | `'Thả tim cho skin này'` |
| `lib/features/community/community_strings.dart:231` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ tim'` |
| `lib/features/community/community_strings.dart:232` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng yêu thích'` |
| `lib/features/community/community_strings.dart:235` | Nội dung/placeholder — đã rà theo VOICE | `'Khoe lên Cộng đồng'` |
| `lib/features/community/community_strings.dart:236` | Nội dung/placeholder — đã rà theo VOICE | `'Khoe cửa hàng hôm nay với mọi người'` |
| `lib/features/community/community_strings.dart:237` | Nội dung/placeholder — đã rà theo VOICE | `'Khoe Chợ Đêm của bạn với mọi người'` |
| `lib/features/community/community_strings.dart:240` | Nội dung/placeholder — đã rà theo VOICE | `'Từ trước tới giờ'` |
| `lib/features/community/community_strings.dart:241` | Nội dung/placeholder — đã rà theo VOICE | `'Yêu thích nhất'` |
| `lib/features/community/community_strings.dart:242` | Nội dung/placeholder — đã rà theo VOICE | `'Đánh giá cao nhất'` |
| `lib/features/community/community_strings.dart:243` | Nội dung/placeholder — đã rà theo VOICE | `'Nhiều đánh giá nhất'` |
| `lib/features/community/community_strings.dart:244` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có đánh giá'` |
| `lib/features/community/community_strings.dart:245` | Nội dung/placeholder — đã rà theo VOICE | `'$n đánh giá'` |
| `lib/features/community/community_strings.dart:246` | Nội dung/placeholder — đã rà theo VOICE | `'$avg · $n đánh giá'` |
| `lib/features/community/community_strings.dart:247` | Nội dung/placeholder — đã rà theo VOICE | `'$avg trên 5 sao'` |
| `lib/features/community/community_strings.dart:248` | Nội dung/placeholder — đã rà theo VOICE | `'Viết đánh giá đầu tiên'` |
| `lib/features/community/community_strings.dart:249` | Nội dung/placeholder — đã rà theo VOICE | `'Đánh giá skin'` |
| `lib/features/community/community_strings.dart:250` | Nội dung/placeholder — đã rà theo VOICE | `'Đánh giá'` |
| `lib/features/community/community_strings.dart:251` | Nội dung/placeholder — đã rà theo VOICE | `'Đánh giá · $n'` |
| `lib/features/community/community_strings.dart:252` | Nội dung/placeholder — đã rà theo VOICE | `'Mới nhất'` |
| `lib/features/community/community_strings.dart:253` | Nội dung/placeholder — đã rà theo VOICE | `'Hữu ích nhất'` |
| `lib/features/community/community_strings.dart:254` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có đánh giá'` |
| `lib/features/community/community_strings.dart:255` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có đánh giá — hãy là người đầu tiên!'` |
| `lib/features/community/community_strings.dart:256` | Nội dung/placeholder — đã rà theo VOICE | `'Đánh giá của bạn'` |
| `lib/features/community/community_strings.dart:257` | Nội dung/placeholder — đã rà theo VOICE | `'Chạm vào sao để chấm điểm skin này'` |
| `lib/features/community/community_strings.dart:258` | Nội dung/placeholder — đã rà theo VOICE | `'Sửa'` |
| `lib/features/community/community_strings.dart:259` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa đánh giá'` |
| `lib/features/community/community_strings.dart:260` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa đánh giá của bạn?'` |
| `lib/features/community/community_strings.dart:262` | Nội dung/placeholder — đã rà theo VOICE | `'Điểm và nhận xét của bạn cho skin này sẽ bị xóa.'` |
| `lib/features/community/community_strings.dart:263` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa đánh giá.'` |
| `lib/features/community/community_strings.dart:264` | Nội dung/placeholder — đã rà theo VOICE | `'Đã lưu đánh giá!'` |
| `lib/features/community/community_strings.dart:265` | Nội dung/placeholder — đã rà theo VOICE | `'Chia sẻ cảm nhận về skin này (không bắt buộc)'` |
| `lib/features/community/community_strings.dart:266` | Nội dung/placeholder — đã rà theo VOICE | `'Lưu đánh giá'` |
| `lib/features/community/community_strings.dart:267` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy chọn số sao.'` |
| `lib/features/community/community_strings.dart:268` | Nội dung/placeholder — đã rà theo VOICE | `'Hữu ích'` |
| `lib/features/community/community_strings.dart:269` | Nội dung/placeholder — đã rà theo VOICE | `'Hữu ích · $n'` |
| `lib/features/community/community_strings.dart:270` | Nội dung/placeholder — đã rà theo VOICE | `'đã sửa'` |
| `lib/features/community/community_strings.dart:271` | Nội dung/placeholder — đã rà theo VOICE | `'$n sao'` |
| `lib/features/community/community_strings.dart:272` | Nội dung/placeholder — đã rà theo VOICE | `'Tệ'` |
| `lib/features/community/community_strings.dart:272` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa ổn'` |
| `lib/features/community/community_strings.dart:272` | Nội dung/placeholder — đã rà theo VOICE | `'Ổn'` |
| `lib/features/community/community_strings.dart:272` | Nội dung/placeholder — đã rà theo VOICE | `'Đẹp'` |
| `lib/features/community/community_strings.dart:272` | Nội dung/placeholder — đã rà theo VOICE | `'Tuyệt phẩm'` |
| `lib/features/community/community_strings.dart:273` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm tài khoản Riot để đánh giá skin.'` |
| `lib/features/community/community_strings.dart:274` | Nội dung/placeholder — đã rà theo VOICE | `'Xem video'` |
| `lib/features/community/community_strings.dart:275` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy skin này.'` |
| `lib/features/community/community_strings.dart:276` | Nội dung/placeholder — đã rà theo VOICE | `'Xem đánh giá'` |
| `lib/features/community/community_strings.dart:279` | Nội dung/placeholder — đã rà theo VOICE | `'Mọi rank'` |
| `lib/features/community/community_strings.dart:280` | Nội dung/placeholder — đã rà theo VOICE | `'Khoảng rank'` |
| `lib/features/community/community_strings.dart:281` | Nội dung/placeholder — đã rà theo VOICE | `'Từ'` |
| `lib/features/community/community_strings.dart:282` | Nội dung/placeholder — đã rà theo VOICE | `'Đến'` |
| `lib/features/community/community_strings.dart:283` | Nội dung/placeholder — đã rà theo VOICE | `'$a – $b'` |
| `lib/features/community/community_strings.dart:285` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy chọn rank thấp nhất không cao hơn rank cao nhất.'` |
| `lib/features/community/community_strings.dart:286` | Nội dung/placeholder — đã rà theo VOICE | `'Vai trò cần'` |
| `lib/features/community/community_strings.dart:287` | Nội dung/placeholder — đã rà theo VOICE | `'Linh hoạt'` |
| `lib/features/community/community_strings.dart:288` | Nội dung/placeholder — đã rà theo VOICE | `'Cần mic'` |
| `lib/features/community/community_strings.dart:289` | Nội dung/placeholder — đã rà theo VOICE | `'Có mic'` |
| `lib/features/community/community_strings.dart:290` | Nội dung/placeholder — đã rà theo VOICE | `'Ngôn ngữ'` |
| `lib/features/community/community_strings.dart:291` | Nội dung/placeholder — đã rà theo VOICE | `'Mọi ngôn ngữ'` |
| `lib/features/community/community_strings.dart:295` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ar'` |
| `lib/features/community/community_strings.dart:295` | Nội dung/placeholder — đã rà theo VOICE | `'العربية'` |
| `lib/features/community/community_strings.dart:296` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'de'` |
| `lib/features/community/community_strings.dart:296` | Nội dung/placeholder — đã rà theo VOICE | `'Deutsch'` |
| `lib/features/community/community_strings.dart:297` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'en'` |
| `lib/features/community/community_strings.dart:297` | Nội dung/placeholder — đã rà theo VOICE | `'English'` |
| `lib/features/community/community_strings.dart:298` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'es'` |
| `lib/features/community/community_strings.dart:298` | Nội dung/placeholder — đã rà theo VOICE | `'Español'` |
| `lib/features/community/community_strings.dart:299` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'fr'` |
| `lib/features/community/community_strings.dart:299` | Nội dung/placeholder — đã rà theo VOICE | `'Français'` |
| `lib/features/community/community_strings.dart:300` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'id'` |
| `lib/features/community/community_strings.dart:300` | Nội dung/placeholder — đã rà theo VOICE | `'Bahasa Indonesia'` |
| `lib/features/community/community_strings.dart:301` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'it'` |
| `lib/features/community/community_strings.dart:301` | Nội dung/placeholder — đã rà theo VOICE | `'Italiano'` |
| `lib/features/community/community_strings.dart:302` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ja'` |
| `lib/features/community/community_strings.dart:302` | Nội dung/placeholder — đã rà theo VOICE | `'日本語'` |
| `lib/features/community/community_strings.dart:303` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ko'` |
| `lib/features/community/community_strings.dart:303` | Nội dung/placeholder — đã rà theo VOICE | `'한국어'` |
| `lib/features/community/community_strings.dart:304` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'pl'` |
| `lib/features/community/community_strings.dart:304` | Nội dung/placeholder — đã rà theo VOICE | `'Polski'` |
| `lib/features/community/community_strings.dart:305` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'pt'` |
| `lib/features/community/community_strings.dart:305` | Nội dung/placeholder — đã rà theo VOICE | `'Português'` |
| `lib/features/community/community_strings.dart:306` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ru'` |
| `lib/features/community/community_strings.dart:306` | Nội dung/placeholder — đã rà theo VOICE | `'Русский'` |
| `lib/features/community/community_strings.dart:307` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'th'` |
| `lib/features/community/community_strings.dart:307` | Nội dung/placeholder — đã rà theo VOICE | `'ไทย'` |
| `lib/features/community/community_strings.dart:308` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'tr'` |
| `lib/features/community/community_strings.dart:308` | Nội dung/placeholder — đã rà theo VOICE | `'Türkçe'` |
| `lib/features/community/community_strings.dart:309` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'vi'` |
| `lib/features/community/community_strings.dart:309` | Nội dung/placeholder — đã rà theo VOICE | `'Tiếng Việt'` |
| `lib/features/community/community_strings.dart:310` | Nội dung/placeholder — đã rà theo VOICE | `'zh-CN'` |
| `lib/features/community/community_strings.dart:310` | Nội dung/placeholder — đã rà theo VOICE | `'简体中文'` |
| `lib/features/community/community_strings.dart:311` | Nội dung/placeholder — đã rà theo VOICE | `'zh-TW'` |
| `lib/features/community/community_strings.dart:311` | Nội dung/placeholder — đã rà theo VOICE | `'繁體中文'` |
| `lib/features/community/community_strings.dart:320` | Nội dung/placeholder — đã rà theo VOICE | `''` |
| `lib/features/community/community_strings.dart:321` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội hiện có'` |
| `lib/features/community/community_strings.dart:322` | Nội dung/placeholder — đã rà theo VOICE | `'$n người'` |
| `lib/features/community/community_strings.dart:323` | Nội dung/placeholder — đã rà theo VOICE | `'Lấy từ tổ đội trong game'` |
| `lib/features/community/community_strings.dart:325` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội có tối đa 5 người: chỉ còn $max chỗ.'` |
| `lib/features/community/community_strings.dart:327` | Nội dung/placeholder — đã rà theo VOICE | `'Để trống: ValVN tự tạo mã từ tổ đội trong game khi bạn đăng tin.'` |
| `lib/features/community/community_strings.dart:329` | Nội dung/placeholder — đã rà theo VOICE | `'Không tạo được mã tổ đội. Hãy mở VALORANT hoặc nhập mã thủ công.'` |
| `lib/features/community/community_strings.dart:330` | Nội dung/placeholder — đã rà theo VOICE | `'Phù hợp rank của bạn'` |
| `lib/features/community/community_strings.dart:331` | Nội dung/placeholder — đã rà theo VOICE | `'Ngoài khoảng rank'` |
| `lib/features/community/community_strings.dart:332` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tìm'` |
| `lib/features/community/community_strings.dart:333` | Nội dung/placeholder — đã rà theo VOICE | `'Đã đủ người'` |
| `lib/features/community/community_strings.dart:334` | Nội dung/placeholder — đã rà theo VOICE | `'Đang trong trận'` |
| `lib/features/community/community_strings.dart:335` | Nội dung/placeholder — đã rà theo VOICE | `'$n người đã vào'` |
| `lib/features/community/community_strings.dart:336` | Nội dung/placeholder — đã rà theo VOICE | `'Gia hạn'` |
| `lib/features/community/community_strings.dart:337` | Nội dung/placeholder — đã rà theo VOICE | `'Đã gia hạn tin thêm 30 phút.'` |
| `lib/features/community/community_strings.dart:339` | Nội dung/placeholder — đã rà theo VOICE | `'Tin của bạn đã hết hạn. Hãy đăng tin mới để tìm đồng đội.'` |
| `lib/features/community/community_strings.dart:340` | Nội dung/placeholder — đã rà theo VOICE | `'Thành viên'` |
| `lib/features/community/community_strings.dart:341` | Nội dung/placeholder — đã rà theo VOICE | `'$name đã vào tổ đội'` |
| `lib/features/community/community_strings.dart:342` | Nội dung/placeholder — đã rà theo VOICE | `'Tin tìm đồng đội của bạn vừa có người vào.'` |
| `lib/features/community/community_strings.dart:343` | Nội dung/placeholder — đã rà theo VOICE | `'Đã vào tổ đội! Mở VALORANT để chơi cùng nhau.'` |
| `lib/features/community/community_strings.dart:344` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội này đã đủ người.'` |
| `lib/features/community/community_strings.dart:346` | Nội dung/placeholder — đã rà theo VOICE | `'Mã tổ đội đã hết hạn hoặc không còn hiệu lực.'` |
| `lib/features/community/community_strings.dart:347` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới'` |
| `lib/features/community/community_strings.dart:348` | Nội dung/placeholder — đã rà theo VOICE | `'Đặc vụ đã chọn'` |
| `lib/features/community/community_strings.dart:349` | Nội dung/placeholder — đã rà theo VOICE | `'Bộ lọc'` |
| `lib/features/community/community_strings.dart:350` | Nội dung/placeholder — đã rà theo VOICE | `'Mọi vai trò'` |
| `lib/features/community/community_strings.dart:353` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm đồng đội hợp rank'` |
| `lib/features/community/community_strings.dart:354` | Nội dung/placeholder — đã rà theo VOICE | `'Skin được yêu thích trong tuần'` |
| `lib/features/community/community_strings.dart:357` | Nội dung/placeholder — đã rà theo VOICE | `'Nước bạn'` |
| `lib/features/community/community_strings.dart:358` | Nội dung/placeholder — đã rà theo VOICE | `'Khu vực'` |
| `lib/features/community/community_strings.dart:359` | Nội dung/placeholder — đã rà theo VOICE | `'Quốc tế'` |
| `lib/features/community/community_strings.dart:360` | Nội dung/placeholder — đã rà theo VOICE | `'Toàn cầu'` |
| `lib/features/community/community_strings.dart:361` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng các nước'` |
| `lib/features/community/community_strings.dart:362` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm quốc gia…'` |
| `lib/features/community/community_strings.dart:363` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy quốc gia phù hợp.'` |
| `lib/features/community/community_strings.dart:364` | Nội dung/placeholder — đã rà theo VOICE | `'Nước của bạn'` |
| `lib/features/community/community_strings.dart:365` | Nội dung/placeholder — đã rà theo VOICE | `'Về nước bạn'` |
| `lib/features/community/community_strings.dart:367` | Nội dung/placeholder — đã rà theo VOICE | `'$posts bài · $authors người'` |
| `lib/features/community/community_strings.dart:368` | Nội dung/placeholder — đã rà theo VOICE | `'$n tin tìm đồng đội'` |
| `lib/features/community/community_strings.dart:369` | Nội dung/placeholder — đã rà theo VOICE | `'Ngôn ngữ nội dung'` |
| `lib/features/community/community_strings.dart:371` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ hiện nội dung viết bằng các ngôn ngữ đã chọn. Bỏ trống để xem tất cả.'` |
| `lib/features/community/community_strings.dart:372` | Nội dung/placeholder — đã rà theo VOICE | `'$n ngôn ngữ'` |
| `lib/features/community/community_strings.dart:373` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ chọn'` |
| `lib/features/community/community_strings.dart:374` | Nội dung/placeholder — đã rà theo VOICE | `'Áp dụng'` |
| `lib/features/community/community_strings.dart:375` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có bài trong phạm vi này'` |
| `lib/features/community/community_strings.dart:377` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng bài đầu tiên hoặc chọn Khu vực hay Quốc tế để xem thêm.'` |
| `lib/features/community/community_strings.dart:378` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ người cùng máy chủ mới vào tổ đội được.'` |
| `lib/features/community/community_strings.dart:380` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đang xem máy chủ $region — chỉ người cùng máy chủ với tài khoản của bạn mới vào tổ đội được.'` |
| `lib/features/community/community_strings.dart:386` | Nội dung/placeholder — đã rà theo VOICE | `'AE'` |
| `lib/features/community/community_strings.dart:386` | Nội dung/placeholder — đã rà theo VOICE | `'Các Tiểu vương quốc Ả Rập Thống nhất'` |
| `lib/features/community/community_strings.dart:387` | Nội dung/placeholder — đã rà theo VOICE | `'AL'` |
| `lib/features/community/community_strings.dart:387` | Nội dung/placeholder — đã rà theo VOICE | `'Albania'` |
| `lib/features/community/community_strings.dart:388` | Nội dung/placeholder — đã rà theo VOICE | `'AM'` |
| `lib/features/community/community_strings.dart:388` | Nội dung/placeholder — đã rà theo VOICE | `'Armenia'` |
| `lib/features/community/community_strings.dart:389` | Nội dung/placeholder — đã rà theo VOICE | `'AR'` |
| `lib/features/community/community_strings.dart:389` | Nội dung/placeholder — đã rà theo VOICE | `'Argentina'` |
| `lib/features/community/community_strings.dart:390` | Nội dung/placeholder — đã rà theo VOICE | `'AT'` |
| `lib/features/community/community_strings.dart:390` | Nội dung/placeholder — đã rà theo VOICE | `'Áo'` |
| `lib/features/community/community_strings.dart:391` | Nội dung/placeholder — đã rà theo VOICE | `'AU'` |
| `lib/features/community/community_strings.dart:391` | Nội dung/placeholder — đã rà theo VOICE | `'Úc'` |
| `lib/features/community/community_strings.dart:392` | Nội dung/placeholder — đã rà theo VOICE | `'AZ'` |
| `lib/features/community/community_strings.dart:392` | Nội dung/placeholder — đã rà theo VOICE | `'Azerbaijan'` |
| `lib/features/community/community_strings.dart:393` | Nội dung/placeholder — đã rà theo VOICE | `'BA'` |
| `lib/features/community/community_strings.dart:393` | Nội dung/placeholder — đã rà theo VOICE | `'Bosnia và Herzegovina'` |
| `lib/features/community/community_strings.dart:394` | Nội dung/placeholder — đã rà theo VOICE | `'BD'` |
| `lib/features/community/community_strings.dart:394` | Nội dung/placeholder — đã rà theo VOICE | `'Bangladesh'` |
| `lib/features/community/community_strings.dart:395` | Nội dung/placeholder — đã rà theo VOICE | `'BE'` |
| `lib/features/community/community_strings.dart:395` | Nội dung/placeholder — đã rà theo VOICE | `'Bỉ'` |
| `lib/features/community/community_strings.dart:396` | Nội dung/placeholder — đã rà theo VOICE | `'BG'` |
| `lib/features/community/community_strings.dart:396` | Nội dung/placeholder — đã rà theo VOICE | `'Bulgaria'` |
| `lib/features/community/community_strings.dart:397` | Nội dung/placeholder — đã rà theo VOICE | `'BH'` |
| `lib/features/community/community_strings.dart:397` | Nội dung/placeholder — đã rà theo VOICE | `'Bahrain'` |
| `lib/features/community/community_strings.dart:398` | Nội dung/placeholder — đã rà theo VOICE | `'BN'` |
| `lib/features/community/community_strings.dart:398` | Nội dung/placeholder — đã rà theo VOICE | `'Brunei'` |
| `lib/features/community/community_strings.dart:399` | Nội dung/placeholder — đã rà theo VOICE | `'BO'` |
| `lib/features/community/community_strings.dart:399` | Nội dung/placeholder — đã rà theo VOICE | `'Bolivia'` |
| `lib/features/community/community_strings.dart:400` | Nội dung/placeholder — đã rà theo VOICE | `'BR'` |
| `lib/features/community/community_strings.dart:400` | Nội dung/placeholder — đã rà theo VOICE | `'Brazil'` |
| `lib/features/community/community_strings.dart:401` | Nội dung/placeholder — đã rà theo VOICE | `'BY'` |
| `lib/features/community/community_strings.dart:401` | Nội dung/placeholder — đã rà theo VOICE | `'Belarus'` |
| `lib/features/community/community_strings.dart:402` | Nội dung/placeholder — đã rà theo VOICE | `'CA'` |
| `lib/features/community/community_strings.dart:402` | Nội dung/placeholder — đã rà theo VOICE | `'Canada'` |
| `lib/features/community/community_strings.dart:403` | Nội dung/placeholder — đã rà theo VOICE | `'CH'` |
| `lib/features/community/community_strings.dart:403` | Nội dung/placeholder — đã rà theo VOICE | `'Thụy Sĩ'` |
| `lib/features/community/community_strings.dart:404` | Nội dung/placeholder — đã rà theo VOICE | `'CL'` |
| `lib/features/community/community_strings.dart:404` | Nội dung/placeholder — đã rà theo VOICE | `'Chile'` |
| `lib/features/community/community_strings.dart:405` | Nội dung/placeholder — đã rà theo VOICE | `'CN'` |
| `lib/features/community/community_strings.dart:405` | Nội dung/placeholder — đã rà theo VOICE | `'Trung Quốc'` |
| `lib/features/community/community_strings.dart:406` | Nội dung/placeholder — đã rà theo VOICE | `'CO'` |
| `lib/features/community/community_strings.dart:406` | Nội dung/placeholder — đã rà theo VOICE | `'Colombia'` |
| `lib/features/community/community_strings.dart:407` | Nội dung/placeholder — đã rà theo VOICE | `'CR'` |
| `lib/features/community/community_strings.dart:407` | Nội dung/placeholder — đã rà theo VOICE | `'Costa Rica'` |
| `lib/features/community/community_strings.dart:408` | Nội dung/placeholder — đã rà theo VOICE | `'CU'` |
| `lib/features/community/community_strings.dart:408` | Nội dung/placeholder — đã rà theo VOICE | `'Cuba'` |
| `lib/features/community/community_strings.dart:409` | Nội dung/placeholder — đã rà theo VOICE | `'CY'` |
| `lib/features/community/community_strings.dart:409` | Nội dung/placeholder — đã rà theo VOICE | `'Síp'` |
| `lib/features/community/community_strings.dart:410` | Nội dung/placeholder — đã rà theo VOICE | `'CZ'` |
| `lib/features/community/community_strings.dart:410` | Nội dung/placeholder — đã rà theo VOICE | `'Séc'` |
| `lib/features/community/community_strings.dart:411` | Nội dung/placeholder — đã rà theo VOICE | `'DE'` |
| `lib/features/community/community_strings.dart:411` | Nội dung/placeholder — đã rà theo VOICE | `'Đức'` |
| `lib/features/community/community_strings.dart:412` | Nội dung/placeholder — đã rà theo VOICE | `'DK'` |
| `lib/features/community/community_strings.dart:412` | Nội dung/placeholder — đã rà theo VOICE | `'Đan Mạch'` |
| `lib/features/community/community_strings.dart:413` | Nội dung/placeholder — đã rà theo VOICE | `'DO'` |
| `lib/features/community/community_strings.dart:413` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng hòa Dominica'` |
| `lib/features/community/community_strings.dart:414` | Nội dung/placeholder — đã rà theo VOICE | `'DZ'` |
| `lib/features/community/community_strings.dart:414` | Nội dung/placeholder — đã rà theo VOICE | `'Algeria'` |
| `lib/features/community/community_strings.dart:415` | Nội dung/placeholder — đã rà theo VOICE | `'EC'` |
| `lib/features/community/community_strings.dart:415` | Nội dung/placeholder — đã rà theo VOICE | `'Ecuador'` |
| `lib/features/community/community_strings.dart:416` | Nội dung/placeholder — đã rà theo VOICE | `'EE'` |
| `lib/features/community/community_strings.dart:416` | Nội dung/placeholder — đã rà theo VOICE | `'Estonia'` |
| `lib/features/community/community_strings.dart:417` | Nội dung/placeholder — đã rà theo VOICE | `'EG'` |
| `lib/features/community/community_strings.dart:417` | Nội dung/placeholder — đã rà theo VOICE | `'Ai Cập'` |
| `lib/features/community/community_strings.dart:418` | Nội dung/placeholder — đã rà theo VOICE | `'ES'` |
| `lib/features/community/community_strings.dart:418` | Nội dung/placeholder — đã rà theo VOICE | `'Tây Ban Nha'` |
| `lib/features/community/community_strings.dart:419` | Nội dung/placeholder — đã rà theo VOICE | `'ET'` |
| `lib/features/community/community_strings.dart:419` | Nội dung/placeholder — đã rà theo VOICE | `'Ethiopia'` |
| `lib/features/community/community_strings.dart:420` | Nội dung/placeholder — đã rà theo VOICE | `'FI'` |
| `lib/features/community/community_strings.dart:420` | Nội dung/placeholder — đã rà theo VOICE | `'Phần Lan'` |
| `lib/features/community/community_strings.dart:421` | Nội dung/placeholder — đã rà theo VOICE | `'FR'` |
| `lib/features/community/community_strings.dart:421` | Nội dung/placeholder — đã rà theo VOICE | `'Pháp'` |
| `lib/features/community/community_strings.dart:422` | Nội dung/placeholder — đã rà theo VOICE | `'GB'` |
| `lib/features/community/community_strings.dart:422` | Nội dung/placeholder — đã rà theo VOICE | `'Vương quốc Anh'` |
| `lib/features/community/community_strings.dart:423` | Nội dung/placeholder — đã rà theo VOICE | `'GE'` |
| `lib/features/community/community_strings.dart:423` | Nội dung/placeholder — đã rà theo VOICE | `'Georgia'` |
| `lib/features/community/community_strings.dart:424` | Nội dung/placeholder — đã rà theo VOICE | `'GH'` |
| `lib/features/community/community_strings.dart:424` | Nội dung/placeholder — đã rà theo VOICE | `'Ghana'` |
| `lib/features/community/community_strings.dart:425` | Nội dung/placeholder — đã rà theo VOICE | `'GR'` |
| `lib/features/community/community_strings.dart:425` | Nội dung/placeholder — đã rà theo VOICE | `'Hy Lạp'` |
| `lib/features/community/community_strings.dart:426` | Nội dung/placeholder — đã rà theo VOICE | `'GT'` |
| `lib/features/community/community_strings.dart:426` | Nội dung/placeholder — đã rà theo VOICE | `'Guatemala'` |
| `lib/features/community/community_strings.dart:427` | Nội dung/placeholder — đã rà theo VOICE | `'HK'` |
| `lib/features/community/community_strings.dart:427` | Nội dung/placeholder — đã rà theo VOICE | `'Hồng Kông'` |
| `lib/features/community/community_strings.dart:428` | Nội dung/placeholder — đã rà theo VOICE | `'HN'` |
| `lib/features/community/community_strings.dart:428` | Nội dung/placeholder — đã rà theo VOICE | `'Honduras'` |
| `lib/features/community/community_strings.dart:429` | Nội dung/placeholder — đã rà theo VOICE | `'HR'` |
| `lib/features/community/community_strings.dart:429` | Nội dung/placeholder — đã rà theo VOICE | `'Croatia'` |
| `lib/features/community/community_strings.dart:430` | Nội dung/placeholder — đã rà theo VOICE | `'HU'` |
| `lib/features/community/community_strings.dart:430` | Nội dung/placeholder — đã rà theo VOICE | `'Hungary'` |
| `lib/features/community/community_strings.dart:431` | Nội dung/placeholder — đã rà theo VOICE | `'ID'` |
| `lib/features/community/community_strings.dart:431` | Nội dung/placeholder — đã rà theo VOICE | `'Indonesia'` |
| `lib/features/community/community_strings.dart:432` | Nội dung/placeholder — đã rà theo VOICE | `'IE'` |
| `lib/features/community/community_strings.dart:432` | Nội dung/placeholder — đã rà theo VOICE | `'Ireland'` |
| `lib/features/community/community_strings.dart:433` | Nội dung/placeholder — đã rà theo VOICE | `'IL'` |
| `lib/features/community/community_strings.dart:433` | Nội dung/placeholder — đã rà theo VOICE | `'Israel'` |
| `lib/features/community/community_strings.dart:434` | Nội dung/placeholder — đã rà theo VOICE | `'IN'` |
| `lib/features/community/community_strings.dart:434` | Nội dung/placeholder — đã rà theo VOICE | `'Ấn Độ'` |
| `lib/features/community/community_strings.dart:435` | Nội dung/placeholder — đã rà theo VOICE | `'IQ'` |
| `lib/features/community/community_strings.dart:435` | Nội dung/placeholder — đã rà theo VOICE | `'Iraq'` |
| `lib/features/community/community_strings.dart:436` | Nội dung/placeholder — đã rà theo VOICE | `'IR'` |
| `lib/features/community/community_strings.dart:436` | Nội dung/placeholder — đã rà theo VOICE | `'Iran'` |
| `lib/features/community/community_strings.dart:437` | Nội dung/placeholder — đã rà theo VOICE | `'IS'` |
| `lib/features/community/community_strings.dart:437` | Nội dung/placeholder — đã rà theo VOICE | `'Iceland'` |
| `lib/features/community/community_strings.dart:438` | Nội dung/placeholder — đã rà theo VOICE | `'IT'` |
| `lib/features/community/community_strings.dart:438` | Nội dung/placeholder — đã rà theo VOICE | `'Ý'` |
| `lib/features/community/community_strings.dart:439` | Nội dung/placeholder — đã rà theo VOICE | `'JO'` |
| `lib/features/community/community_strings.dart:439` | Nội dung/placeholder — đã rà theo VOICE | `'Jordan'` |
| `lib/features/community/community_strings.dart:440` | Nội dung/placeholder — đã rà theo VOICE | `'JP'` |
| `lib/features/community/community_strings.dart:440` | Nội dung/placeholder — đã rà theo VOICE | `'Nhật Bản'` |
| `lib/features/community/community_strings.dart:441` | Nội dung/placeholder — đã rà theo VOICE | `'KE'` |
| `lib/features/community/community_strings.dart:441` | Nội dung/placeholder — đã rà theo VOICE | `'Kenya'` |
| `lib/features/community/community_strings.dart:442` | Nội dung/placeholder — đã rà theo VOICE | `'KH'` |
| `lib/features/community/community_strings.dart:442` | Nội dung/placeholder — đã rà theo VOICE | `'Campuchia'` |
| `lib/features/community/community_strings.dart:443` | Nội dung/placeholder — đã rà theo VOICE | `'KR'` |
| `lib/features/community/community_strings.dart:443` | Nội dung/placeholder — đã rà theo VOICE | `'Hàn Quốc'` |
| `lib/features/community/community_strings.dart:444` | Nội dung/placeholder — đã rà theo VOICE | `'KW'` |
| `lib/features/community/community_strings.dart:444` | Nội dung/placeholder — đã rà theo VOICE | `'Kuwait'` |
| `lib/features/community/community_strings.dart:445` | Nội dung/placeholder — đã rà theo VOICE | `'KZ'` |
| `lib/features/community/community_strings.dart:445` | Nội dung/placeholder — đã rà theo VOICE | `'Kazakhstan'` |
| `lib/features/community/community_strings.dart:446` | Nội dung/placeholder — đã rà theo VOICE | `'LA'` |
| `lib/features/community/community_strings.dart:446` | Nội dung/placeholder — đã rà theo VOICE | `'Lào'` |
| `lib/features/community/community_strings.dart:447` | Nội dung/placeholder — đã rà theo VOICE | `'LB'` |
| `lib/features/community/community_strings.dart:447` | Nội dung/placeholder — đã rà theo VOICE | `'Liban'` |
| `lib/features/community/community_strings.dart:448` | Nội dung/placeholder — đã rà theo VOICE | `'LK'` |
| `lib/features/community/community_strings.dart:448` | Nội dung/placeholder — đã rà theo VOICE | `'Sri Lanka'` |
| `lib/features/community/community_strings.dart:449` | Nội dung/placeholder — đã rà theo VOICE | `'LT'` |
| `lib/features/community/community_strings.dart:449` | Nội dung/placeholder — đã rà theo VOICE | `'Litva'` |
| `lib/features/community/community_strings.dart:450` | Nội dung/placeholder — đã rà theo VOICE | `'LU'` |
| `lib/features/community/community_strings.dart:450` | Nội dung/placeholder — đã rà theo VOICE | `'Luxembourg'` |
| `lib/features/community/community_strings.dart:451` | Nội dung/placeholder — đã rà theo VOICE | `'LV'` |
| `lib/features/community/community_strings.dart:451` | Nội dung/placeholder — đã rà theo VOICE | `'Latvia'` |
| `lib/features/community/community_strings.dart:452` | Nội dung/placeholder — đã rà theo VOICE | `'LY'` |
| `lib/features/community/community_strings.dart:452` | Nội dung/placeholder — đã rà theo VOICE | `'Libya'` |
| `lib/features/community/community_strings.dart:453` | Nội dung/placeholder — đã rà theo VOICE | `'MA'` |
| `lib/features/community/community_strings.dart:453` | Nội dung/placeholder — đã rà theo VOICE | `'Maroc'` |
| `lib/features/community/community_strings.dart:454` | Nội dung/placeholder — đã rà theo VOICE | `'MD'` |
| `lib/features/community/community_strings.dart:454` | Nội dung/placeholder — đã rà theo VOICE | `'Moldova'` |
| `lib/features/community/community_strings.dart:455` | Nội dung/placeholder — đã rà theo VOICE | `'ME'` |
| `lib/features/community/community_strings.dart:455` | Nội dung/placeholder — đã rà theo VOICE | `'Montenegro'` |
| `lib/features/community/community_strings.dart:456` | Nội dung/placeholder — đã rà theo VOICE | `'MK'` |
| `lib/features/community/community_strings.dart:456` | Nội dung/placeholder — đã rà theo VOICE | `'Bắc Macedonia'` |
| `lib/features/community/community_strings.dart:457` | Nội dung/placeholder — đã rà theo VOICE | `'MM'` |
| `lib/features/community/community_strings.dart:457` | Nội dung/placeholder — đã rà theo VOICE | `'Myanmar'` |
| `lib/features/community/community_strings.dart:458` | Nội dung/placeholder — đã rà theo VOICE | `'MN'` |
| `lib/features/community/community_strings.dart:458` | Nội dung/placeholder — đã rà theo VOICE | `'Mông Cổ'` |
| `lib/features/community/community_strings.dart:459` | Nội dung/placeholder — đã rà theo VOICE | `'MO'` |
| `lib/features/community/community_strings.dart:459` | Nội dung/placeholder — đã rà theo VOICE | `'Ma Cao'` |
| `lib/features/community/community_strings.dart:460` | Nội dung/placeholder — đã rà theo VOICE | `'MT'` |
| `lib/features/community/community_strings.dart:460` | Nội dung/placeholder — đã rà theo VOICE | `'Malta'` |
| `lib/features/community/community_strings.dart:461` | Nội dung/placeholder — đã rà theo VOICE | `'MX'` |
| `lib/features/community/community_strings.dart:461` | Nội dung/placeholder — đã rà theo VOICE | `'Mexico'` |
| `lib/features/community/community_strings.dart:462` | Nội dung/placeholder — đã rà theo VOICE | `'MY'` |
| `lib/features/community/community_strings.dart:462` | Nội dung/placeholder — đã rà theo VOICE | `'Malaysia'` |
| `lib/features/community/community_strings.dart:463` | Nội dung/placeholder — đã rà theo VOICE | `'NG'` |
| `lib/features/community/community_strings.dart:463` | Nội dung/placeholder — đã rà theo VOICE | `'Nigeria'` |
| `lib/features/community/community_strings.dart:464` | Nội dung/placeholder — đã rà theo VOICE | `'NI'` |
| `lib/features/community/community_strings.dart:464` | Nội dung/placeholder — đã rà theo VOICE | `'Nicaragua'` |
| `lib/features/community/community_strings.dart:465` | Nội dung/placeholder — đã rà theo VOICE | `'NL'` |
| `lib/features/community/community_strings.dart:465` | Nội dung/placeholder — đã rà theo VOICE | `'Hà Lan'` |
| `lib/features/community/community_strings.dart:466` | Nội dung/placeholder — đã rà theo VOICE | `'NO'` |
| `lib/features/community/community_strings.dart:466` | Nội dung/placeholder — đã rà theo VOICE | `'Na Uy'` |
| `lib/features/community/community_strings.dart:467` | Nội dung/placeholder — đã rà theo VOICE | `'NP'` |
| `lib/features/community/community_strings.dart:467` | Nội dung/placeholder — đã rà theo VOICE | `'Nepal'` |
| `lib/features/community/community_strings.dart:468` | Nội dung/placeholder — đã rà theo VOICE | `'NZ'` |
| `lib/features/community/community_strings.dart:468` | Nội dung/placeholder — đã rà theo VOICE | `'New Zealand'` |
| `lib/features/community/community_strings.dart:469` | Nội dung/placeholder — đã rà theo VOICE | `'OM'` |
| `lib/features/community/community_strings.dart:469` | Nội dung/placeholder — đã rà theo VOICE | `'Oman'` |
| `lib/features/community/community_strings.dart:470` | Nội dung/placeholder — đã rà theo VOICE | `'PA'` |
| `lib/features/community/community_strings.dart:470` | Nội dung/placeholder — đã rà theo VOICE | `'Panama'` |
| `lib/features/community/community_strings.dart:471` | Nội dung/placeholder — đã rà theo VOICE | `'PE'` |
| `lib/features/community/community_strings.dart:471` | Nội dung/placeholder — đã rà theo VOICE | `'Peru'` |
| `lib/features/community/community_strings.dart:472` | Nội dung/placeholder — đã rà theo VOICE | `'PH'` |
| `lib/features/community/community_strings.dart:472` | Nội dung/placeholder — đã rà theo VOICE | `'Philippines'` |
| `lib/features/community/community_strings.dart:473` | Nội dung/placeholder — đã rà theo VOICE | `'PK'` |
| `lib/features/community/community_strings.dart:473` | Nội dung/placeholder — đã rà theo VOICE | `'Pakistan'` |
| `lib/features/community/community_strings.dart:474` | Nội dung/placeholder — đã rà theo VOICE | `'PL'` |
| `lib/features/community/community_strings.dart:474` | Nội dung/placeholder — đã rà theo VOICE | `'Ba Lan'` |
| `lib/features/community/community_strings.dart:475` | Nội dung/placeholder — đã rà theo VOICE | `'PR'` |
| `lib/features/community/community_strings.dart:475` | Nội dung/placeholder — đã rà theo VOICE | `'Puerto Rico'` |
| `lib/features/community/community_strings.dart:476` | Nội dung/placeholder — đã rà theo VOICE | `'PT'` |
| `lib/features/community/community_strings.dart:476` | Nội dung/placeholder — đã rà theo VOICE | `'Bồ Đào Nha'` |
| `lib/features/community/community_strings.dart:477` | Nội dung/placeholder — đã rà theo VOICE | `'PY'` |
| `lib/features/community/community_strings.dart:477` | Nội dung/placeholder — đã rà theo VOICE | `'Paraguay'` |
| `lib/features/community/community_strings.dart:478` | Nội dung/placeholder — đã rà theo VOICE | `'QA'` |
| `lib/features/community/community_strings.dart:478` | Nội dung/placeholder — đã rà theo VOICE | `'Qatar'` |
| `lib/features/community/community_strings.dart:479` | Nội dung/placeholder — đã rà theo VOICE | `'RO'` |
| `lib/features/community/community_strings.dart:479` | Nội dung/placeholder — đã rà theo VOICE | `'Romania'` |
| `lib/features/community/community_strings.dart:480` | Nội dung/placeholder — đã rà theo VOICE | `'RS'` |
| `lib/features/community/community_strings.dart:480` | Nội dung/placeholder — đã rà theo VOICE | `'Serbia'` |
| `lib/features/community/community_strings.dart:481` | Nội dung/placeholder — đã rà theo VOICE | `'RU'` |
| `lib/features/community/community_strings.dart:481` | Nội dung/placeholder — đã rà theo VOICE | `'Nga'` |
| `lib/features/community/community_strings.dart:482` | Nội dung/placeholder — đã rà theo VOICE | `'SA'` |
| `lib/features/community/community_strings.dart:482` | Nội dung/placeholder — đã rà theo VOICE | `'Ả Rập Xê Út'` |
| `lib/features/community/community_strings.dart:483` | Nội dung/placeholder — đã rà theo VOICE | `'SE'` |
| `lib/features/community/community_strings.dart:483` | Nội dung/placeholder — đã rà theo VOICE | `'Thụy Điển'` |
| `lib/features/community/community_strings.dart:484` | Nội dung/placeholder — đã rà theo VOICE | `'SG'` |
| `lib/features/community/community_strings.dart:484` | Nội dung/placeholder — đã rà theo VOICE | `'Singapore'` |
| `lib/features/community/community_strings.dart:485` | Nội dung/placeholder — đã rà theo VOICE | `'SI'` |
| `lib/features/community/community_strings.dart:485` | Nội dung/placeholder — đã rà theo VOICE | `'Slovenia'` |
| `lib/features/community/community_strings.dart:486` | Nội dung/placeholder — đã rà theo VOICE | `'SK'` |
| `lib/features/community/community_strings.dart:486` | Nội dung/placeholder — đã rà theo VOICE | `'Slovakia'` |
| `lib/features/community/community_strings.dart:487` | Nội dung/placeholder — đã rà theo VOICE | `'SV'` |
| `lib/features/community/community_strings.dart:487` | Nội dung/placeholder — đã rà theo VOICE | `'El Salvador'` |
| `lib/features/community/community_strings.dart:488` | Nội dung/placeholder — đã rà theo VOICE | `'TH'` |
| `lib/features/community/community_strings.dart:488` | Nội dung/placeholder — đã rà theo VOICE | `'Thái Lan'` |
| `lib/features/community/community_strings.dart:489` | Nội dung/placeholder — đã rà theo VOICE | `'TL'` |
| `lib/features/community/community_strings.dart:489` | Nội dung/placeholder — đã rà theo VOICE | `'Đông Timor'` |
| `lib/features/community/community_strings.dart:490` | Nội dung/placeholder — đã rà theo VOICE | `'TN'` |
| `lib/features/community/community_strings.dart:490` | Nội dung/placeholder — đã rà theo VOICE | `'Tunisia'` |
| `lib/features/community/community_strings.dart:491` | Nội dung/placeholder — đã rà theo VOICE | `'TR'` |
| `lib/features/community/community_strings.dart:491` | Nội dung/placeholder — đã rà theo VOICE | `'Thổ Nhĩ Kỳ'` |
| `lib/features/community/community_strings.dart:492` | Nội dung/placeholder — đã rà theo VOICE | `'TW'` |
| `lib/features/community/community_strings.dart:492` | Nội dung/placeholder — đã rà theo VOICE | `'Đài Loan'` |
| `lib/features/community/community_strings.dart:493` | Nội dung/placeholder — đã rà theo VOICE | `'UA'` |
| `lib/features/community/community_strings.dart:493` | Nội dung/placeholder — đã rà theo VOICE | `'Ukraine'` |
| `lib/features/community/community_strings.dart:494` | Nội dung/placeholder — đã rà theo VOICE | `'US'` |
| `lib/features/community/community_strings.dart:494` | Nội dung/placeholder — đã rà theo VOICE | `'Hoa Kỳ'` |
| `lib/features/community/community_strings.dart:495` | Nội dung/placeholder — đã rà theo VOICE | `'UY'` |
| `lib/features/community/community_strings.dart:495` | Nội dung/placeholder — đã rà theo VOICE | `'Uruguay'` |
| `lib/features/community/community_strings.dart:496` | Nội dung/placeholder — đã rà theo VOICE | `'UZ'` |
| `lib/features/community/community_strings.dart:496` | Nội dung/placeholder — đã rà theo VOICE | `'Uzbekistan'` |
| `lib/features/community/community_strings.dart:497` | Nội dung/placeholder — đã rà theo VOICE | `'VE'` |
| `lib/features/community/community_strings.dart:497` | Nội dung/placeholder — đã rà theo VOICE | `'Venezuela'` |
| `lib/features/community/community_strings.dart:498` | Nội dung/placeholder — đã rà theo VOICE | `'VN'` |
| `lib/features/community/community_strings.dart:498` | Nội dung/placeholder — đã rà theo VOICE | `'Việt Nam'` |
| `lib/features/community/community_strings.dart:499` | Nội dung/placeholder — đã rà theo VOICE | `'ZA'` |
| `lib/features/community/community_strings.dart:499` | Nội dung/placeholder — đã rà theo VOICE | `'Nam Phi'` |
| `lib/features/community/community_strings.dart:503` | Nội dung/placeholder — đã rà theo VOICE | `'Dịch bằng Google'` |
| `lib/features/community/community_strings.dart:504` | Nội dung/placeholder — đã rà theo VOICE | `'Đang dịch…'` |
| `lib/features/community/community_strings.dart:505` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tải gói dịch…'` |
| `lib/features/community/community_strings.dart:506` | Nội dung/placeholder — đã rà theo VOICE | `'Xem bản gốc'` |
| `lib/features/community/community_strings.dart:507` | Nội dung/placeholder — đã rà theo VOICE | `'Xem bản dịch'` |
| `lib/features/community/community_strings.dart:508` | Nội dung/placeholder — đã rà theo VOICE | `'Dịch tự động bởi Google'` |
| `lib/features/community/community_strings.dart:509` | Nội dung/placeholder — đã rà theo VOICE | `'Không dịch được. Hãy thử lại.'` |
| `lib/features/community/community_strings.dart:510` | Nội dung/placeholder — đã rà theo VOICE | `'Thiết bị này chưa hỗ trợ dịch trên máy.'` |
| `lib/features/community/community_strings.dart:511` | Nội dung/placeholder — đã rà theo VOICE | `'Tải gói dịch trên máy?'` |
| `lib/features/community/community_strings.dart:513` | Nội dung/placeholder — đã rà theo VOICE | `'Để dịch từ $from sang $to, ValVN cần tải gói ngôn ngữ từ Google (khoảng $size). '` |
| `lib/features/community/community_strings.dart:514` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ tải một lần; nội dung được dịch hoàn toàn trên máy của bạn và '` |
| `lib/features/community/community_strings.dart:515` | Nội dung/placeholder — đã rà theo VOICE | `'không gửi tới máy chủ nào.'` |
| `lib/features/community/community_strings.dart:516` | Nội dung/placeholder — đã rà theo VOICE | `'$mb MB'` |
| `lib/features/community/community_strings.dart:517` | Nội dung/placeholder — đã rà theo VOICE | `'Tải và dịch'` |
| `lib/features/community/community_strings.dart:518` | Nội dung/placeholder — đã rà theo VOICE | `'Bản dịch của Google'` |
| `lib/features/community/community_strings.dart:520` | Nội dung/placeholder — đã rà theo VOICE | `'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE '` |
| `lib/features/community/community_strings.dart:521` | Nội dung/placeholder — đã rà theo VOICE | `'DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR '` |
| `lib/features/community/community_strings.dart:522` | Nội dung/placeholder — đã rà theo VOICE | `'IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY '` |
| `lib/features/community/community_strings.dart:523` | Nội dung/placeholder — đã rà theo VOICE | `'IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR '` |
| `lib/features/community/community_strings.dart:524` | Nội dung/placeholder — đã rà theo VOICE | `'PURPOSE AND NONINFRINGEMENT.'` |
| `lib/features/community/community_strings.dart:527` | Nội dung/placeholder — đã rà theo VOICE | `'Dữ liệu Cộng đồng của bạn'` |
| `lib/features/community/community_strings.dart:529` | Nội dung/placeholder — đã rà theo VOICE | `'Áp dụng cho tài khoản đang dùng: $riotId. Tệp tải về không chứa mật '` |
| `lib/features/community/community_strings.dart:530` | Nội dung/placeholder — đã rà theo VOICE | `'khẩu hay dữ liệu đăng nhập Riot.'` |
| `lib/features/community/community_strings.dart:532` | Nội dung/placeholder — đã rà theo VOICE | `'Tải dữ liệu của tôi'` |
| `lib/features/community/community_strings.dart:534` | Nội dung/placeholder — đã rà theo VOICE | `'Bản sao mọi thứ bạn đã đăng trong Cộng đồng: bài viết, bình luận, đánh '` |
| `lib/features/community/community_strings.dart:535` | Nội dung/placeholder — đã rà theo VOICE | `'giá, lượt thích, bình chọn và tin tìm đồng đội.'` |
| `lib/features/community/community_strings.dart:536` | Nội dung/placeholder — đã rà theo VOICE | `'Dữ liệu Cộng đồng ValVN'` |
| `lib/features/community/community_strings.dart:537` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chuẩn bị…'` |
| `lib/features/community/community_strings.dart:539` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa dữ liệu Cộng đồng của tôi'` |
| `lib/features/community/community_strings.dart:541` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa vĩnh viễn mọi thứ bạn đã đăng lên Cộng đồng.'` |
| `lib/features/community/community_strings.dart:542` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa dữ liệu Cộng đồng?'` |
| `lib/features/community/community_strings.dart:544` | Nội dung/placeholder — đã rà theo VOICE | `'Toàn bộ bài viết, bình luận, đánh giá skin, lượt thích, bình chọn, '` |
| `lib/features/community/community_strings.dart:545` | Nội dung/placeholder — đã rà theo VOICE | `'tin tìm đồng đội và ảnh của $riotId trên Cộng đồng ValVN sẽ bị xóa '` |
| `lib/features/community/community_strings.dart:546` | Nội dung/placeholder — đã rà theo VOICE | `'vĩnh viễn và không thể khôi phục. Bạn quay lại chế độ xem ẩn danh và '` |
| `lib/features/community/community_strings.dart:547` | Nội dung/placeholder — đã rà theo VOICE | `'cần đồng ý lại nếu muốn tham gia lần nữa.\n\n'` |
| `lib/features/community/community_strings.dart:548` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản Riot và dữ liệu trong game không bị ảnh hưởng. Hãy tải dữ '` |
| `lib/features/community/community_strings.dart:549` | Nội dung/placeholder — đã rà theo VOICE | `'liệu về trước nếu bạn muốn giữ một bản sao.'` |
| `lib/features/community/community_strings.dart:550` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa vĩnh viễn'` |
| `lib/features/community/community_strings.dart:551` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa dữ liệu Cộng đồng của bạn.'` |
| `lib/features/community/community_strings.dart:553` | Nội dung/placeholder — đã rà theo VOICE | `'Rút lại đồng ý'` |
| `lib/features/community/community_strings.dart:555` | Nội dung/placeholder — đã rà theo VOICE | `'Ngừng dùng Cộng đồng bằng tài khoản này. Bài đã đăng vẫn được giữ.'` |
| `lib/features/community/community_strings.dart:556` | Nội dung/placeholder — đã rà theo VOICE | `'Rút lại đồng ý?'` |
| `lib/features/community/community_strings.dart:558` | Nội dung/placeholder — đã rà theo VOICE | `'ValVN sẽ ngừng dùng Cộng đồng bằng $riotId: kết nối Cộng đồng trên '` |
| `lib/features/community/community_strings.dart:559` | Nội dung/placeholder — đã rà theo VOICE | `'thiết bị này bị xóa và bạn quay lại chế độ xem ẩn danh.\n\n'` |
| `lib/features/community/community_strings.dart:560` | Nội dung/placeholder — đã rà theo VOICE | `'Bài viết, bình luận, đánh giá, bình chọn và tin tìm đồng đội đã đăng '` |
| `lib/features/community/community_strings.dart:561` | Nội dung/placeholder — đã rà theo VOICE | `'vẫn còn trên '` |
| `lib/features/community/community_strings.dart:562` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng và vẫn hiện Riot ID của bạn cho đến khi bạn xóa chúng từng '` |
| `lib/features/community/community_strings.dart:563` | Nội dung/placeholder — đã rà theo VOICE | `'cái, hoặc chọn "Xóa dữ liệu Cộng đồng của tôi". Bạn có thể tham gia '` |
| `lib/features/community/community_strings.dart:564` | Nội dung/placeholder — đã rà theo VOICE | `'lại bất cứ lúc nào.'` |
| `lib/features/community/community_strings.dart:565` | Nội dung/placeholder — đã rà theo VOICE | `'Rút lại'` |
| `lib/features/community/community_strings.dart:567` | Nội dung/placeholder — đã rà theo VOICE | `'Đã rút lại đồng ý. Bạn đang xem Cộng đồng ẩn danh.'` |
| `lib/features/community/community_strings.dart:570` | Nội dung/placeholder — đã rà theo VOICE | `'Tham gia Cộng đồng ValVN'` |
| `lib/features/community/community_strings.dart:571` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản: $riotId'` |
| `lib/features/community/community_strings.dart:573` | Nội dung/placeholder — đã rà theo VOICE | `'Khi cần xác minh Riot ID, ValVN gửi quyền truy cập Riot của bạn cho '` |
| `lib/features/community/community_strings.dart:574` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng ValVN. Cộng đồng dùng xong là bỏ ngay, không lưu.'` |
| `lib/features/community/community_strings.dart:576` | Nội dung/placeholder — đã rà theo VOICE | `'Người khác sẽ thấy Riot ID, thẻ người chơi, rank và quốc gia của bạn.'` |
| `lib/features/community/community_strings.dart:578` | Nội dung/placeholder — đã rà theo VOICE | `'Mật khẩu và dữ liệu đăng nhập khác của bạn luôn ở lại trên thiết bị '` |
| `lib/features/community/community_strings.dart:579` | Nội dung/placeholder — đã rà theo VOICE | `'này. Bạn có thể rút lại đồng ý trong Cài đặt.'` |
| `lib/features/community/community_strings.dart:580` | Nội dung/placeholder — đã rà theo VOICE | `'Chính sách quyền riêng tư'` |
| `lib/features/community/community_strings.dart:581` | Nội dung/placeholder — đã rà theo VOICE | `'Tiêu chuẩn cộng đồng'` |
| `lib/features/community/community_strings.dart:582` | Nội dung/placeholder — đã rà theo VOICE | `'Đồng ý và tiếp tục'` |
| `lib/features/community/community_strings.dart:583` | Nội dung/placeholder — đã rà theo VOICE | `'Để sau'` |
| `lib/features/community/community_strings.dart:584` | Nội dung/placeholder — đã rà theo VOICE | `'Xem lại và tham gia'` |
| `lib/features/community/community_strings.dart:586` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đang xem ẩn danh — tham gia để đăng bài, bình chọn và tìm đồng đội.'` |
| `lib/features/community/community_strings.dart:587` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm đồng đội dành cho thành viên'` |
| `lib/features/community/community_strings.dart:589` | Nội dung/placeholder — đã rà theo VOICE | `'Tham gia (xác minh Riot ID một lần) để xem tin của người chơi cùng máy '` |
| `lib/features/community/community_strings.dart:590` | Nội dung/placeholder — đã rà theo VOICE | `'chủ và đăng tin tìm đồng đội của bạn. Bạn vẫn xem Bảng tin và Xếp hạng '` |
| `lib/features/community/community_strings.dart:591` | Nội dung/placeholder — đã rà theo VOICE | `'skin bình thường.'` |
| `lib/features/community/community_strings.dart:593` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy đồng ý chia sẻ Riot ID với Cộng đồng để tiếp tục.'` |
| `lib/features/home/home_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Trang chủ'` |
| `lib/features/home/home_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Tùy chỉnh Trang chủ'` |
| `lib/features/home/home_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Kéo để sắp xếp. Tắt để ẩn thẻ.'` |
| `lib/features/home/home_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Khôi phục mặc định'` |
| `lib/features/home/home_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Ẩn thẻ này'` |
| `lib/features/home/home_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Đã ẩn "$name"'` |
| `lib/features/home/home_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Hoàn tác'` |
| `lib/features/home/home_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Tùy chọn cho $name'` |
| `lib/features/home/home_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đã ẩn mọi thẻ'` |
| `lib/features/home/home_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Mở Tùy chỉnh Trang chủ để hiện lại.'` |
| `lib/features/home/home_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có gì mới'` |
| `lib/features/home/home_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Kéo xuống để làm mới.'` |
| `lib/features/home/home_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng nhập của $riotId đã hết hạn. Đăng nhập lại để xem cửa hàng, rank '` |
| `lib/features/home/home_strings.dart:25` | Nội dung/placeholder — đã rà theo VOICE | `'và Battle Pass.'` |
| `lib/features/home/home_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Đã chuyển đến $name'` |
| `lib/features/home/home_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Trận hiện tại'` |
| `lib/features/home/home_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện khi bạn đang tìm trận, chọn đặc vụ hoặc trong trận.'` |
| `lib/features/home/home_strings.dart:34` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng hôm nay'` |
| `lib/features/home/home_strings.dart:35` | Nội dung/placeholder — đã rà theo VOICE | `'Skin hằng ngày, wishlist và Chợ Đêm.'` |
| `lib/features/home/home_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Rank & phong độ'` |
| `lib/features/home/home_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Rank, RR hôm nay, chuỗi trận và số trận lên rank.'` |
| `lib/features/home/home_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'Battle Pass'` |
| `lib/features/home/home_strings.dart:40` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp, XP cần mỗi ngày và nhiệm vụ tuần.'` |
| `lib/features/home/home_strings.dart:41` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn bè đang chơi'` |
| `lib/features/home/home_strings.dart:42` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn bè đang trong trận hoặc đang tìm trận.'` |
| `lib/features/home/home_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'Cộng đồng'` |
| `lib/features/home/home_strings.dart:45` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm đồng đội hợp rank và skin được yêu thích trong tuần.'` |
| `lib/features/home/home_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản khác'` |
| `lib/features/home/home_strings.dart:48` | Nội dung/placeholder — đã rà theo VOICE | `'Trạng thái và wishlist của các tài khoản còn lại.'` |
| `lib/features/home/home_strings.dart:49` | Nội dung/placeholder — đã rà theo VOICE | `'Trạng thái máy chủ'` |
| `lib/features/home/home_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ hiện khi có bảo trì hoặc sự cố.'` |
| `lib/features/home/home_strings.dart:54` | Nội dung/placeholder — đã rà theo VOICE | `'Đội bạn $ally, đội địch $enemy'` |
| `lib/features/home/home_strings.dart:55` | Nội dung/placeholder — đã rà theo VOICE | `'Đội bạn'` |
| `lib/features/home/home_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Đội địch'` |
| `lib/features/home/home_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tìm trận, đã chờ $coarse'` |
| `lib/features/home/home_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới sau $time'` |
| `lib/features/home/home_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'Đang làm mới…'` |
| `lib/features/home/home_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'Có skin trong wishlist!'` |
| `lib/features/home/home_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'$n skin trong wishlist đang bán'` |
| `lib/features/home/home_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Tổng $vp'` |
| `lib/features/home/home_strings.dart:69` | Nội dung/placeholder — đã rà theo VOICE | `'Ví $vp · đủ mua $affordable skin'` |
| `lib/features/home/home_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm'` |
| `lib/features/home/home_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'$n ưu đãi đang chờ bạn lật'` |
| `lib/features/home/home_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'$pct · $name · $price'` |
| `lib/features/home/home_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'Mới'` |
| `lib/features/home/home_strings.dart:75` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $time'` |
| `lib/features/home/home_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'$name, $price, $tier${wished ? '` |
| `lib/features/home/home_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `' : '` |
| `lib/features/home/home_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'}'` |
| `lib/features/home/home_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'trong wishlist'` |
| `lib/features/home/home_strings.dart:85` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $rr RR lên rank'` |
| `lib/features/home/home_strings.dart:86` | Nội dung/placeholder — đã rà theo VOICE | `'Hôm nay $value'` |
| `lib/features/home/home_strings.dart:87` | Nội dung/placeholder — đã rà theo VOICE | `'$day: $value'` |
| `lib/features/home/home_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `'Hôm nay ${net >= 0 ? '` |
| `lib/features/home/home_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `' : '` |
| `lib/features/home/home_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `'} ${net.abs()} RR, $wins thắng, '` |
| `lib/features/home/home_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'$losses thua'` |
| `lib/features/home/home_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'$w thắng – $l thua, $d hòa'` |
| `lib/features/home/home_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'$w thắng – $l thua'` |
| `lib/features/home/home_strings.dart:93` | Nội dung/placeholder — đã rà theo VOICE | `'Hôm nay chưa đấu xếp hạng'` |
| `lib/features/home/home_strings.dart:94` | Nội dung/placeholder — đã rà theo VOICE | `'Chuỗi $n trận thắng'` |
| `lib/features/home/home_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'Chuỗi $n trận thua'` |
| `lib/features/home/home_strings.dart:96` | Nội dung/placeholder — đã rà theo VOICE | `'≈ $n trận để lên $rank'` |
| `lib/features/home/home_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Phần trước: $rank'` |
| `lib/features/home/home_strings.dart:98` | Nội dung/placeholder — đã rà theo VOICE | `'Hạng $pos trên bảng xếp hạng'` |
| `lib/features/home/home_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'$n bạn đang chơi'` |
| `lib/features/home/home_strings.dart:102` | Nội dung/placeholder — đã rà theo VOICE | `'Xem bạn bè nào đang chơi?'` |
| `lib/features/home/home_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'Để biết bạn bè nào đang chơi, ValVN sẽ kết nối trò chuyện Riot của tài '` |
| `lib/features/home/home_strings.dart:105` | Nội dung/placeholder — đã rà theo VOICE | `'khoản đang dùng mỗi khi bạn mở Trang chủ. Bạn bè sẽ thấy bạn đang '` |
| `lib/features/home/home_strings.dart:106` | Nội dung/placeholder — đã rà theo VOICE | `'trực tuyến. Bạn có thể tắt trong Tùy chỉnh Trang chủ.'` |
| `lib/features/home/home_strings.dart:107` | Nội dung/placeholder — đã rà theo VOICE | `'Bật'` |
| `lib/features/home/home_strings.dart:108` | Nội dung/placeholder — đã rà theo VOICE | `'Không, ẩn thẻ'` |
| `lib/features/home/home_strings.dart:109` | Nội dung/placeholder — đã rà theo VOICE | `'Xem tất cả'` |
| `lib/features/home/home_strings.dart:110` | Nội dung/placeholder — đã rà theo VOICE | `'$name, $status'` |
| `lib/features/home/home_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'+$n'` |
| `lib/features/home/home_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm đồng đội hợp rank bạn'` |
| `lib/features/home/home_strings.dart:115` | Nội dung/placeholder — đã rà theo VOICE | `'Cần $n người'` |
| `lib/features/home/home_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'Skin được yêu thích tuần này'` |
| `lib/features/home/home_strings.dart:117` | Nội dung/placeholder — đã rà theo VOICE | `'$n lượt thích'` |
| `lib/features/home/home_strings.dart:118` | Nội dung/placeholder — đã rà theo VOICE | `'Xem tất cả tin tìm đồng đội'` |
| `lib/features/home/home_strings.dart:119` | Nội dung/placeholder — đã rà theo VOICE | `'Xem bảng xếp hạng skin'` |
| `lib/features/home/home_strings.dart:121` | Nội dung/placeholder — đã rà theo VOICE | `'$author, $details'` |
| `lib/features/home/home_strings.dart:122` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $time'` |
| `lib/features/home/home_strings.dart:125` | Nội dung/placeholder — đã rà theo VOICE | `'Tài khoản khác ($n)'` |
| `lib/features/home/home_strings.dart:126` | Nội dung/placeholder — đã rà theo VOICE | `'Có skin trong wishlist'` |
| `lib/features/home/home_strings.dart:127` | Nội dung/placeholder — đã rà theo VOICE | `'+$n tài khoản'` |
| `lib/features/home/home_strings.dart:130` | Nội dung/placeholder — đã rà theo VOICE | `'Đang bảo trì · $region'` |
| `lib/features/home/home_strings.dart:132` | Nội dung/placeholder — đã rà theo VOICE | `'Sắp bảo trì · $region'` |
| `lib/features/home/home_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'Sự cố máy chủ · $region'` |
| `lib/features/home/home_strings.dart:134` | Nội dung/placeholder — đã rà theo VOICE | `'+$n thông báo'` |
| `lib/features/home/home_strings.dart:135` | Nội dung/placeholder — đã rà theo VOICE | `'Chi tiết'` |
| `lib/features/home/home_strings.dart:138` | Nội dung/placeholder — đã rà theo VOICE | `' · '` |
| `lib/features/live_game/live_game_strings.dart:4` | Nội dung/placeholder — đã rà theo VOICE | `'Chi tiết trận'` |
| `lib/features/live_game/live_game_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới'` |
| `lib/features/live_game/live_game_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới ngay'` |
| `lib/features/live_game/live_game_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Đóng'` |
| `lib/features/live_game/live_game_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Tự làm mới sau $seconds giây'` |
| `lib/features/live_game/live_game_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chọn đặc vụ'` |
| `lib/features/live_game/live_game_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Đang diễn ra'` |
| `lib/features/live_game/live_game_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Đã kết thúc'` |
| `lib/features/live_game/live_game_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Trận hiện tại'` |
| `lib/features/live_game/live_game_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Không trong trận'` |
| `lib/features/live_game/live_game_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Đang ở sảnh chờ'` |
| `lib/features/live_game/live_game_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tìm trận'` |
| `lib/features/live_game/live_game_strings.dart:22` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chọn đặc vụ'` |
| `lib/features/live_game/live_game_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Đang đấu'` |
| `lib/features/live_game/live_game_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa cập nhật được trạng thái trận'` |
| `lib/features/live_game/live_game_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'$inQueue · $elapsed'` |
| `lib/features/live_game/live_game_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `' · '` |
| `lib/features/live_game/live_game_strings.dart:34` | Nội dung/placeholder — đã rà theo VOICE | `'$ally – $enemy'` |
| `lib/features/live_game/live_game_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn không ở trong trận nào'` |
| `lib/features/live_game/live_game_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Mở VALORANT và tìm trận — chi tiết trận sẽ tự hiện ở đây khi bạn vào '` |
| `lib/features/live_game/live_game_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'màn hình chọn đặc vụ.'` |
| `lib/features/live_game/live_game_strings.dart:41` | Nội dung/placeholder — đã rà theo VOICE | `'Khi tìm được trận, ValVN sẽ hiện đội hình và rank của mọi người.'` |
| `lib/features/live_game/live_game_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'Giữ ứng dụng mở — chi tiết trận sẽ hiện ngay khi tìm được trận.'` |
| `lib/features/live_game/live_game_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Mở tổ đội & hàng chờ'` |
| `lib/features/live_game/live_game_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'Tự động làm mới khi có trận.'` |
| `lib/features/live_game/live_game_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'Đặc vụ'` |
| `lib/features/live_game/live_game_strings.dart:51` | Nội dung/placeholder — đã rà theo VOICE | `'Đội của bạn'` |
| `lib/features/live_game/live_game_strings.dart:52` | Nội dung/placeholder — đã rà theo VOICE | `'Đội địch'` |
| `lib/features/live_game/live_game_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Người chơi'` |
| `lib/features/live_game/live_game_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Chạm để chọn thử, giữ để khóa đặc vụ.'` |
| `lib/features/live_game/live_game_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $t'` |
| `lib/features/live_game/live_game_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Đã khóa $agent'` |
| `lib/features/live_game/live_game_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đã khóa $agent'` |
| `lib/features/live_game/live_game_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đang chọn $agent'` |
| `lib/features/live_game/live_game_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa khóa được đặc vụ này. Hãy làm mới rồi thử lại.'` |
| `lib/features/live_game/live_game_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa chọn được đặc vụ này. Hãy làm mới rồi thử lại.'` |
| `lib/features/live_game/live_game_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn chưa sở hữu đặc vụ này.'` |
| `lib/features/live_game/live_game_strings.dart:68` | Nội dung/placeholder — đã rà theo VOICE | `'Đồng đội đã khóa đặc vụ này.'` |
| `lib/features/live_game/live_game_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa tải được danh sách đặc vụ. Hãy làm mới để thử lại.'` |
| `lib/features/live_game/live_game_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Đội địch sẽ hiện khi trận đấu bắt đầu.'` |
| `lib/features/live_game/live_game_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'Đội địch đã khóa $locked/$size'` |
| `lib/features/live_game/live_game_strings.dart:79` | Nội dung/placeholder — đã rà theo VOICE | `'Ẩn danh'` |
| `lib/features/live_game/live_game_strings.dart:80` | Nội dung/placeholder — đã rà theo VOICE | `'BẠN'` |
| `lib/features/live_game/live_game_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội'` |
| `lib/features/live_game/live_game_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa chọn đặc vụ'` |
| `lib/features/live_game/live_game_strings.dart:83` | Nội dung/placeholder — đã rà theo VOICE | `'Đã khóa'` |
| `lib/features/live_game/live_game_strings.dart:84` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có người chơi.'` |
| `lib/features/live_game/live_game_strings.dart:87` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $n'` |
| `lib/features/live_game/live_game_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'Cao nhất: $rank'` |
| `lib/features/live_game/live_game_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `'Không rõ rank'` |
| `lib/features/live_game/live_game_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Xem trang bị của $name'` |
| `lib/features/live_game/live_game_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'Tỉ số trực tiếp'` |
| `lib/features/live_game/live_game_strings.dart:98` | Nội dung/placeholder — đã rà theo VOICE | `'Rời trận'` |
| `lib/features/live_game/live_game_strings.dart:99` | Nội dung/placeholder — đã rà theo VOICE | `'Rời trận đấu?'` |
| `lib/features/live_game/live_game_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'Né trận ở màn hình chọn đặc vụ có thể khiến bạn bị phạt (mất RR, khóa '` |
| `lib/features/live_game/live_game_strings.dart:102` | Nội dung/placeholder — đã rà theo VOICE | `'hàng chờ). Bạn vẫn muốn rời?'` |
| `lib/features/live_game/live_game_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'Rời trận có thể khiến bạn bị phạt (mất RR, khóa hàng chờ). Bạn vẫn '` |
| `lib/features/live_game/live_game_strings.dart:105` | Nội dung/placeholder — đã rà theo VOICE | `'muốn rời?'` |
| `lib/features/live_game/live_game_strings.dart:106` | Nội dung/placeholder — đã rà theo VOICE | `'Đã rời trận.'` |
| `lib/features/live_game/live_game_strings.dart:107` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa rời được trận.'` |
| `lib/features/live_game/live_game_strings.dart:109` | Nội dung/placeholder — đã rà theo VOICE | `'Trận đã chuyển giai đoạn trong lúc bạn xác nhận. Chưa rời trận, hãy thử lại.'` |
| `lib/features/live_game/live_game_strings.dart:112` | Nội dung/placeholder — đã rà theo VOICE | `'Bảng điểm cuối trận'` |
| `lib/features/live_game/live_game_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn: $kda'` |
| `lib/features/live_game/live_game_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn: $kda · ACS $acs'` |
| `lib/features/live_game/live_game_strings.dart:117` | Nội dung/placeholder — đã rà theo VOICE | `'Xem chi tiết trận'` |
| `lib/features/live_game/live_game_strings.dart:119` | Nội dung/placeholder — đã rà theo VOICE | `'ValVN sẽ tự thử lại. Bảng điểm thường có sau khoảng một phút.'` |
| `lib/features/live_game/live_game_strings.dart:120` | Nội dung/placeholder — đã rà theo VOICE | `'K/D/A'` |
| `lib/features/live_game/live_game_strings.dart:121` | Nội dung/placeholder — đã rà theo VOICE | `'ACS'` |
| `lib/features/live_game/live_game_strings.dart:124` | Nội dung/placeholder — đã rà theo VOICE | `'Trang bị'` |
| `lib/features/live_game/live_game_strings.dart:127` | Nội dung/placeholder — đã rà theo VOICE | `'Trang bị của $name'` |
| `lib/features/live_game/live_game_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Vũ khí'` |
| `lib/features/live_game/live_game_strings.dart:129` | Nội dung/placeholder — đã rà theo VOICE | `'Hình phun sơn'` |
| `lib/features/live_game/live_game_strings.dart:130` | Nội dung/placeholder — đã rà theo VOICE | `'Flex'` |
| `lib/features/live_game/live_game_strings.dart:131` | Nội dung/placeholder — đã rà theo VOICE | `'Thẻ người chơi'` |
| `lib/features/live_game/live_game_strings.dart:132` | Nội dung/placeholder — đã rà theo VOICE | `'Không có thông tin trang bị của người chơi này.'` |
| `lib/features/live_game/live_game_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'Phụ kiện súng'` |
| `lib/features/live_game/live_game_strings.dart:135` | Nội dung/placeholder — đã rà theo VOICE | `'Trang bị trong trận này'` |
| `lib/features/live_game/live_game_strings.dart:136` | Nội dung/placeholder — đã rà theo VOICE | `'Trang bị lúc chọn đặc vụ'` |
| `lib/features/profile/profile_strings.dart:3` | Nội dung/placeholder — đã rà theo VOICE | `'Hồ sơ'` |
| `lib/features/profile/profile_strings.dart:4` | Nội dung/placeholder — đã rà theo VOICE | `'Tính toán lên hạng'` |
| `lib/features/profile/profile_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'RR theo ngày'` |
| `lib/features/profile/profile_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Chi tiết trận đấu'` |
| `lib/features/profile/profile_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Hồ sơ người chơi'` |
| `lib/features/profile/profile_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `' · '` |
| `lib/features/profile/profile_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `' #$tag'` |
| `lib/features/profile/profile_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Sao chép Riot ID'` |
| `lib/features/profile/profile_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Đã sao chép Riot ID'` |
| `lib/features/profile/profile_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $n'` |
| `lib/features/profile/profile_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'$xp / $perLevel XP'` |
| `lib/features/profile/profile_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện tại'` |
| `lib/features/profile/profile_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Cao nhất'` |
| `lib/features/profile/profile_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'$peakRank · $actTitle'` |
| `lib/features/profile/profile_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Theo lịch sử trên thiết bị'` |
| `lib/features/profile/profile_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa từng xếp hạng'` |
| `lib/features/profile/profile_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'≈ $matches trận để lên $rank'` |
| `lib/features/profile/profile_strings.dart:40` | Nội dung/placeholder — đã rà theo VOICE | `'Phần này: $wins thắng / $games trận · $rate'` |
| `lib/features/profile/profile_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'Bảng xếp hạng #$n'` |
| `lib/features/profile/profile_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Diễn biến RR'` |
| `lib/features/profile/profile_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'$n trận gần nhất'` |
| `lib/features/profile/profile_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'Hôm nay chưa có trận xếp hạng'` |
| `lib/features/profile/profile_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Hôm nay: $text'` |
| `lib/features/profile/profile_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội & hàng chờ'` |
| `lib/features/profile/profile_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn bè & trò chuyện'` |
| `lib/features/profile/profile_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Lịch sử đấu'` |
| `lib/features/profile/profile_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả'` |
| `lib/features/profile/profile_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Bản đồ'` |
| `lib/features/profile/profile_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'$filterMap: $map'` |
| `lib/features/profile/profile_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Lọc theo bản đồ'` |
| `lib/features/profile/profile_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có trận đấu nào.'` |
| `lib/features/profile/profile_strings.dart:68` | Nội dung/placeholder — đã rà theo VOICE | `'Không có trận nào ở chế độ này.'` |
| `lib/features/profile/profile_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Không có trận nào trên bản đồ này trong các '` |
| `lib/features/profile/profile_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'trận đã tải.'` |
| `lib/features/profile/profile_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Đã hiển thị tất cả trận đấu'` |
| `lib/features/profile/profile_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa tải được trận đấu'` |
| `lib/features/profile/profile_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'$k/$d/$a'` |
| `lib/features/profile/profile_strings.dart:79` | Nội dung/placeholder — đã rà theo VOICE | `'K/D/A ${kdaValue(k, d, a)}'` |
| `lib/features/profile/profile_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'$rank · $rr RR'` |
| `lib/features/profile/profile_strings.dart:85` | Nội dung/placeholder — đã rà theo VOICE | `'$a – $b'` |
| `lib/features/profile/profile_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'Hạng $n'` |
| `lib/features/profile/profile_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `'Hạng mục tiêu'` |
| `lib/features/profile/profile_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Hạng của bạn'` |
| `lib/features/profile/profile_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'Còn thiếu $n RR'` |
| `lib/features/profile/profile_strings.dart:96` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đã đạt hạng này.'` |
| `lib/features/profile/profile_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Với phong độ hiện tại'` |
| `lib/features/profile/profile_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'$atCurrentForm ($gain / $loss mỗi trận)'` |
| `lib/features/profile/profile_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'≈ $n trận'` |
| `lib/features/profile/profile_strings.dart:107` | Nội dung/placeholder — đã rà theo VOICE | `'Tốt nhất: $n trận thắng liên tiếp'` |
| `lib/features/profile/profile_strings.dart:108` | Nội dung/placeholder — đã rà theo VOICE | `'Tỉ lệ thắng'` |
| `lib/features/profile/profile_strings.dart:109` | Nội dung/placeholder — đã rà theo VOICE | `'Số trận cần'` |
| `lib/features/profile/profile_strings.dart:113` | Nội dung/placeholder — đã rà theo VOICE | `'Phong độ gần đây: $w thắng – $l thua'` |
| `lib/features/profile/profile_strings.dart:115` | Nội dung/placeholder — đã rà theo VOICE | `'Ước tính dựa trên các trận xếp hạng gần đây, chưa tính các trận phân '` |
| `lib/features/profile/profile_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'hạng và cơ chế bảo vệ xuống hạng.'` |
| `lib/features/profile/profile_strings.dart:118` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy hoàn thành các trận phân hạng để dùng tính năng tính toán lên hạng.'` |
| `lib/features/profile/profile_strings.dart:120` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đã ở Bất Tử trở lên — tính năng này chỉ tính đến Bất Tử 1.'` |
| `lib/features/profile/profile_strings.dart:122` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có trận xếp hạng gần đây nào để ước tính phong độ.'` |
| `lib/features/profile/profile_strings.dart:126` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có trận xếp hạng nào được lưu trên thiết bị này.'` |
| `lib/features/profile/profile_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Lịch sử RR được lưu ngay trên thiết bị của bạn, kể cả các trận Riot '` |
| `lib/features/profile/profile_strings.dart:129` | Nội dung/placeholder — đã rà theo VOICE | `'không còn trả về.'` |
| `lib/features/profile/profile_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'$w thắng – $l thua – $d hòa'` |
| `lib/features/profile/profile_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'$w thắng – $l thua'` |
| `lib/features/profile/profile_strings.dart:136` | Nội dung/placeholder — đã rà theo VOICE | `'$from → $to'` |
| `lib/features/profile/profile_strings.dart:139` | Nội dung/placeholder — đã rà theo VOICE | `'$n trận'` |
| `lib/features/profile/profile_strings.dart:142` | Nội dung/placeholder — đã rà theo VOICE | `'Thành tích của bạn'` |
| `lib/features/profile/profile_strings.dart:143` | Nội dung/placeholder — đã rà theo VOICE | `'Thành tích'` |
| `lib/features/profile/profile_strings.dart:144` | Nội dung/placeholder — đã rà theo VOICE | `'Bảng điểm'` |
| `lib/features/profile/profile_strings.dart:145` | Nội dung/placeholder — đã rà theo VOICE | `'Bảng điểm xếp hạng'` |
| `lib/features/profile/profile_strings.dart:146` | Nội dung/placeholder — đã rà theo VOICE | `'Diễn biến vòng đấu'` |
| `lib/features/profile/profile_strings.dart:147` | Nội dung/placeholder — đã rà theo VOICE | `'ACS'` |
| `lib/features/profile/profile_strings.dart:148` | Nội dung/placeholder — đã rà theo VOICE | `'Điểm chiến đấu trung bình'` |
| `lib/features/profile/profile_strings.dart:149` | Nội dung/placeholder — đã rà theo VOICE | `'HS%'` |
| `lib/features/profile/profile_strings.dart:150` | Nội dung/placeholder — đã rà theo VOICE | `'ADR'` |
| `lib/features/profile/profile_strings.dart:151` | Nội dung/placeholder — đã rà theo VOICE | `'K/D/A'` |
| `lib/features/profile/profile_strings.dart:152` | Nội dung/placeholder — đã rà theo VOICE | `'First blood'` |
| `lib/features/profile/profile_strings.dart:153` | Nội dung/placeholder — đã rà theo VOICE | `'RR'` |
| `lib/features/profile/profile_strings.dart:156` | Nội dung/placeholder — đã rà theo VOICE | `'$n RR'` |
| `lib/features/profile/profile_strings.dart:157` | Nội dung/placeholder — đã rà theo VOICE | `'K'` |
| `lib/features/profile/profile_strings.dart:158` | Nội dung/placeholder — đã rà theo VOICE | `'D'` |
| `lib/features/profile/profile_strings.dart:159` | Nội dung/placeholder — đã rà theo VOICE | `'A'` |
| `lib/features/profile/profile_strings.dart:160` | Nội dung/placeholder — đã rà theo VOICE | `'+/−'` |
| `lib/features/profile/profile_strings.dart:161` | Nội dung/placeholder — đã rà theo VOICE | `'#'` |
| `lib/features/profile/profile_strings.dart:162` | Nội dung/placeholder — đã rà theo VOICE | `'MVP'` |
| `lib/features/profile/profile_strings.dart:163` | Nội dung/placeholder — đã rà theo VOICE | `'MVP đội'` |
| `lib/features/profile/profile_strings.dart:164` | Nội dung/placeholder — đã rà theo VOICE | `'Đội của bạn'` |
| `lib/features/profile/profile_strings.dart:165` | Nội dung/placeholder — đã rà theo VOICE | `'Đội địch'` |
| `lib/features/profile/profile_strings.dart:166` | Nội dung/placeholder — đã rà theo VOICE | `'Đội Xanh'` |
| `lib/features/profile/profile_strings.dart:167` | Nội dung/placeholder — đã rà theo VOICE | `'Đội Đỏ'` |
| `lib/features/profile/profile_strings.dart:168` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả người chơi'` |
| `lib/features/profile/profile_strings.dart:169` | Nội dung/placeholder — đã rà theo VOICE | `'Thời lượng'` |
| `lib/features/profile/profile_strings.dart:172` | Nội dung/placeholder — đã rà theo VOICE | `'$duration $d'` |
| `lib/features/profile/profile_strings.dart:175` | Nội dung/placeholder — đã rà theo VOICE | `'Vòng $n'` |
| `lib/features/profile/profile_strings.dart:176` | Nội dung/placeholder — đã rà theo VOICE | `'Hiệp 1'` |
| `lib/features/profile/profile_strings.dart:177` | Nội dung/placeholder — đã rà theo VOICE | `'Hiệp 2'` |
| `lib/features/profile/profile_strings.dart:178` | Nội dung/placeholder — đã rà theo VOICE | `'Hiệp phụ'` |
| `lib/features/profile/profile_strings.dart:179` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có thông tin từng vòng của trận này.'` |
| `lib/features/profile/profile_strings.dart:180` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có thông tin người chơi của trận này.'` |
| `lib/features/profile/profile_strings.dart:183` | Nội dung/placeholder — đã rà theo VOICE | `'$n hạ gục'` |
| `lib/features/profile/profile_strings.dart:186` | Nội dung/placeholder — đã rà theo VOICE | `'Đặt Spike ở $site'` |
| `lib/features/profile/profile_strings.dart:189` | Nội dung/placeholder — đã rà theo VOICE | `'Trận gần đây'` |
| `lib/features/profile/profile_strings.dart:190` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp ẩn'` |
| `lib/features/profile/profile_strings.dart:193` | Nội dung/placeholder — đã rà theo VOICE | `'Phong độ gần đây'` |
| `lib/features/profile/profile_strings.dart:194` | Nội dung/placeholder — đã rà theo VOICE | `'K/D'` |
| `lib/features/profile/profile_strings.dart:197` | Nội dung/placeholder — đã rà theo VOICE | `'Chuỗi $n trận thắng'` |
| `lib/features/profile/profile_strings.dart:200` | Nội dung/placeholder — đã rà theo VOICE | `'Chuỗi $n trận thua'` |
| `lib/features/profile/profile_strings.dart:204` | Nội dung/placeholder — đã rà theo VOICE | `'${w}T · ${l}B · ${d}H'` |
| `lib/features/profile/profile_strings.dart:204` | Nội dung/placeholder — đã rà theo VOICE | `'${w}T · ${l}B'` |
| `lib/features/profile/profile_strings.dart:208` | Nội dung/placeholder — đã rà theo VOICE | `'$games trận gần nhất: $w thắng, $l thua'` |
| `lib/features/profile/profile_strings.dart:211` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ lọc bản đồ'` |
| `lib/features/profile/profile_strings.dart:219` | Nội dung/placeholder — đã rà theo VOICE | `'$rr / 100 RR'` |
| `lib/features/profile/profile_strings.dart:220` | Nội dung/placeholder — đã rà theo VOICE | `'Mở tính toán lên hạng'` |
| `lib/features/profile/profile_strings.dart:223` | Nội dung/placeholder — đã rà theo VOICE | `'Đổi bên'` |
| `lib/features/profile/profile_strings.dart:224` | Nội dung/placeholder — đã rà theo VOICE | `'Thắng vòng'` |
| `lib/features/profile/profile_strings.dart:225` | Nội dung/placeholder — đã rà theo VOICE | `'Thua vòng'` |
| `lib/features/profile/profile_strings.dart:228` | Nội dung/placeholder — đã rà theo VOICE | `'Tiến độ tới hạng mục tiêu'` |
| `lib/features/profile/profile_strings.dart:239` | Nội dung/placeholder — đã rà theo VOICE | `'KAST'` |
| `lib/features/profile/profile_strings.dart:241` | Nội dung/placeholder — đã rà theo VOICE | `'Tỉ lệ vòng bạn hạ gục, hỗ trợ, sống sót hoặc được đồng đội hạ đối thủ vừa hạ bạn'` |
| `lib/features/profile/profile_strings.dart:242` | Nội dung/placeholder — đã rà theo VOICE | `'Phân bố phát bắn trúng'` |
| `lib/features/profile/profile_strings.dart:243` | Nội dung/placeholder — đã rà theo VOICE | `'Đầu'` |
| `lib/features/profile/profile_strings.dart:244` | Nội dung/placeholder — đã rà theo VOICE | `'Thân'` |
| `lib/features/profile/profile_strings.dart:245` | Nội dung/placeholder — đã rà theo VOICE | `'Chân'` |
| `lib/features/profile/profile_strings.dart:248` | Nội dung/placeholder — đã rà theo VOICE | `'$part $percent'` |
| `lib/features/profile/profile_strings.dart:251` | Nội dung/placeholder — đã rà theo VOICE | `'Chạm vào một vòng để xem từng pha hạ gục.'` |
| `lib/features/profile/profile_strings.dart:252` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có thông tin hạ gục trong vòng này.'` |
| `lib/features/profile/profile_strings.dart:253` | Nội dung/placeholder — đã rà theo VOICE | `'Spike'` |
| `lib/features/profile/profile_strings.dart:254` | Nội dung/placeholder — đã rà theo VOICE | `'Rơi từ trên cao'` |
| `lib/features/profile/profile_strings.dart:255` | Nội dung/placeholder — đã rà theo VOICE | `'Kỹ năng'` |
| `lib/features/profile/profile_strings.dart:256` | Nội dung/placeholder — đã rà theo VOICE | `'Xem pha hạ gục'` |
| `lib/features/profile/profile_strings.dart:257` | Nội dung/placeholder — đã rà theo VOICE | `'Ẩn pha hạ gục'` |
| `lib/features/profile/profile_strings.dart:266` | Nội dung/placeholder — đã rà theo VOICE | `'$killer hạ gục $victim ($time)'` |
| `lib/features/profile/profile_strings.dart:267` | Nội dung/placeholder — đã rà theo VOICE | `'$killer hạ gục $victim bằng $weapon ($time)'` |
| `lib/features/profile/profile_strings.dart:271` | Nội dung/placeholder — đã rà theo VOICE | `'$n ngày qua'` |
| `lib/features/profile/profile_strings.dart:274` | Nội dung/placeholder — đã rà theo VOICE | `'Ngày tính theo $zone'` |
| `lib/features/profile/profile_strings.dart:279` | Nội dung/placeholder — đã rà theo VOICE | `'−'` |
| `lib/features/profile/profile_strings.dart:279` | Nội dung/placeholder — đã rà theo VOICE | `'+'` |
| `lib/features/profile/profile_strings.dart:284` | Nội dung/placeholder — đã rà theo VOICE | `'UTC$sign$h'` |
| `lib/features/profile/profile_strings.dart:285` | Nội dung/placeholder — đã rà theo VOICE | `'UTC$sign$h:${m.toString().padLeft(2, '` |
| `lib/features/profile/profile_strings.dart:285` | Nội dung/placeholder — đã rà theo VOICE | `')}'` |
| `lib/features/profile/profile_strings.dart:286` | Nội dung/placeholder — đã rà theo VOICE | `'giờ thiết bị ($utc)'` |
| `lib/features/profile/profile_strings.dart:290` | Nội dung/placeholder — đã rà theo VOICE | `'$n ngày có trận'` |
| `lib/features/profile/profile_strings.dart:294` | Nội dung/placeholder — đã rà theo VOICE | `'T2'` |
| `lib/features/profile/profile_strings.dart:295` | Nội dung/placeholder — đã rà theo VOICE | `'T3'` |
| `lib/features/profile/profile_strings.dart:296` | Nội dung/placeholder — đã rà theo VOICE | `'T4'` |
| `lib/features/profile/profile_strings.dart:297` | Nội dung/placeholder — đã rà theo VOICE | `'T5'` |
| `lib/features/profile/profile_strings.dart:298` | Nội dung/placeholder — đã rà theo VOICE | `'T6'` |
| `lib/features/profile/profile_strings.dart:299` | Nội dung/placeholder — đã rà theo VOICE | `'T7'` |
| `lib/features/profile/profile_strings.dart:300` | Nội dung/placeholder — đã rà theo VOICE | `'CN'` |
| `lib/features/profile/profile_strings.dart:305` | Nội dung/placeholder — đã rà theo VOICE | `'Tiến độ tới $rank'` |
| `lib/features/profile/profile_strings.dart:308` | Nội dung/placeholder — đã rà theo VOICE | `'$rr RR khi thắng'` |
| `lib/features/profile/profile_strings.dart:311` | Nội dung/placeholder — đã rà theo VOICE | `'$rr RR khi thua'` |
| `lib/features/profile/profile_strings.dart:312` | Nội dung/placeholder — đã rà theo VOICE | `'Theo tỉ lệ thắng'` |
| `lib/features/profile/profile_strings.dart:313` | Nội dung/placeholder — đã rà theo VOICE | `'Tỉ lệ thắng gần đây của bạn'` |
| `lib/features/profile/profile_strings.dart:314` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn hạng bạn muốn đạt'` |
| `lib/features/settings/legal/legal_strings.dart:1` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_info.dart'` |
| `lib/features/settings/legal/legal_strings.dart:7` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'MỤC LỤC'` |
| `lib/features/settings/legal/legal_strings.dart:8` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phiên bản $version'` |
| `lib/features/settings/legal/legal_strings.dart:9` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Hiệu lực từ $date'` |
| `lib/features/settings/legal/legal_strings.dart:10` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Về đầu trang'` |
| `lib/features/settings/legal/legal_strings.dart:14` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Trợ thủ VALORANT của bạn: cửa hàng mỗi ngày, wishlist, rank, trận đấu, '` |
| `lib/features/settings/legal/legal_strings.dart:15` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhiều tài khoản và cộng đồng người chơi, ngay trên thiết bị của bạn.'` |
| `lib/features/settings/legal/legal_strings.dart:16` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'PHÁP LÝ'` |
| `lib/features/settings/legal/legal_strings.dart:17` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phần mềm bên thứ ba'` |
| `lib/features/settings/legal/legal_strings.dart:19` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Giấy phép của các phần mềm mã nguồn mở mà ValVN sử dụng'` |
| `lib/features/settings/legal/legal_strings.dart:20` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'LIÊN HỆ'` |
| `lib/features/settings/legal/legal_strings.dart:21` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Liên hệ'` |
| `lib/features/settings/legal/legal_strings.dart:23` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'NGUỒN DỮ LIỆU & GHI CÔNG'` |
| `lib/features/settings/legal/legal_strings.dart:29` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bằng việc tiếp tục, bạn đồng ý với '` |
| `lib/features/settings/legal/legal_strings.dart:30` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Điều khoản sử dụng'` |
| `lib/features/settings/legal/legal_strings.dart:31` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `' và '` |
| `lib/features/settings/legal/legal_strings.dart:32` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chính sách quyền riêng tư'` |
| `lib/features/settings/legal/legal_strings.dart:33` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `' của ValVN.'` |
| `lib/features/settings/settings_strings.dart:4` | Nội dung/placeholder — đã rà theo VOICE | `'Cài đặt'` |
| `lib/features/settings/settings_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Báo lỗi ValVN'` |
| `lib/features/settings/settings_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Giới thiệu & pháp lý'` |
| `lib/features/settings/settings_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Quyền riêng tư, điều khoản, bản quyền và liên hệ'` |
| `lib/features/settings/settings_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Val'` |
| `lib/features/settings/settings_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'VN'` |
| `lib/features/settings/settings_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng hằng ngày, Chợ Đêm và bundle'` |
| `lib/features/settings/settings_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Rank, lịch sử đấu, trận đang diễn ra'` |
| `lib/features/settings/settings_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Wishlist & thông báo'` |
| `lib/features/settings/settings_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đăng nhập trên trang chính thức của Riot. ValVN chỉ lưu mật khẩu khi bạn tự chọn lưu thông tin đăng nhập.'` |
| `lib/features/settings/settings_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Thông báo pháp lý'` |
| `lib/features/settings/settings_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Đừng bỏ lỡ skin bạn săn'` |
| `lib/features/settings/settings_strings.dart:25` | Nội dung/placeholder — đã rà theo VOICE | `'Bật thông báo để biết khi cửa hàng làm mới và khi skin trong wishlist '` |
| `lib/features/settings/settings_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'xuất hiện.'` |
| `lib/features/settings/settings_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Nhắc khi cửa hàng hằng ngày làm mới'` |
| `lib/features/settings/settings_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Mỗi ngày, vào giờ cửa hàng làm mới'` |
| `lib/features/settings/settings_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'Báo khi skin bạn săn xuất hiện'` |
| `lib/features/settings/settings_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Kiểm tra cửa hàng của mọi tài khoản, kể cả khi bạn không mở ứng dụng'` |
| `lib/features/settings/settings_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'Biết khi Chợ Đêm mở'` |
| `lib/features/settings/settings_strings.dart:34` | Nội dung/placeholder — đã rà theo VOICE | `'Để kịp lật thẻ ưu đãi trước khi hết hạn'` |
| `lib/features/settings/settings_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn có thể bật hoặc tắt từng loại thông báo bất cứ lúc nào trong Cài '` |
| `lib/features/settings/settings_strings.dart:37` | Nội dung/placeholder — đã rà theo VOICE | `'đặt.'` |
| `lib/features/settings/settings_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Bật thông báo'` |
| `lib/features/settings/settings_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'Để sau'` |
| `lib/features/settings/settings_strings.dart:42` | Nội dung/placeholder — đã rà theo VOICE | `'TÙY CHỌN'` |
| `lib/features/settings/settings_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'THÔNG BÁO'` |
| `lib/features/settings/settings_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'GIAO DIỆN'` |
| `lib/features/settings/settings_strings.dart:45` | Nội dung/placeholder — đã rà theo VOICE | `'HỖ TRỢ'` |
| `lib/features/settings/settings_strings.dart:49` | Nội dung/placeholder — đã rà theo VOICE | `'NÂNG CAO'` |
| `lib/features/settings/settings_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'THÔNG TIN'` |
| `lib/features/settings/settings_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Đã chuyển sang $account'` |
| `lib/features/settings/settings_strings.dart:54` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa $account'` |
| `lib/features/settings/settings_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'Tự động mở chi tiết trận'` |
| `lib/features/settings/settings_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Mở bảng trận hiện tại ngay khi tìm thấy trận'` |
| `lib/features/settings/settings_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện rank cao nhất trong chi tiết trận'` |
| `lib/features/settings/settings_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện tỉ số trực tiếp'` |
| `lib/features/settings/settings_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Nền tảng'` |
| `lib/features/settings/settings_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn nền tảng'` |
| `lib/features/settings/settings_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn PC, PlayStation hoặc Xbox theo nơi bạn chơi để xem đúng lịch sử đấu.'` |
| `lib/features/settings/settings_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Áp dụng cho $account'` |
| `lib/features/settings/settings_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện giá quy đổi ước tính'` |
| `lib/features/settings/settings_strings.dart:69` | Nội dung/placeholder — đã rà theo VOICE | `'Cạnh giá VP, ví dụ $vp $price'` |
| `lib/features/settings/settings_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có bảng giá đã xác minh cho khu vực của bạn — hãy nhập giá gói '` |
| `lib/features/settings/settings_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'VP của bạn.'` |
| `lib/features/settings/settings_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'Cách tính giá quy đổi'` |
| `lib/features/settings/settings_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'Giá gói VP của bạn'` |
| `lib/features/settings/settings_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa nhập — dùng bảng giá của khu vực nếu có'` |
| `lib/features/settings/settings_strings.dart:77` | Nội dung/placeholder — đã rà theo VOICE | `'$vp = $price'` |
| `lib/features/settings/settings_strings.dart:80` | Nội dung/placeholder — đã rà theo VOICE | `'Khi cửa hàng làm mới'` |
| `lib/features/settings/settings_strings.dart:83` | Nội dung/placeholder — đã rà theo VOICE | `'$time hằng ngày'` |
| `lib/features/settings/settings_strings.dart:84` | Nội dung/placeholder — đã rà theo VOICE | `'Khi skin trong wishlist xuất hiện'` |
| `lib/features/settings/settings_strings.dart:86` | Nội dung/placeholder — đã rà theo VOICE | `'Kiểm tra cửa hàng của mọi tài khoản, kể cả khi bạn không mở ứng dụng'` |
| `lib/features/settings/settings_strings.dart:87` | Nội dung/placeholder — đã rà theo VOICE | `'Khi Chợ Đêm mở'` |
| `lib/features/settings/settings_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'Nhắc bạn lật thẻ ưu đãi Chợ Đêm'` |
| `lib/features/settings/settings_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `'Ứng dụng chưa có quyền gửi thông báo.'` |
| `lib/features/settings/settings_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Chủ đề'` |
| `lib/features/settings/settings_strings.dart:93` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn chủ đề'` |
| `lib/features/settings/settings_strings.dart:94` | Nội dung/placeholder — đã rà theo VOICE | `'Tối'` |
| `lib/features/settings/settings_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'Sáng'` |
| `lib/features/settings/settings_strings.dart:96` | Nội dung/placeholder — đã rà theo VOICE | `'Theo hệ thống'` |
| `lib/features/settings/settings_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Tên vật phẩm'` |
| `lib/features/settings/settings_strings.dart:98` | Nội dung/placeholder — đã rà theo VOICE | `'Ngôn ngữ tên vật phẩm'` |
| `lib/features/settings/settings_strings.dart:100` | Nội dung/placeholder — đã rà theo VOICE | `'Tên skin, đặc vụ, bản đồ… hiển thị theo ngôn ngữ này.'` |
| `lib/features/settings/settings_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'Tiếng Việt'` |
| `lib/features/settings/settings_strings.dart:102` | Nội dung/placeholder — đã rà theo VOICE | `'Tiếng Anh'` |
| `lib/features/settings/settings_strings.dart:105` | Nội dung/placeholder — đã rà theo VOICE | `'Phiên bản $version'` |
| `lib/features/settings/settings_strings.dart:106` | Nội dung/placeholder — đã rà theo VOICE | `'Bản dựng $build'` |
| `lib/features/settings/settings_strings.dart:107` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa dữ liệu tạm'` |
| `lib/features/settings/settings_strings.dart:109` | Nội dung/placeholder — đã rà theo VOICE | `'Ảnh và dữ liệu đã tải về máy, kể cả báo lỗi đã ghi'` |
| `lib/features/settings/settings_strings.dart:110` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa $size'` |
| `lib/features/settings/settings_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa xóa được dữ liệu tạm. Hãy thử lại.'` |
| `lib/features/settings/settings_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'Gửi báo lỗi cho ValVN'` |
| `lib/features/settings/settings_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'Báo lỗi không chứa mật khẩu hay dữ liệu đăng nhập Riot của bạn.'` |
| `lib/features/settings/settings_strings.dart:120` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có gì để gửi. Hãy dùng ứng dụng một lúc rồi thử lại.'` |
| `lib/features/settings/settings_strings.dart:123` | Nội dung/placeholder — đã rà theo VOICE | `'Góp ý cho ValVN'` |
| `lib/features/settings/settings_strings.dart:124` | Nội dung/placeholder — đã rà theo VOICE | `'Mở trang góp ý của ValVN'` |
| `lib/features/settings/settings_strings.dart:125` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa mở được liên kết. Hãy thử lại.'` |
| `lib/features/settings/settings_strings.dart:126` | Nội dung/placeholder — đã rà theo VOICE | `'Trạng thái máy chủ'` |
| `lib/features/settings/settings_strings.dart:127` | Nội dung/placeholder — đã rà theo VOICE | `'Bảo trì và sự cố VALORANT theo máy chủ'` |
| `lib/features/settings/settings_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Đang bảo trì'` |
| `lib/features/settings/settings_strings.dart:129` | Nội dung/placeholder — đã rà theo VOICE | `'$n thông báo'` |
| `lib/features/settings/settings_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'Nguồn: trang trạng thái chính thức của Riot Games. Giờ hiển thị theo '` |
| `lib/features/settings/settings_strings.dart:134` | Nội dung/placeholder — đã rà theo VOICE | `'múi giờ của thiết bị.'` |
| `lib/features/settings/settings_strings.dart:135` | Nội dung/placeholder — đã rà theo VOICE | `'Máy chủ hoạt động bình thường'` |
| `lib/features/settings/settings_strings.dart:137` | Nội dung/placeholder — đã rà theo VOICE | `'Không có sự cố hay bảo trì nào ở máy chủ $region.'` |
| `lib/features/settings/settings_strings.dart:138` | Nội dung/placeholder — đã rà theo VOICE | `'Máy chủ đang bảo trì'` |
| `lib/features/settings/settings_strings.dart:140` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn có thể chưa vào được game, và ValVN có thể tạm thời chưa tải được '` |
| `lib/features/settings/settings_strings.dart:141` | Nội dung/placeholder — đã rà theo VOICE | `'thông tin.'` |
| `lib/features/settings/settings_strings.dart:142` | Nội dung/placeholder — đã rà theo VOICE | `'Riot đang xử lý sự cố'` |
| `lib/features/settings/settings_strings.dart:143` | Nội dung/placeholder — đã rà theo VOICE | `'Máy chủ này có $n thông báo sự cố.'` |
| `lib/features/settings/settings_strings.dart:144` | Nội dung/placeholder — đã rà theo VOICE | `'Sắp có bảo trì'` |
| `lib/features/settings/settings_strings.dart:146` | Nội dung/placeholder — đã rà theo VOICE | `'$n lịch bảo trì đã được Riot thông báo.'` |
| `lib/features/settings/settings_strings.dart:147` | Nội dung/placeholder — đã rà theo VOICE | `'Bảo trì'` |
| `lib/features/settings/settings_strings.dart:148` | Nội dung/placeholder — đã rà theo VOICE | `'Sự cố'` |
| `lib/features/settings/settings_strings.dart:149` | Nội dung/placeholder — đã rà theo VOICE | `'Thông tin'` |
| `lib/features/settings/settings_strings.dart:150` | Nội dung/placeholder — đã rà theo VOICE | `'Cảnh báo'` |
| `lib/features/settings/settings_strings.dart:151` | Nội dung/placeholder — đã rà theo VOICE | `'Nghiêm trọng'` |
| `lib/features/settings/settings_strings.dart:152` | Nội dung/placeholder — đã rà theo VOICE | `'Đã lên lịch'` |
| `lib/features/settings/settings_strings.dart:153` | Nội dung/placeholder — đã rà theo VOICE | `'Đang diễn ra'` |
| `lib/features/settings/settings_strings.dart:154` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xong'` |
| `lib/features/settings/settings_strings.dart:155` | Nội dung/placeholder — đã rà theo VOICE | `'Bắt đầu $when'` |
| `lib/features/settings/settings_strings.dart:156` | Nội dung/placeholder — đã rà theo VOICE | `'Cập nhật $when'` |
| `lib/features/settings/settings_strings.dart:157` | Nội dung/placeholder — đã rà theo VOICE | `'CẬP NHẬT TỪ RIOT'` |
| `lib/features/settings/settings_strings.dart:158` | Nội dung/placeholder — đã rà theo VOICE | `'Xem thêm $n cập nhật'` |
| `lib/features/settings/settings_strings.dart:159` | Nội dung/placeholder — đã rà theo VOICE | `'Thu gọn'` |
| `lib/features/settings/settings_strings.dart:160` | Nội dung/placeholder — đã rà theo VOICE | `'Máy chủ'` |
| `lib/features/settings/settings_strings.dart:164` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'windows'` |
| `lib/features/settings/settings_strings.dart:164` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'pc'` |
| `lib/features/settings/settings_strings.dart:164` | Nội dung/placeholder — đã rà theo VOICE | `'PC'` |
| `lib/features/settings/settings_strings.dart:165` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'macos'` |
| `lib/features/settings/settings_strings.dart:165` | Nội dung/placeholder — đã rà theo VOICE | `'Mac'` |
| `lib/features/settings/settings_strings.dart:166` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ps4'` |
| `lib/features/settings/settings_strings.dart:166` | Nội dung/placeholder — đã rà theo VOICE | `'PlayStation 4'` |
| `lib/features/settings/settings_strings.dart:167` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ps5'` |
| `lib/features/settings/settings_strings.dart:167` | Nội dung/placeholder — đã rà theo VOICE | `'PlayStation 5'` |
| `lib/features/settings/settings_strings.dart:168` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'playstation'` |
| `lib/features/settings/settings_strings.dart:168` | Nội dung/placeholder — đã rà theo VOICE | `'PlayStation'` |
| `lib/features/settings/settings_strings.dart:169` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'xbone'` |
| `lib/features/settings/settings_strings.dart:169` | Nội dung/placeholder — đã rà theo VOICE | `'Xbox One'` |
| `lib/features/settings/settings_strings.dart:170` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'xbox'` |
| `lib/features/settings/settings_strings.dart:170` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'xboxseries'` |
| `lib/features/settings/settings_strings.dart:170` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'xbox_series'` |
| `lib/features/settings/settings_strings.dart:170` | Nội dung/placeholder — đã rà theo VOICE | `'Xbox'` |
| `lib/features/settings/settings_strings.dart:171` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'android'` |
| `lib/features/settings/settings_strings.dart:171` | Nội dung/placeholder — đã rà theo VOICE | `'Android'` |
| `lib/features/settings/settings_strings.dart:172` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ios'` |
| `lib/features/settings/settings_strings.dart:172` | Nội dung/placeholder — đã rà theo VOICE | `'iOS'` |
| `lib/features/settings/settings_strings.dart:173` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'mobile'` |
| `lib/features/settings/settings_strings.dart:173` | Nội dung/placeholder — đã rà theo VOICE | `'Di động'` |
| `lib/features/settings/settings_strings.dart:174` | Nội dung/placeholder — đã rà theo VOICE | `'Nền tảng khác'` |
| `lib/features/settings/settings_strings.dart:178` | Nội dung/placeholder — đã rà theo VOICE | `'Đã đăng xuất tất cả tài khoản'` |
| `lib/features/settings/settings_strings.dart:181` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa gửi được báo lỗi. Hãy thử lại.'` |
| `lib/features/settings/settings_strings.dart:185` | Nội dung/placeholder — đã rà theo VOICE | `'$appName $version — Báo lỗi'` |
| `lib/features/settings/settings_strings.dart:190` | Nội dung/placeholder — đã rà theo VOICE | `'Báo lỗi không chứa mật khẩu hay dữ liệu đăng nhập Riot của bạn.'` |
| `lib/features/settings/settings_strings.dart:191` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có gì để gửi'` |
| `lib/features/settings/settings_strings.dart:192` | Nội dung/placeholder — đã rà theo VOICE | `'$count mục'` |
| `lib/features/settings/settings_strings.dart:193` | Nội dung/placeholder — đã rà theo VOICE | `'$shown / $total mục'` |
| `lib/features/settings/settings_strings.dart:194` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm trong báo lỗi…'` |
| `lib/features/settings/settings_strings.dart:195` | Nội dung/placeholder — đã rà theo VOICE | `'Không có mục phù hợp.'` |
| `lib/features/settings/settings_strings.dart:196` | Nội dung/placeholder — đã rà theo VOICE | `'Tùy chọn khác'` |
| `lib/features/settings/settings_strings.dart:197` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa báo lỗi đã ghi'` |
| `lib/features/settings/settings_strings.dart:198` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa báo lỗi đã ghi trên thiết bị này?'` |
| `lib/features/settings/settings_strings.dart:199` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa báo lỗi'` |
| `lib/features/settings/settings_strings.dart:200` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả'` |
| `lib/features/settings/settings_strings.dart:201` | Nội dung/placeholder — đã rà theo VOICE | `'Sự cố'` |
| `lib/features/settings/settings_strings.dart:202` | Nội dung/placeholder — đã rà theo VOICE | `'Kết nối'` |
| `lib/features/settings/settings_strings.dart:203` | Nội dung/placeholder — đã rà theo VOICE | `'Đăng nhập'` |
| `lib/features/settings/settings_strings.dart:204` | Nội dung/placeholder — đã rà theo VOICE | `'Không có mục phù hợp. Hãy bỏ lọc để xem thêm.'` |
| `lib/features/settings/settings_strings.dart:207` | Nội dung/placeholder — đã rà theo VOICE | `'TRỢ THỦ VALORANT'` |
| `lib/features/settings/settings_strings.dart:208` | Nội dung/placeholder — đã rà theo VOICE | `'Xem giá, độ hiếm, đếm ngược làm mới'` |
| `lib/features/settings/settings_strings.dart:209` | Nội dung/placeholder — đã rà theo VOICE | `'RR từng trận, rank đối thủ'` |
| `lib/features/settings/settings_strings.dart:210` | Nội dung/placeholder — đã rà theo VOICE | `'Báo khi skin bạn săn lên kệ'` |
| `lib/features/settings/settings_strings.dart:213` | Nội dung/placeholder — đã rà theo VOICE | `'NGUỒN DỮ LIỆU'` |
| `lib/features/settings/settings_strings.dart:214` | Ngoại lệ kỹ thuật cần ngữ cảnh (ghi công/trang Riot) | `'valorant-api.com'` |
| `lib/features/settings/settings_strings.dart:216` | Nội dung/placeholder — đã rà theo VOICE | `'Tên, hình ảnh và thông tin về skin, đặc vụ, bản đồ và rank.'` |
| `lib/features/settings/settings_strings.dart:217` | Nội dung/placeholder — đã rà theo VOICE | `'Riot Games'` |
| `lib/features/settings/settings_strings.dart:219` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng, ví, bộ sưu tập, trận đấu và xếp hạng lấy trực tiếp từ tài '` |
| `lib/features/settings/settings_strings.dart:220` | Nội dung/placeholder — đã rà theo VOICE | `'khoản Riot bạn đăng nhập.'` |
| `lib/features/settings/settings_strings.dart:221` | Nội dung/placeholder — đã rà theo VOICE | `'Tài liệu cộng đồng'` |
| `lib/features/settings/settings_strings.dart:223` | Ngoại lệ kỹ thuật cần ngữ cảnh (ghi công/trang Riot) | `'Dự án techchrism/valorant-api-docs và cộng đồng nhà phát triển '` |
| `lib/features/settings/settings_strings.dart:224` | Nội dung/placeholder — đã rà theo VOICE | `'VALORANT.'` |
| `lib/features/settings/settings_strings.dart:225` | Nội dung/placeholder — đã rà theo VOICE | `'PHÁP LÝ'` |
| `lib/features/settings/settings_strings.dart:230` | Nội dung/placeholder — đã rà theo VOICE | `'https://github.com/ndh0408/ValVN/issues'` |
| `lib/features/settings/settings_strings.dart:231` | Ngoại lệ kỹ thuật cần ngữ cảnh (ghi công/trang Riot) | `'https://valorant-api.com'` |
| `lib/features/settings/settings_strings.dart:233` | Ngoại lệ kỹ thuật cần ngữ cảnh (ghi công/trang Riot) | `'https://github.com/techchrism/valorant-api-docs'` |
| `lib/features/skin_detail/skin_detail_strings.dart:3` | Nội dung/placeholder — đã rà theo VOICE | `'Chi tiết skin'` |
| `lib/features/skin_detail/skin_detail_strings.dart:4` | Nội dung/placeholder — đã rà theo VOICE | `'Biến thể'` |
| `lib/features/skin_detail/skin_detail_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Nâng cấp'` |
| `lib/features/skin_detail/skin_detail_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Xem video'` |
| `lib/features/skin_detail/skin_detail_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm vào wishlist'` |
| `lib/features/skin_detail/skin_detail_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa khỏi wishlist'` |
| `lib/features/skin_detail/skin_detail_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Đã có trong wishlist'` |
| `lib/features/skin_detail/skin_detail_strings.dart:10` | Nội dung/placeholder — đã rà theo VOICE | `'Đã sở hữu'` |
| `lib/features/skin_detail/skin_detail_strings.dart:11` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa mở khóa'` |
| `lib/features/skin_detail/skin_detail_strings.dart:12` | Nội dung/placeholder — đã rà theo VOICE | `'Tắt tiếng'` |
| `lib/features/skin_detail/skin_detail_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Bật tiếng'` |
| `lib/features/skin_detail/skin_detail_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Phát'` |
| `lib/features/skin_detail/skin_detail_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Tạm dừng'` |
| `lib/features/skin_detail/skin_detail_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy skin này.'` |
| `lib/features/skin_detail/skin_detail_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Không phát được video. Kiểm tra mạng rồi thử lại.'` |
| `lib/features/skin_detail/skin_detail_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'$level · $item'` |
| `lib/features/skin_detail/skin_detail_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'$contract · $level'` |
| `lib/features/skin_detail/skin_detail_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'Có trong cửa hàng của: $accounts'` |
| `lib/features/social/social_strings.dart:4` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội & hàng chờ'` |
| `lib/features/social/social_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn bè & trò chuyện'` |
| `lib/features/social/social_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Trò chuyện'` |
| `lib/features/social/social_strings.dart:9` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm theo Riot ID…'` |
| `lib/features/social/social_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'$total bạn · $online đang trực tuyến'` |
| `lib/features/social/social_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Trực tuyến ($n)'` |
| `lib/features/social/social_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Ngoại tuyến ($n)'` |
| `lib/features/social/social_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chơi ($n)'` |
| `lib/features/social/social_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả'` |
| `lib/features/social/social_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Trực tuyến'` |
| `lib/features/social/social_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa đọc'` |
| `lib/features/social/social_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có bạn bè'` |
| `lib/features/social/social_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Không có bạn bè nào khớp bộ lọc này.'` |
| `lib/features/social/social_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Danh sách bạn bè Riot của bạn đang trống. Hãy kết bạn trong game.'` |
| `lib/features/social/social_strings.dart:24` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy bạn bè nào phù hợp.'` |
| `lib/features/social/social_strings.dart:25` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy'` |
| `lib/features/social/social_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Xem tất cả'` |
| `lib/features/social/social_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'$n tin chưa đọc'` |
| `lib/features/social/social_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'99+'` |
| `lib/features/social/social_strings.dart:28` | Nội dung/placeholder — đã rà theo VOICE | `'$n'` |
| `lib/features/social/social_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'Đang kết nối trò chuyện…'` |
| `lib/features/social/social_strings.dart:30` | Nội dung/placeholder — đã rà theo VOICE | `'Mất kết nối trò chuyện. Đang kết nối lại…'` |
| `lib/features/social/social_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Trò chuyện đang ngoại tuyến.'` |
| `lib/features/social/social_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Danh sách bạn bè và tin nhắn lấy trực tiếp từ Riot. ValVN không lưu '` |
| `lib/features/social/social_strings.dart:34` | Nội dung/placeholder — đã rà theo VOICE | `'chúng ở nơi nào khác.'` |
| `lib/features/social/social_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Đang đấu'` |
| `lib/features/social/social_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'$ally – $enemy'` |
| `lib/features/social/social_strings.dart:40` | Nội dung/placeholder — đã rà theo VOICE | `' · '` |
| `lib/features/social/social_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chọn đặc vụ'` |
| `lib/features/social/social_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chọn đặc vụ · $map'` |
| `lib/features/social/social_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tìm trận'` |
| `lib/features/social/social_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tìm trận · $queue'` |
| `lib/features/social/social_strings.dart:49` | Nội dung/placeholder — đã rà theo VOICE | `'Đang ở sảnh chờ · ${partyOf(partySize, maxPartySize ?? 5)}'` |
| `lib/features/social/social_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'Đang ở sảnh chờ'` |
| `lib/features/social/social_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội $size/$max'` |
| `lib/features/social/social_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Top $position'` |
| `lib/features/social/social_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'Đang ở trường bắn'` |
| `lib/features/social/social_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chơi tự do'` |
| `lib/features/social/social_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chơi tự do · $map'` |
| `lib/features/social/social_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Đang trong VALORANT'` |
| `lib/features/social/social_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Vắng mặt'` |
| `lib/features/social/social_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Trực tuyến'` |
| `lib/features/social/social_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Trực tuyến trên điện thoại'` |
| `lib/features/social/social_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chơi $game'` |
| `lib/features/social/social_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'Ngoại tuyến'` |
| `lib/features/social/social_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Hoạt động $relative'` |
| `lib/features/social/social_strings.dart:70` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'league_of_legends'` |
| `lib/features/social/social_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Liên Minh Huyền Thoại'` |
| `lib/features/social/social_strings.dart:71` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'bacon'` |
| `lib/features/social/social_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'Huyền Thoại Runeterra'` |
| `lib/features/social/social_strings.dart:72` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'lion'` |
| `lib/features/social/social_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'2XKO'` |
| `lib/features/social/social_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'Nhập tin nhắn…'` |
| `lib/features/social/social_strings.dart:77` | Nội dung/placeholder — đã rà theo VOICE | `'Gửi'` |
| `lib/features/social/social_strings.dart:78` | Nội dung/placeholder — đã rà theo VOICE | `'Bắt đầu trò chuyện'` |
| `lib/features/social/social_strings.dart:79` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có tin nhắn. Hãy gửi lời chào!'` |
| `lib/features/social/social_strings.dart:84` | Nội dung/placeholder — đã rà theo VOICE | `'Chào bạn!'` |
| `lib/features/social/social_strings.dart:85` | Nội dung/placeholder — đã rà theo VOICE | `'Làm vài trận không?'` |
| `lib/features/social/social_strings.dart:86` | Nội dung/placeholder — đã rà theo VOICE | `'Vào tổ đội với mình nhé!'` |
| `lib/features/social/social_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'Xem hồ sơ'` |
| `lib/features/social/social_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'Không gửi được tin nhắn. Kiểm tra kết nối rồi thử lại.'` |
| `lib/features/social/social_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa tải được tin nhắn cũ. Hãy kết nối lại rồi thử lại.'` |
| `lib/features/social/social_strings.dart:94` | Nội dung/placeholder — đã rà theo VOICE | `'Đang kết nối… Bạn có thể gửi tin khi kết nối xong.'` |
| `lib/features/social/social_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'Người này không có trong danh sách bạn bè.'` |
| `lib/features/social/social_strings.dart:96` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa gửi được'` |
| `lib/features/social/social_strings.dart:100` | Nội dung/placeholder — đã rà theo VOICE | `'Mở VALORANT trên máy tính hoặc máy chơi game'` |
| `lib/features/social/social_strings.dart:102` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội & hàng chờ chỉ hoạt động khi VALORANT đang chạy trên máy tính '` |
| `lib/features/social/social_strings.dart:103` | Nội dung/placeholder — đã rà theo VOICE | `'hoặc console của bạn. Mở game rồi kéo xuống để làm mới.'` |
| `lib/features/social/social_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'Tự động làm mới'` |
| `lib/features/social/social_strings.dart:108` | Nội dung/placeholder — đã rà theo VOICE | `'$size/$max người · ${open ? openState : closedState}'` |
| `lib/features/social/social_strings.dart:109` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội mở'` |
| `lib/features/social/social_strings.dart:110` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ người được mời'` |
| `lib/features/social/social_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'Hàng chờ'` |
| `lib/features/social/social_strings.dart:112` | Nội dung/placeholder — đã rà theo VOICE | `'Đổi hàng chờ'` |
| `lib/features/social/social_strings.dart:113` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn hàng chờ'` |
| `lib/features/social/social_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội $size người'` |
| `lib/features/social/social_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ chơi một mình'` |
| `lib/features/social/social_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'Tối đa $max người'` |
| `lib/features/social/social_strings.dart:117` | Nội dung/placeholder — đã rà theo VOICE | `'Đang chọn'` |
| `lib/features/social/social_strings.dart:118` | Nội dung/placeholder — đã rà theo VOICE | `'Thành viên ($n/$max)'` |
| `lib/features/social/social_strings.dart:119` | Nội dung/placeholder — đã rà theo VOICE | `'Trưởng nhóm'` |
| `lib/features/social/social_strings.dart:120` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn'` |
| `lib/features/social/social_strings.dart:121` | Nội dung/placeholder — đã rà theo VOICE | `'Sẵn sàng'` |
| `lib/features/social/social_strings.dart:122` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa sẵn sàng'` |
| `lib/features/social/social_strings.dart:123` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ sẵn sàng'` |
| `lib/features/social/social_strings.dart:124` | Nội dung/placeholder — đã rà theo VOICE | `'Bắt đầu tìm trận'` |
| `lib/features/social/social_strings.dart:125` | Nội dung/placeholder — đã rà theo VOICE | `'Hủy tìm trận · $elapsed'` |
| `lib/features/social/social_strings.dart:126` | Nội dung/placeholder — đã rà theo VOICE | `'Hủy tìm trận'` |
| `lib/features/social/social_strings.dart:127` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tìm trận · $elapsed'` |
| `lib/features/social/social_strings.dart:128` | Nội dung/placeholder — đã rà theo VOICE | `'Đã tìm thấy trận!'` |
| `lib/features/social/social_strings.dart:129` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội đang ở sảnh Chơi tự do.'` |
| `lib/features/social/social_strings.dart:131` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ trưởng nhóm mới có thể đổi hàng chờ và bắt đầu tìm trận.'` |
| `lib/features/social/social_strings.dart:132` | Nội dung/placeholder — đã rà theo VOICE | `'Không thể đổi hàng chờ khi đang trong trận.'` |
| `lib/features/social/social_strings.dart:134` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn đang trong trận. Hàng chờ sẽ mở lại khi trận kết thúc.'` |
| `lib/features/social/social_strings.dart:135` | Nội dung/placeholder — đã rà theo VOICE | `'Cấp $n'` |
| `lib/features/social/social_strings.dart:138` | Nội dung/placeholder — đã rà theo VOICE | `'$ms ms'` |
| `lib/features/social/social_strings.dart:139` | Nội dung/placeholder — đã rà theo VOICE | `'Ping tốt nhất tới máy chủ trận đấu'` |
| `lib/features/social/social_strings.dart:143` | Nội dung/placeholder — đã rà theo VOICE | `'Tổ đội chưa thể vào $queue: $reason'` |
| `lib/features/social/social_strings.dart:144` | Nội dung/placeholder — đã rà theo VOICE | `'chênh lệch rank quá lớn để đấu xếp hạng'` |
| `lib/features/social/social_strings.dart:146` | Nội dung/placeholder — đã rà theo VOICE | `'tổ đội quá đông (tối đa $max người)'` |
| `lib/features/social/social_strings.dart:147` | Nội dung/placeholder — đã rà theo VOICE | `'có thành viên chưa đủ cấp tài khoản'` |
| `lib/features/social/social_strings.dart:149` | Nội dung/placeholder — đã rà theo VOICE | `'tổ đội đang bị hạn chế tìm trận (còn $time)'` |
| `lib/features/social/social_strings.dart:150` | Nội dung/placeholder — đã rà theo VOICE | `'tổ đội chưa đủ điều kiện'` |
| `lib/features/social/social_strings.dart:154` | Nội dung/placeholder — đã rà theo VOICE | `'${s[0].toUpperCase()}${s.substring(1)}'` |
| `lib/features/social/social_strings.dart:156` | Nội dung/placeholder — đã rà theo VOICE | `'Mời bạn bè'` |
| `lib/features/social/social_strings.dart:158` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có bạn bè nào đang trực tuyến trong VALORANT.'` |
| `lib/features/social/social_strings.dart:159` | Nội dung/placeholder — đã rà theo VOICE | `'Đã gửi lời mời tới $name.'` |
| `lib/features/social/social_strings.dart:161` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa biết Riot ID của người này nên chưa thể mời.'` |
| `lib/features/social/social_strings.dart:162` | Nội dung/placeholder — đã rà theo VOICE | `'Mời $name'` |
| `lib/features/social/social_strings.dart:163` | Nội dung/placeholder — đã rà theo VOICE | `'$name · Đã mời'` |
| `lib/features/social/social_strings.dart:164` | Nội dung/placeholder — đã rà theo VOICE | `'Mời bằng Riot ID'` |
| `lib/features/social/social_strings.dart:165` | Nội dung/placeholder — đã rà theo VOICE | `'Mời cả người chưa kết bạn'` |
| `lib/features/social/social_strings.dart:166` | Nội dung/placeholder — đã rà theo VOICE | `'Tên#TAG'` |
| `lib/features/social/social_strings.dart:168` | Nội dung/placeholder — đã rà theo VOICE | `'Riot ID gồm tên (3–16 ký tự), dấu # và tag (3–5 chữ hoặc số).'` |
| `lib/features/social/social_strings.dart:169` | Nội dung/placeholder — đã rà theo VOICE | `'Gửi lời mời'` |
| `lib/features/social/social_strings.dart:171` | Nội dung/placeholder — đã rà theo VOICE | `'Mã tổ đội'` |
| `lib/features/social/social_strings.dart:172` | Nội dung/placeholder — đã rà theo VOICE | `'Mã tổ đội: $code'` |
| `lib/features/social/social_strings.dart:173` | Nội dung/placeholder — đã rà theo VOICE | `'Tạo mã'` |
| `lib/features/social/social_strings.dart:174` | Nội dung/placeholder — đã rà theo VOICE | `'Sao chép'` |
| `lib/features/social/social_strings.dart:175` | Nội dung/placeholder — đã rà theo VOICE | `'Chia sẻ'` |
| `lib/features/social/social_strings.dart:179` | Nội dung/placeholder — đã rà theo VOICE | `'Vào tổ đội VALORANT của mình bằng mã: $code'` |
| `lib/features/social/social_strings.dart:182` | Nội dung/placeholder — đã rà theo VOICE | `'Sẵn sàng $ready/$total'` |
| `lib/features/social/social_strings.dart:183` | Nội dung/placeholder — đã rà theo VOICE | `'Sẵn sàng tìm trận'` |
| `lib/features/social/social_strings.dart:184` | Nội dung/placeholder — đã rà theo VOICE | `'Tắt mã'` |
| `lib/features/social/social_strings.dart:185` | Nội dung/placeholder — đã rà theo VOICE | `'Tạo mã để bạn bè vào tổ đội nhanh bằng mã.'` |
| `lib/features/social/social_strings.dart:186` | Nội dung/placeholder — đã rà theo VOICE | `'Trưởng nhóm có thể tạo mã để mời nhanh.'` |
| `lib/features/social/social_strings.dart:187` | Nội dung/placeholder — đã rà theo VOICE | `'Vào tổ đội khác'` |
| `lib/features/social/social_strings.dart:188` | Nội dung/placeholder — đã rà theo VOICE | `'Nhập mã để tham gia'` |
| `lib/features/social/social_strings.dart:189` | Nội dung/placeholder — đã rà theo VOICE | `'Tham gia'` |
| `lib/features/social/social_strings.dart:190` | Nội dung/placeholder — đã rà theo VOICE | `'Đã tham gia tổ đội.'` |
| `lib/features/social/social_strings.dart:191` | Nội dung/placeholder — đã rà theo VOICE | `'Mã tổ đội chỉ gồm chữ cái và chữ số.'` |
| `lib/features/social/social_strings.dart:192` | Nội dung/placeholder — đã rà theo VOICE | `'Tham gia tổ đội khác?'` |
| `lib/features/social/social_strings.dart:194` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn sẽ rời tổ đội hiện tại để vào tổ đội có mã này.'` |
| `lib/features/social/social_strings.dart:196` | Nội dung/placeholder — đã rà theo VOICE | `'Mọi thay đổi chỉ được gửi tới Riot khi bạn bấm. ValVN không tự tìm '` |
| `lib/features/social/social_strings.dart:197` | Nội dung/placeholder — đã rà theo VOICE | `'trận hay khóa đặc vụ thay bạn.'` |
| `lib/features/social/social_strings.dart:199` | Nội dung/placeholder — đã rà theo VOICE | `'Lời mời'` |
| `lib/features/social/social_strings.dart:200` | Nội dung/placeholder — đã rà theo VOICE | `'Lời mời từ $name'` |
| `lib/features/social/social_strings.dart:201` | Nội dung/placeholder — đã rà theo VOICE | `'Lời mời vào tổ đội'` |
| `lib/features/social/social_strings.dart:202` | Nội dung/placeholder — đã rà theo VOICE | `'Chấp nhận'` |
| `lib/features/social/social_strings.dart:203` | Nội dung/placeholder — đã rà theo VOICE | `'Từ chối'` |
| `lib/features/social/social_strings.dart:204` | Nội dung/placeholder — đã rà theo VOICE | `'Hãy chấp nhận lời mời này trong game.'` |
| `lib/features/social/social_strings.dart:205` | Nội dung/placeholder — đã rà theo VOICE | `'Yêu cầu tham gia'` |
| `lib/features/social/social_strings.dart:206` | Nội dung/placeholder — đã rà theo VOICE | `'$name muốn vào tổ đội'` |
| `lib/features/social/social_strings.dart:208` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa khỏi tổ đội'` |
| `lib/features/social/social_strings.dart:209` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa khỏi tổ đội?'` |
| `lib/features/social/social_strings.dart:211` | Nội dung/placeholder — đã rà theo VOICE | `'$name sẽ bị xóa khỏi tổ đội của bạn.'` |
| `lib/features/social/social_strings.dart:212` | Nội dung/placeholder — đã rà theo VOICE | `'Rời tổ đội'` |
| `lib/features/social/social_strings.dart:213` | Nội dung/placeholder — đã rà theo VOICE | `'Rời tổ đội?'` |
| `lib/features/social/social_strings.dart:215` | Nội dung/placeholder — đã rà theo VOICE | `'Bạn sẽ rời tổ đội hiện tại và về tổ đội riêng.'` |
| `lib/features/social/social_strings.dart:216` | Nội dung/placeholder — đã rà theo VOICE | `'Mở tổ đội'` |
| `lib/features/social/social_strings.dart:217` | Nội dung/placeholder — đã rà theo VOICE | `'Đóng tổ đội'` |
| `lib/features/social/social_strings.dart:218` | Nội dung/placeholder — đã rà theo VOICE | `'Tùy chọn khác'` |
| `lib/features/social/social_strings.dart:221` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa hoàn tất thao tác. $message'` |
| `lib/features/social/social_strings.dart:225` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'playstation'` |
| `lib/features/social/social_strings.dart:225` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ps5'` |
| `lib/features/social/social_strings.dart:225` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ps4'` |
| `lib/features/social/social_strings.dart:225` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'ps'` |
| `lib/features/social/social_strings.dart:225` | Nội dung/placeholder — đã rà theo VOICE | `'PlayStation'` |
| `lib/features/social/social_strings.dart:226` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'xbox'` |
| `lib/features/social/social_strings.dart:226` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'xbone'` |
| `lib/features/social/social_strings.dart:226` | Khóa/mã/ký hiệu nội bộ — không phải câu hiển thị | `'xsx'` |
| `lib/features/social/social_strings.dart:226` | Nội dung/placeholder — đã rà theo VOICE | `'Xbox'` |
| `lib/features/store/store_strings.dart:3` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng'` |
| `lib/features/store/store_strings.dart:4` | Nội dung/placeholder — đã rà theo VOICE | `'Hằng ngày'` |
| `lib/features/store/store_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm'` |
| `lib/features/store/store_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Phụ kiện'` |
| `lib/features/store/store_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Bundle'` |
| `lib/features/store/store_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Chi tiết bundle'` |
| `lib/features/store/store_strings.dart:13` | Nội dung/placeholder — đã rà theo VOICE | `'Số dư: $vp VP, $kc KC, $rp RP'` |
| `lib/features/store/store_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới sau $t'` |
| `lib/features/store/store_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới lúc $time hằng ngày'` |
| `lib/features/store/store_strings.dart:21` | Nội dung/placeholder — đã rà theo VOICE | `'Tổng'` |
| `lib/features/store/store_strings.dart:22` | Nội dung/placeholder — đã rà theo VOICE | `'Hôm nay cửa hàng không có skin nào.'` |
| `lib/features/store/store_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng trống'` |
| `lib/features/store/store_strings.dart:26` | Nội dung/placeholder — đã rà theo VOICE | `'Đã sở hữu $owned/$total'` |
| `lib/features/store/store_strings.dart:29` | Nội dung/placeholder — đã rà theo VOICE | `'$n trong wishlist'` |
| `lib/features/store/store_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'Kết thúc sau $t'` |
| `lib/features/store/store_strings.dart:35` | Nội dung/placeholder — đã rà theo VOICE | `'Kết thúc lúc $wall'` |
| `lib/features/store/store_strings.dart:37` | Nội dung/placeholder — đã rà theo VOICE | `'Tiết kiệm tổng cộng $amount'` |
| `lib/features/store/store_strings.dart:39` | Nội dung/placeholder — đã rà theo VOICE | `'Ưu đãi Chợ Đêm là riêng cho tài khoản của bạn và không thể làm mới.'` |
| `lib/features/store/store_strings.dart:40` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện chưa có Chợ Đêm.'` |
| `lib/features/store/store_strings.dart:41` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm chưa mở'` |
| `lib/features/store/store_strings.dart:44` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa lật'` |
| `lib/features/store/store_strings.dart:47` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới sau $t'` |
| `lib/features/store/store_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'Làm mới lúc $wall'` |
| `lib/features/store/store_strings.dart:51` | Nội dung/placeholder — đã rà theo VOICE | `'Từ: $contract'` |
| `lib/features/store/store_strings.dart:52` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng phụ kiện hiện không có gì.'` |
| `lib/features/store/store_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có phụ kiện'` |
| `lib/features/store/store_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Còn $t'` |
| `lib/features/store/store_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Hết hạn lúc $wall'` |
| `lib/features/store/store_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện không có bundle nào đang mở bán.'` |
| `lib/features/store/store_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có bundle'` |
| `lib/features/store/store_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Bundle đã hết hạn'` |
| `lib/features/store/store_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Xem các bundle đang bán'` |
| `lib/features/store/store_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Đã sở hữu $owned/$total vật phẩm'` |
| `lib/features/store/store_strings.dart:68` | Nội dung/placeholder — đã rà theo VOICE | `'Giá bundle'` |
| `lib/features/store/store_strings.dart:69` | Nội dung/placeholder — đã rà theo VOICE | `'Mua lẻ'` |
| `lib/features/store/store_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Tiết kiệm'` |
| `lib/features/store/store_strings.dart:71` | Nội dung/placeholder — đã rà theo VOICE | `'Chỉ bán trọn bộ, không mua lẻ.'` |
| `lib/features/store/store_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy bundle này. Có thể bundle đã hết hạn.'` |
| `lib/features/store/store_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'Miễn phí'` |
| `lib/features/store/store_strings.dart:75` | Nội dung/placeholder — đã rà theo VOICE | `'Vật phẩm trong bundle'` |
| `lib/features/store/store_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'$n vật phẩm'` |
| `lib/features/store/store_strings.dart:77` | Nội dung/placeholder — đã rà theo VOICE | `'×$n'` |
| `lib/features/store/store_strings.dart:80` | Nội dung/placeholder — đã rà theo VOICE | `'Chia sẻ ảnh'` |
| `lib/features/store/store_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'Chia sẻ cửa hàng hôm nay'` |
| `lib/features/store/store_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'Chia sẻ Chợ Đêm'` |
| `lib/features/store/store_strings.dart:84` | Nội dung/placeholder — đã rà theo VOICE | `'Chia sẻ ảnh cửa hàng với bạn bè qua ứng dụng bạn chọn.'` |
| `lib/features/store/store_strings.dart:85` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện Riot ID trên ảnh'` |
| `lib/features/store/store_strings.dart:86` | Nội dung/placeholder — đã rà theo VOICE | `'Tắt sẵn để giữ riêng tư cho bạn.'` |
| `lib/features/store/store_strings.dart:87` | Nội dung/placeholder — đã rà theo VOICE | `'Hiện giá quy đổi ước tính'` |
| `lib/features/store/store_strings.dart:88` | Nội dung/placeholder — đã rà theo VOICE | `'Quy đổi theo gói VP có lợi nhất.'` |
| `lib/features/store/store_strings.dart:89` | Nội dung/placeholder — đã rà theo VOICE | `'Đang tải ảnh skin…'` |
| `lib/features/store/store_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'Chia sẻ'` |
| `lib/features/store/store_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `'Không tạo được ảnh. Hãy thử lại.'` |
| `lib/features/store/store_strings.dart:92` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng hôm nay'` |
| `lib/features/store/store_strings.dart:93` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm'` |
| `lib/features/store/store_strings.dart:94` | Nội dung/placeholder — đã rà theo VOICE | `'ValVN'` |
| `lib/features/store/store_strings.dart:95` | Nội dung/placeholder — đã rà theo VOICE | `'V'` |
| `lib/features/store/store_strings.dart:96` | Nội dung/placeholder — đã rà theo VOICE | `'VALVN'` |
| `lib/features/store/store_strings.dart:97` | Nội dung/placeholder — đã rà theo VOICE | `'Trợ thủ VALORANT của bạn'` |
| `lib/features/store/store_strings.dart:98` | Nội dung/placeholder — đã rà theo VOICE | `'Giá quy đổi chỉ là ước tính theo gói VP.'` |
| `lib/features/store/store_strings.dart:101` | Nội dung/placeholder — đã rà theo VOICE | `'Tổng $vp'` |
| `lib/features/store/store_strings.dart:104` | Nội dung/placeholder — đã rà theo VOICE | `'Tiết kiệm $vp'` |
| `lib/features/store/store_strings.dart:107` | Nội dung/placeholder — đã rà theo VOICE | `'Đến $wall'` |
| `lib/features/store/store_strings.dart:110` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng VALORANT hôm nay của mình'` |
| `lib/features/store/store_strings.dart:111` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm VALORANT của mình'` |
| `lib/features/store/store_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'valvn-store-$stamp.png'` |
| `lib/features/store/store_strings.dart:116` | Nội dung/placeholder — đã rà theo VOICE | `'valvn-night-market-$stamp.png'` |
| `lib/features/store/store_strings.dart:119` | Nội dung/placeholder — đã rà theo VOICE | `'Đã sở hữu'` |
| `lib/features/store/store_strings.dart:120` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm vào wishlist'` |
| `lib/features/store/store_strings.dart:121` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa khỏi wishlist'` |
| `lib/features/store/store_strings.dart:124` | Nội dung/placeholder — đã rà theo VOICE | `'$name, $price'` |
| `lib/features/store/store_strings.dart:127` | Nội dung/placeholder — đã rà theo VOICE | `'Cửa hàng đã làm mới'` |
| `lib/features/store/store_strings.dart:132` | Nội dung/placeholder — đã rà theo VOICE | `'Xem $skinCount skin mới hôm nay của $account.'` |
| `lib/features/store/store_strings.dart:133` | Nội dung/placeholder — đã rà theo VOICE | `'Xem skin mới hôm nay của $account.'` |
| `lib/features/wishlist/wishlist_strings.dart:5` | Nội dung/placeholder — đã rà theo VOICE | `'Wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:6` | Nội dung/placeholder — đã rà theo VOICE | `'Skin bạn đang săn'` |
| `lib/features/wishlist/wishlist_strings.dart:7` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả skin'` |
| `lib/features/wishlist/wishlist_strings.dart:8` | Nội dung/placeholder — đã rà theo VOICE | `'Chạm ♡ để thêm skin vào wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:11` | Nội dung/placeholder — đã rà theo VOICE | `'Wishlist của $riotId'` |
| `lib/features/wishlist/wishlist_strings.dart:14` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm skin'` |
| `lib/features/wishlist/wishlist_strings.dart:15` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có skin nào'` |
| `lib/features/wishlist/wishlist_strings.dart:16` | Nội dung/placeholder — đã rà theo VOICE | `'Wishlist trống. Chạm ♡ ở bất kỳ skin nào để thêm.'` |
| `lib/features/wishlist/wishlist_strings.dart:17` | Nội dung/placeholder — đã rà theo VOICE | `'Xem tất cả skin'` |
| `lib/features/wishlist/wishlist_strings.dart:18` | Nội dung/placeholder — đã rà theo VOICE | `'Tổng giá trị wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:19` | Nội dung/placeholder — đã rà theo VOICE | `'Không tính skin phần thưởng'` |
| `lib/features/wishlist/wishlist_strings.dart:20` | Nội dung/placeholder — đã rà theo VOICE | `'Có giá ước tính (≈)'` |
| `lib/features/wishlist/wishlist_strings.dart:23` | Nội dung/placeholder — đã rà theo VOICE | `'$count skin'` |
| `lib/features/wishlist/wishlist_strings.dart:27` | Nội dung/placeholder — đã rà theo VOICE | `'Đang lọc: $count skin · $value'` |
| `lib/features/wishlist/wishlist_strings.dart:31` | Nội dung/placeholder — đã rà theo VOICE | `'Một skin trong wishlist đang được bán!'` |
| `lib/features/wishlist/wishlist_strings.dart:32` | Nội dung/placeholder — đã rà theo VOICE | `'$count skin trong wishlist đang được bán!'` |
| `lib/features/wishlist/wishlist_strings.dart:33` | Nội dung/placeholder — đã rà theo VOICE | `'Chạm vào dòng được đánh dấu để xem ưu đãi.'` |
| `lib/features/wishlist/wishlist_strings.dart:35` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa khỏi wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:36` | Nội dung/placeholder — đã rà theo VOICE | `'Đã xóa $name khỏi wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:37` | Nội dung/placeholder — đã rà theo VOICE | `'Hoàn tác'` |
| `lib/features/wishlist/wishlist_strings.dart:38` | Nội dung/placeholder — đã rà theo VOICE | `'Đã sở hữu'` |
| `lib/features/wishlist/wishlist_strings.dart:41` | Nội dung/placeholder — đã rà theo VOICE | `'Kết thúc sau $time'` |
| `lib/features/wishlist/wishlist_strings.dart:42` | Nội dung/placeholder — đã rà theo VOICE | `'Xem trong cửa hàng'` |
| `lib/features/wishlist/wishlist_strings.dart:43` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa kiểm tra được cửa hàng'` |
| `lib/features/wishlist/wishlist_strings.dart:46` | Nội dung/placeholder — đã rà theo VOICE | `'Thông báo wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:48` | Nội dung/placeholder — đã rà theo VOICE | `'Cho tài khoản này, kể cả khi bạn không mở ứng dụng'` |
| `lib/features/wishlist/wishlist_strings.dart:49` | Nội dung/placeholder — đã rà theo VOICE | `'Ứng dụng chưa có quyền gửi thông báo.'` |
| `lib/features/wishlist/wishlist_strings.dart:50` | Nội dung/placeholder — đã rà theo VOICE | `'Mở cài đặt'` |
| `lib/features/wishlist/wishlist_strings.dart:53` | Nội dung/placeholder — đã rà theo VOICE | `'Tìm skin…'` |
| `lib/features/wishlist/wishlist_strings.dart:54` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa tìm kiếm'` |
| `lib/features/wishlist/wishlist_strings.dart:55` | Nội dung/placeholder — đã rà theo VOICE | `'Sắp xếp'` |
| `lib/features/wishlist/wishlist_strings.dart:56` | Nội dung/placeholder — đã rà theo VOICE | `'Sắp xếp: $sort'` |
| `lib/features/wishlist/wishlist_strings.dart:57` | Nội dung/placeholder — đã rà theo VOICE | `'Độ hiếm'` |
| `lib/features/wishlist/wishlist_strings.dart:58` | Nội dung/placeholder — đã rà theo VOICE | `'Tên'` |
| `lib/features/wishlist/wishlist_strings.dart:59` | Nội dung/placeholder — đã rà theo VOICE | `'Vũ khí'` |
| `lib/features/wishlist/wishlist_strings.dart:60` | Nội dung/placeholder — đã rà theo VOICE | `'Giá'` |
| `lib/features/wishlist/wishlist_strings.dart:61` | Nội dung/placeholder — đã rà theo VOICE | `'Phiên bản'` |
| `lib/features/wishlist/wishlist_strings.dart:62` | Nội dung/placeholder — đã rà theo VOICE | `'Vũ khí'` |
| `lib/features/wishlist/wishlist_strings.dart:63` | Nội dung/placeholder — đã rà theo VOICE | `'Tất cả vũ khí'` |
| `lib/features/wishlist/wishlist_strings.dart:64` | Nội dung/placeholder — đã rà theo VOICE | `'Chọn vũ khí'` |
| `lib/features/wishlist/wishlist_strings.dart:65` | Nội dung/placeholder — đã rà theo VOICE | `'Không tìm thấy skin'` |
| `lib/features/wishlist/wishlist_strings.dart:66` | Nội dung/placeholder — đã rà theo VOICE | `'Không có skin phù hợp. Bỏ lọc để xem thêm.'` |
| `lib/features/wishlist/wishlist_strings.dart:67` | Nội dung/placeholder — đã rà theo VOICE | `'Bỏ lọc'` |
| `lib/features/wishlist/wishlist_strings.dart:70` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa có skin'` |
| `lib/features/wishlist/wishlist_strings.dart:72` | Nội dung/placeholder — đã rà theo VOICE | `'Chưa tải được danh sách skin. Hãy làm mới để thử lại.'` |
| `lib/features/wishlist/wishlist_strings.dart:73` | Nội dung/placeholder — đã rà theo VOICE | `'$count skin'` |
| `lib/features/wishlist/wishlist_strings.dart:74` | Nội dung/placeholder — đã rà theo VOICE | `'$count trong wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:75` | Nội dung/placeholder — đã rà theo VOICE | `'Thêm vào wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:76` | Nội dung/placeholder — đã rà theo VOICE | `'Xóa khỏi wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:77` | Nội dung/placeholder — đã rà theo VOICE | `'Đã có trong wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'$name, $price, $inWishlistLabel'` |
| `lib/features/wishlist/wishlist_strings.dart:81` | Nội dung/placeholder — đã rà theo VOICE | `'$name, $price'` |
| `lib/features/wishlist/wishlist_strings.dart:82` | Nội dung/placeholder — đã rà theo VOICE | `'đã có trong wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:85` | Nội dung/placeholder — đã rà theo VOICE | `'Skin trong wishlist đã xuất hiện!'` |
| `lib/features/wishlist/wishlist_strings.dart:90` | Nội dung/placeholder — đã rà theo VOICE | `'$skin đang có trong cửa hàng của $account.'` |
| `lib/features/wishlist/wishlist_strings.dart:91` | Nội dung/placeholder — đã rà theo VOICE | `'$skin đang có trong cửa hàng của $account — còn $left.'` |
| `lib/features/wishlist/wishlist_strings.dart:93` | Nội dung/placeholder — đã rà theo VOICE | `'Chợ Đêm có skin bạn thích!'` |
| `lib/features/wishlist/wishlist_strings.dart:103` | Nội dung/placeholder — đã rà theo VOICE | `'$skin giảm $percent% còn $price ($account).'` |
| `lib/features/wishlist/wishlist_strings.dart:105` | Nội dung/placeholder — đã rà theo VOICE | `'$skin chỉ còn $price ($account).'` |
| `lib/features/wishlist/wishlist_strings.dart:106` | Nội dung/placeholder — đã rà theo VOICE | `'$skin đang có trong Chợ Đêm của $account.'` |
| `lib/features/wishlist/wishlist_strings.dart:109` | Nội dung/placeholder — đã rà theo VOICE | `'Bundle mới có skin trong wishlist'` |
| `lib/features/wishlist/wishlist_strings.dart:114` | Nội dung/placeholder — đã rà theo VOICE | `'$skin nằm trong một bundle đang bán ($account).'` |
| `lib/features/wishlist/wishlist_strings.dart:115` | Nội dung/placeholder — đã rà theo VOICE | `'$skin nằm trong bundle $bundle ($account).'` |
| `lib/features/wishlist/wishlist_strings.dart:119` | Nội dung/placeholder — đã rà theo VOICE | `'$count skin trong wishlist đang được bán!'` |
| `lib/features/wishlist/wishlist_strings.dart:122` | Nội dung/placeholder — đã rà theo VOICE | `', '` |
| `lib/features/wishlist/wishlist_strings.dart:124` | Nội dung/placeholder — đã rà theo VOICE | `'$list và $more skin khác đang có trong cửa hàng của $account.'` |
| `lib/features/wishlist/wishlist_strings.dart:125` | Nội dung/placeholder — đã rà theo VOICE | `'$list đang có trong cửa hàng của $account.'` |
| `lib/features/settings/legal/community_guidelines.dart:1` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_document.dart'` |
| `lib/features/settings/legal/community_guidelines.dart:2` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_info.dart'` |
| `lib/features/settings/legal/community_guidelines.dart:8` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'community'` |
| `lib/features/settings/legal/community_guidelines.dart:9` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tiêu chuẩn cộng đồng'` |
| `lib/features/settings/legal/community_guidelines.dart:10` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quy tắc khi đăng bài, bình luận và tìm đồng đội'` |
| `lib/features/settings/legal/community_guidelines.dart:11` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'1.0'` |
| `lib/features/settings/legal/community_guidelines.dart:14` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cộng đồng ValVN là nơi người chơi VALORANT khoe cửa hàng, bàn chuyện '` |
| `lib/features/settings/legal/community_guidelines.dart:15` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'skin, tìm đồng đội và giúp nhau leo rank. Để nơi này luôn vui và an '` |
| `lib/features/settings/legal/community_guidelines.dart:16` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'toàn, hãy cùng nhau giữ những quy tắc dưới đây. Tiêu chuẩn này là một '` |
| `lib/features/settings/legal/community_guidelines.dart:17` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phần của Điều khoản sử dụng.'` |
| `lib/features/settings/legal/community_guidelines.dart:21` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tôn trọng mọi người'` |
| `lib/features/settings/legal/community_guidelines.dart:24` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tranh luận về lối chơi, meta hay skin thoải mái, nhưng hãy nhắm vào '` |
| `lib/features/settings/legal/community_guidelines.dart:25` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ý kiến chứ không nhắm vào con người.'` |
| `lib/features/settings/legal/community_guidelines.dart:28` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không xúc phạm, chửi bới, quấy rối, đe dọa, bắt nạt hay kích động '` |
| `lib/features/settings/legal/community_guidelines.dart:29` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'người khác quấy rối một ai đó.'` |
| `lib/features/settings/legal/community_guidelines.dart:32` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không phân biệt đối xử hay thù ghét dựa trên dân tộc, vùng miền, '` |
| `lib/features/settings/legal/community_guidelines.dart:33` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'giới tính, tôn giáo, khuyết tật, xu hướng tính dục hay bất kỳ đặc '` |
| `lib/features/settings/legal/community_guidelines.dart:34` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'điểm cá nhân nào.'` |
| `lib/features/settings/legal/community_guidelines.dart:37` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không mạo danh người khác, streamer, tuyển thủ hay Riot Games.'` |
| `lib/features/settings/legal/community_guidelines.dart:41` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nội dung không được phép'` |
| `lib/features/settings/legal/community_guidelines.dart:44` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nội dung vi phạm pháp luật áp dụng (pháp luật Việt Nam và pháp luật '` |
| `lib/features/settings/legal/community_guidelines.dart:45` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nơi bạn sống), kích động bạo lực hay thù ghét, gây phương hại đến '` |
| `lib/features/settings/legal/community_guidelines.dart:46` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'an toàn của người khác hoặc trật tự an toàn xã hội.'` |
| `lib/features/settings/legal/community_guidelines.dart:49` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nội dung khiêu dâm, gợi dục, đặc biệt là liên quan đến trẻ em.'` |
| `lib/features/settings/legal/community_guidelines.dart:52` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Hình ảnh bạo lực, máu me gây sốc, tự hại hoặc cổ vũ hành vi nguy hiểm.'` |
| `lib/features/settings/legal/community_guidelines.dart:55` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thông tin sai sự thật có chủ đích, tin giả, lừa đảo, mạo danh sự '` |
| `lib/features/settings/legal/community_guidelines.dart:56` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'kiện tặng quà hay "hack VP miễn phí".'` |
| `lib/features/settings/legal/community_guidelines.dart:59` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nội dung vi phạm bản quyền hoặc quyền sở hữu trí tuệ của người khác.'` |
| `lib/features/settings/legal/community_guidelines.dart:63` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Gian lận, mua bán và quảng cáo'` |
| `lib/features/settings/legal/community_guidelines.dart:66` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không quảng bá, chia sẻ hay hỏi mua phần mềm gian lận, hack, macro, '` |
| `lib/features/settings/legal/community_guidelines.dart:67` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'công cụ can thiệp trò chơi.'` |
| `lib/features/settings/legal/community_guidelines.dart:70` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không mua bán, cho thuê, trao đổi tài khoản; không quảng cáo dịch vụ '` |
| `lib/features/settings/legal/community_guidelines.dart:71` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cày thuê (boosting), bán VP hay vật phẩm trái phép.'` |
| `lib/features/settings/legal/community_guidelines.dart:74` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không spam, đăng lặp lại, quảng cáo hay dẫn liên kết tới trang web, '` |
| `lib/features/settings/legal/community_guidelines.dart:75` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhóm hoặc dịch vụ thương mại khi chưa được phép.'` |
| `lib/features/settings/legal/community_guidelines.dart:79` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bảo vệ thông tin cá nhân'` |
| `lib/features/settings/legal/community_guidelines.dart:82` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không đăng thông tin cá nhân của người khác (tên thật, số điện '` |
| `lib/features/settings/legal/community_guidelines.dart:83` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thoại, địa chỉ, ảnh riêng tư…) khi chưa có sự đồng ý của họ.'` |
| `lib/features/settings/legal/community_guidelines.dart:86` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không bao giờ chia sẻ mật khẩu, mã xác thực hay email đăng nhập Riot '` |
| `lib/features/settings/legal/community_guidelines.dart:87` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của bạn. ValVN và đội ngũ kiểm duyệt không bao giờ hỏi những thông '` |
| `lib/features/settings/legal/community_guidelines.dart:88` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tin này.'` |
| `lib/features/settings/legal/community_guidelines.dart:91` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cẩn thận khi chụp màn hình: hãy che thông tin bạn không muốn công khai.'` |
| `lib/features/settings/legal/community_guidelines.dart:95` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tìm đồng đội'` |
| `lib/features/settings/legal/community_guidelines.dart:98` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chỉ đăng khi bạn thực sự đang tìm người, với đúng khu vực, chế độ '` |
| `lib/features/settings/legal/community_guidelines.dart:99` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chơi và số chỗ trống.'` |
| `lib/features/settings/legal/community_guidelines.dart:102` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mã tổ đội trong bài hiển thị với mọi người xem bài. Bài tự hết hạn '` |
| `lib/features/settings/legal/community_guidelines.dart:103` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'sau 30 phút; hãy xóa bài hoặc tắt mã trong trò chơi khi đã đủ người.'` |
| `lib/features/settings/legal/community_guidelines.dart:106` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không dùng bài tìm đồng đội để spam, quảng cáo hay dẫn dụ người khác '` |
| `lib/features/settings/legal/community_guidelines.dart:107` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'vào tổ đội nhằm quấy rối, phá game.'` |
| `lib/features/settings/legal/community_guidelines.dart:110` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Khi vào trận, hãy cư xử như một đồng đội tốt: không cố tình phá '` |
| `lib/features/settings/legal/community_guidelines.dart:111` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trận, không bỏ mặc đồng đội (AFK), không chửi bới hay công kích ai.'` |
| `lib/features/settings/legal/community_guidelines.dart:115` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Hình ảnh và bình chọn'` |
| `lib/features/settings/legal/community_guidelines.dart:118` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chỉ đăng hình ảnh bạn có quyền sử dụng và phù hợp với tiêu chuẩn này; '` |
| `lib/features/settings/legal/community_guidelines.dart:119` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ảnh chụp cửa hàng, bộ sưu tập, khoảnh khắc trong trận đều được chào '` |
| `lib/features/settings/legal/community_guidelines.dart:120` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đón.'` |
| `lib/features/settings/legal/community_guidelines.dart:123` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mỗi tài khoản chỉ có một phiếu cho mỗi skin. Không dùng nhiều tài '` |
| `lib/features/settings/legal/community_guidelines.dart:124` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khoản hay công cụ tự động để thao túng bảng xếp hạng.'` |
| `lib/features/settings/legal/community_guidelines.dart:128` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Báo cáo vi phạm'` |
| `lib/features/settings/legal/community_guidelines.dart:130` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thấy nội dung vi phạm? Hãy dùng nút Báo cáo trên bài đăng, bình luận '` |
| `lib/features/settings/legal/community_guidelines.dart:131` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hoặc bài tìm đồng đội và chọn lý do phù hợp. Báo cáo được giữ kín, '` |
| `lib/features/settings/legal/community_guidelines.dart:132` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'người bị báo cáo không biết ai đã báo cáo.'` |
| `lib/features/settings/legal/community_guidelines.dart:136` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nội dung nhận đủ báo cáo từ nhiều người dùng khác nhau sẽ được tự '` |
| `lib/features/settings/legal/community_guidelines.dart:137` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'động ẩn trong khi chờ xem xét.'` |
| `lib/features/settings/legal/community_guidelines.dart:140` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Với trường hợp khẩn cấp hoặc nghiêm trọng (đe dọa, nội dung liên '` |
| `lib/features/settings/legal/community_guidelines.dart:141` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quan đến trẻ em, lộ thông tin cá nhân), hãy báo cáo và gửi thêm '` |
| `lib/features/settings/legal/community_guidelines.dart:142` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'email tới $_email.'` |
| `lib/features/settings/legal/community_guidelines.dart:145` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không lạm dụng tính năng báo cáo để tấn công người khác; báo cáo sai '` |
| `lib/features/settings/legal/community_guidelines.dart:146` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'sự thật lặp lại cũng là vi phạm.'` |
| `lib/features/settings/legal/community_guidelines.dart:150` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Hậu quả khi vi phạm'` |
| `lib/features/settings/legal/community_guidelines.dart:152` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tùy mức độ và tần suất, chúng tôi có thể áp dụng một hoặc nhiều biện '` |
| `lib/features/settings/legal/community_guidelines.dart:153` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'pháp sau, có hoặc không cần báo trước:'` |
| `lib/features/settings/legal/community_guidelines.dart:156` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ẩn hoặc gỡ bỏ nội dung vi phạm.'` |
| `lib/features/settings/legal/community_guidelines.dart:158` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tạm thời hạn chế quyền đăng bài, bình luận, tìm đồng đội hoặc bình chọn.'` |
| `lib/features/settings/legal/community_guidelines.dart:160` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Khóa vĩnh viễn quyền sử dụng Cộng đồng.'` |
| `lib/features/settings/legal/community_guidelines.dart:162` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cung cấp thông tin cho cơ quan có thẩm quyền đối với hành vi vi phạm '` |
| `lib/features/settings/legal/community_guidelines.dart:163` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'pháp luật.'` |
| `lib/features/settings/legal/community_guidelines.dart:167` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Các biện pháp này chỉ áp dụng trong ValVN và không ảnh hưởng tới Tài '` |
| `lib/features/settings/legal/community_guidelines.dart:168` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khoản Riot của bạn. Tuy nhiên, hành vi vi phạm trong trò chơi vẫn có '` |
| `lib/features/settings/legal/community_guidelines.dart:169` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thể bị Riot Games xử lý theo chính sách của họ.'` |
| `lib/features/settings/legal/community_guidelines.dart:172` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Khiếu nại quyết định kiểm duyệt'` |
| `lib/features/settings/legal/community_guidelines.dart:174` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nếu bạn cho rằng nội dung của mình bị gỡ nhầm hoặc biện pháp áp dụng '` |
| `lib/features/settings/legal/community_guidelines.dart:175` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chưa hợp lý, hãy gửi email tới $_email kèm Riot ID và mô tả ngắn. '` |
| `lib/features/settings/legal/community_guidelines.dart:176` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi sẽ xem xét lại và phản hồi sớm nhất có thể.'` |
| `lib/features/settings/legal/legal_document.dart:7` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_info.dart'` |
| `lib/features/settings/legal/legal_document.dart:93` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'${index + 1}. ${section.heading}'` |
| `lib/features/settings/legal/legal_document.dart:97` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phiên bản ${doc.version} · Hiệu lực từ: ${doc.effectiveDate}'` |
| `lib/features/settings/legal/legal_document.dart:104` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'<!-- Tệp tạo tự động từ lib/features/settings/legal/. Không sửa tay: '` |
| `lib/features/settings/legal/legal_document.dart:105` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'sửa nội dung Dart rồi chạy \`dart run tool/export_legal_docs.dart\`. -->'` |
| `lib/features/settings/legal/legal_document.dart:108` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'# ${doc.title}'` |
| `lib/features/settings/legal/legal_document.dart:110` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'**${LegalInfo.productName}** · ${legalMetaLine(doc)}'` |
| `lib/features/settings/legal/legal_document.dart:121` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'### $text'` |
| `lib/features/settings/legal/legal_document.dart:125` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'> $text'` |
| `lib/features/settings/legal/legal_document.dart:131` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'- ${item.text}'` |
| `lib/features/settings/legal/legal_document.dart:132` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'- **${item.lead}** ${item.text}'` |
| `lib/features/settings/legal/legal_document.dart:143` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'## ${numberedHeading(i, doc.sections[i])}'` |
| `lib/features/settings/legal/legal_document.dart:148` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'---'` |
| `lib/features/settings/legal/legal_documents.dart:1` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'community_guidelines.dart'` |
| `lib/features/settings/legal/legal_documents.dart:2` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_document.dart'` |
| `lib/features/settings/legal/legal_documents.dart:3` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_notice.dart'` |
| `lib/features/settings/legal/legal_documents.dart:4` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'privacy_policy.dart'` |
| `lib/features/settings/legal/legal_documents.dart:5` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'terms_of_service.dart'` |
| `lib/features/settings/legal/legal_documents.dart:7` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_document.dart'` |
| `lib/features/settings/legal/legal_documents.dart:8` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_info.dart'` |
| `lib/features/settings/legal/legal_documents.dart:25` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'docs/legal/${doc.id}.md'` |
| `lib/features/settings/legal/legal_info.dart:9` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nguyễn Đức Huy'` |
| `lib/features/settings/legal/legal_info.dart:12` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ndh0408@gmail.com'` |
| `lib/features/settings/legal/legal_info.dart:15` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'2026'` |
| `lib/features/settings/legal/legal_info.dart:18` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'29/09/2026'` |
| `lib/features/settings/legal/legal_info.dart:21` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN'` |
| `lib/features/settings/legal/legal_info.dart:25` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'© $copyrightYear $publisherName. Bảo lưu mọi quyền.'` |
| `lib/features/settings/legal/legal_info.dart:29` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'['` |
| `lib/features/settings/legal/legal_info.dart:29` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'@'` |
| `lib/features/settings/legal/legal_info.dart:33` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mailto'` |
| `lib/features/settings/legal/legal_notice.dart:1` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'../../../core/l10n/common_strings.dart'` |
| `lib/features/settings/legal/legal_notice.dart:2` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_document.dart'` |
| `lib/features/settings/legal/legal_notice.dart:3` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_info.dart'` |
| `lib/features/settings/legal/legal_notice.dart:10` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'notice'` |
| `lib/features/settings/legal/legal_notice.dart:11` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thông báo pháp lý'` |
| `lib/features/settings/legal/legal_notice.dart:12` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tuyên bố miễn trừ Riot Games, nhãn hiệu và ghi công'` |
| `lib/features/settings/legal/legal_notice.dart:13` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'1.0'` |
| `lib/features/settings/legal/legal_notice.dart:16` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tuyên bố miễn trừ Riot Games'` |
| `lib/features/settings/legal/legal_notice.dart:18` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN được làm theo chính sách "Legal Jibber Jabber" của Riot Games '` |
| `lib/features/settings/legal/legal_notice.dart:19` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và có dùng tài sản thuộc sở hữu của Riot Games. Riot Games không xác '` |
| `lib/features/settings/legal/legal_notice.dart:20` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhận hay tài trợ cho dự án này.'` |
| `lib/features/settings/legal/legal_notice.dart:23` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN là ứng dụng độc lập, không phải sản phẩm chính thức của Riot '` |
| `lib/features/settings/legal/legal_notice.dart:24` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Games và không liên kết với Riot Games dưới bất kỳ hình thức nào. Mọi '` |
| `lib/features/settings/legal/legal_notice.dart:25` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hỗ trợ về ValVN do chúng tôi cung cấp, không phải Riot Games.'` |
| `lib/features/settings/legal/legal_notice.dart:28` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nhãn hiệu'` |
| `lib/features/settings/legal/legal_notice.dart:30` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot Games, VALORANT và mọi tài sản liên quan là thương hiệu hoặc '` |
| `lib/features/settings/legal/legal_notice.dart:31` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thương hiệu đã đăng ký của Riot Games, Inc. Các tên, logo và nhãn hiệu '` |
| `lib/features/settings/legal/legal_notice.dart:32` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khác được nhắc đến trong Ứng dụng thuộc về chủ sở hữu của chúng và chỉ '` |
| `lib/features/settings/legal/legal_notice.dart:33` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'được dùng để nhận diện.'` |
| `lib/features/settings/legal/legal_notice.dart:36` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nội dung trò chơi'` |
| `lib/features/settings/legal/legal_notice.dart:38` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tên, hình ảnh, video và thông tin về skin, đặc vụ, bản đồ, rank, thẻ '` |
| `lib/features/settings/legal/legal_notice.dart:39` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'người chơi và các nội dung khác của VALORANT thuộc quyền sở hữu của '` |
| `lib/features/settings/legal/legal_notice.dart:40` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot Games, Inc. Dữ liệu tài khoản của bạn (cửa hàng, ví, bộ sưu tập, '` |
| `lib/features/settings/legal/legal_notice.dart:41` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trận đấu, xếp hạng) được lấy trực tiếp từ máy chủ của Riot Games.'` |
| `lib/features/settings/legal/legal_notice.dart:44` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nguồn dữ liệu và ghi công'` |
| `lib/features/settings/legal/legal_notice.dart:47` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dữ liệu và hình ảnh công khai về vật phẩm, đặc vụ, bản đồ và rank. '` |
| `lib/features/settings/legal/legal_notice.dart:48` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'valorant-api.com là dự án cộng đồng độc lập, không liên kết với '` |
| `lib/features/settings/legal/legal_notice.dart:49` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN hay Riot Games.'` |
| `lib/features/settings/legal/legal_notice.dart:50` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'valorant-api.com:'` |
| `lib/features/settings/legal/legal_notice.dart:53` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tài liệu kỹ thuật do cộng đồng nhà phát triển VALORANT biên soạn.'` |
| `lib/features/settings/legal/legal_notice.dart:54` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'techchrism/valorant-api-docs:'` |
| `lib/features/settings/legal/legal_notice.dart:57` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN được xây dựng bằng Flutter cùng nhiều phần mềm mã nguồn mở '` |
| `lib/features/settings/legal/legal_notice.dart:58` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khác. Danh sách và giấy phép của từng phần mềm có ở mục "Phần mềm '` |
| `lib/features/settings/legal/legal_notice.dart:59` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bên thứ ba" trong trang Giới thiệu & pháp lý.'` |
| `lib/features/settings/legal/legal_notice.dart:60` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phần mềm mã nguồn mở:'` |
| `lib/features/settings/legal/legal_notice.dart:64` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bản quyền ValVN'` |
| `lib/features/settings/legal/legal_notice.dart:66` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'${LegalInfo.copyrightNotice} ValVN là phần mềm độc quyền; việc sử dụng '` |
| `lib/features/settings/legal/legal_notice.dart:67` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tuân theo Điều khoản sử dụng.'` |
| `lib/features/settings/legal/legal_notice.dart:70` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Báo cáo vi phạm quyền sở hữu trí tuệ'` |
| `lib/features/settings/legal/legal_notice.dart:72` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nếu bạn cho rằng nội dung trong ValVN, kể cả nội dung do người dùng '` |
| `lib/features/settings/legal/legal_notice.dart:73` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đăng trong Cộng đồng, vi phạm quyền sở hữu trí tuệ của bạn, hãy gửi '` |
| `lib/features/settings/legal/legal_notice.dart:74` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'email tới $_email. Vui lòng nêu rõ: thông tin liên hệ của bạn, tác '` |
| `lib/features/settings/legal/legal_notice.dart:75` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phẩm nào của bạn được bảo hộ, nội dung vi phạm nằm ở đâu trong Ứng '` |
| `lib/features/settings/legal/legal_notice.dart:76` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dụng, và cam kết rằng thông tin bạn cung cấp là chính xác. Chúng tôi '` |
| `lib/features/settings/legal/legal_notice.dart:77` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'sẽ xem xét và xử lý kịp thời.'` |
| `lib/features/settings/legal/privacy_policy.dart:1` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_document.dart'` |
| `lib/features/settings/legal/privacy_policy.dart:2` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_info.dart'` |
| `lib/features/settings/legal/privacy_policy.dart:26` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'privacy'` |
| `lib/features/settings/legal/privacy_policy.dart:27` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chính sách quyền riêng tư'` |
| `lib/features/settings/legal/privacy_policy.dart:28` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dữ liệu nào được xử lý, ở đâu và quyền của bạn'` |
| `lib/features/settings/legal/privacy_policy.dart:29` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'1.0'` |
| `lib/features/settings/legal/privacy_policy.dart:32` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chính sách này giải thích cách ValVN thu thập, sử dụng, lưu trữ và bảo '` |
| `lib/features/settings/legal/privacy_policy.dart:33` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'vệ dữ liệu cá nhân của bạn, cũng như các quyền của bạn đối với dữ liệu '` |
| `lib/features/settings/legal/privacy_policy.dart:34` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đó. Chính sách được xây dựng theo pháp luật Việt Nam về bảo vệ dữ liệu '` |
| `lib/features/settings/legal/privacy_policy.dart:35` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cá nhân (Nghị định 13/2023/NĐ-CP), đồng thời tính đến các quy định bạn '` |
| `lib/features/settings/legal/privacy_policy.dart:36` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'có thể được hưởng ở nơi bạn sống, như GDPR, UK GDPR, CCPA/CPRA hay LGPD '` |
| `lib/features/settings/legal/privacy_policy.dart:37` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'(xem mục "Quyền của bạn theo luật nơi bạn sống"). ValVN dành cho người '` |
| `lib/features/settings/legal/privacy_policy.dart:38` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chơi VALORANT ở mọi quốc gia.'` |
| `lib/features/settings/legal/privacy_policy.dart:41` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tóm tắt: Phần lớn dữ liệu của bạn chỉ nằm trên thiết bị. Dữ liệu đăng '` |
| `lib/features/settings/legal/privacy_policy.dart:42` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhập Riot của bạn được lưu trong vùng lưu trữ bảo mật của hệ điều hành '` |
| `lib/features/settings/legal/privacy_policy.dart:43` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và không gửi cho chúng tôi, trừ một trường hợp duy nhất: khi bạn lần '` |
| `lib/features/settings/legal/privacy_policy.dart:44` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đầu mở Cộng đồng và xác nhận đồng ý trong hộp thoại hiện ra một lần, '` |
| `lib/features/settings/legal/privacy_policy.dart:45` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mã truy cập Riot (access token) được gửi tới máy chủ ValVN để xác minh '` |
| `lib/features/settings/legal/privacy_policy.dart:46` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot ID, rồi bị hủy ngay. Máy chủ không lưu PUUID (mã định danh người '` |
| `lib/features/settings/legal/privacy_policy.dart:47` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chơi của bạn). ValVN không có quảng cáo, không dùng công cụ phân tích '` |
| `lib/features/settings/legal/privacy_policy.dart:48` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hay theo dõi và không bán dữ liệu của bạn.'` |
| `lib/features/settings/legal/privacy_policy.dart:52` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bên kiểm soát và xử lý dữ liệu'` |
| `lib/features/settings/legal/privacy_policy.dart:54` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'$_publisher ("chúng tôi") là bên quyết định mục đích và phương tiện '` |
| `lib/features/settings/legal/privacy_policy.dart:55` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'xử lý dữ liệu cá nhân trong ValVN (bên kiểm soát và xử lý dữ liệu cá '` |
| `lib/features/settings/legal/privacy_policy.dart:56` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhân). Thông tin liên hệ có ở mục cuối của Chính sách này.'` |
| `lib/features/settings/legal/privacy_policy.dart:59` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phạm vi áp dụng'` |
| `lib/features/settings/legal/privacy_policy.dart:61` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chính sách áp dụng cho ứng dụng ValVN trên iOS và Android ở mọi quốc '` |
| `lib/features/settings/legal/privacy_policy.dart:62` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'gia, bao gồm các tính năng Cộng đồng. Chính sách không áp dụng cho '` |
| `lib/features/settings/legal/privacy_policy.dart:63` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dịch vụ của Riot Games, valorant-api.com, Apple, Google hay các bên '` |
| `lib/features/settings/legal/privacy_policy.dart:64` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thứ ba khác. Mỗi bên xử lý dữ liệu theo chính sách riêng của họ.'` |
| `lib/features/settings/legal/privacy_policy.dart:67` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dữ liệu được xử lý trên thiết bị của bạn'` |
| `lib/features/settings/legal/privacy_policy.dart:69` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Các dữ liệu dưới đây được tạo ra hoặc tải về khi bạn dùng ứng dụng, '` |
| `lib/features/settings/legal/privacy_policy.dart:70` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và chỉ được lưu trên thiết bị của bạn. Chúng tôi không nhận được các '` |
| `lib/features/settings/legal/privacy_policy.dart:71` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dữ liệu này.'` |
| `lib/features/settings/legal/privacy_policy.dart:75` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dữ liệu do Riot cấp cho ứng dụng sau khi bạn đăng nhập trên trang '` |
| `lib/features/settings/legal/privacy_policy.dart:76` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chính thức của Riot, gồm mã truy cập (access token), mã quyền sở '` |
| `lib/features/settings/legal/privacy_policy.dart:77` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hữu (entitlement token) và cookie đăng nhập (tệp giúp Riot nhớ '` |
| `lib/features/settings/legal/privacy_policy.dart:78` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'rằng bạn đã đăng nhập). Chúng được lưu trong Keychain (iOS) hoặc '` |
| `lib/features/settings/legal/privacy_policy.dart:79` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'vùng lưu trữ mã hóa do Keystore bảo vệ (Android). ValVN không bao '` |
| `lib/features/settings/legal/privacy_policy.dart:80` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'giờ thấy mật khẩu bạn nhập vào trang của Riot.'` |
| `lib/features/settings/legal/privacy_policy.dart:81` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dữ liệu đăng nhập Riot:'` |
| `lib/features/settings/legal/privacy_policy.dart:84` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nếu bạn tự chọn lưu tên đăng nhập và mật khẩu Riot để đăng nhập lại '` |
| `lib/features/settings/legal/privacy_policy.dart:85` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhanh hơn, thông tin này chỉ nằm trong vùng lưu trữ bảo mật trên '` |
| `lib/features/settings/legal/privacy_policy.dart:86` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thiết bị. Nó không bao giờ bị ghi vào báo lỗi hay gửi đi đâu, trừ '` |
| `lib/features/settings/legal/privacy_policy.dart:87` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'việc được điền vào trang đăng nhập chính thức của Riot khi bạn yêu '` |
| `lib/features/settings/legal/privacy_policy.dart:88` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cầu.'` |
| `lib/features/settings/legal/privacy_policy.dart:89` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thông tin đăng nhập đã lưu (tùy chọn):'` |
| `lib/features/settings/legal/privacy_policy.dart:92` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot ID (tên#tag), mã định danh người chơi (PUUID), khu vực, nền '` |
| `lib/features/settings/legal/privacy_policy.dart:93` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tảng, thẻ người chơi, cấp độ và rank của các tài khoản bạn thêm '` |
| `lib/features/settings/legal/privacy_policy.dart:94` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'vào. Ứng dụng dùng chúng để hiển thị danh sách và chuyển đổi giữa '` |
| `lib/features/settings/legal/privacy_policy.dart:95` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'các tài khoản.'` |
| `lib/features/settings/legal/privacy_policy.dart:96` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Danh sách tài khoản:'` |
| `lib/features/settings/legal/privacy_policy.dart:99` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cửa hàng, ví, bộ sưu tập, trang bị, Battle Pass, hợp đồng, lịch sử '` |
| `lib/features/settings/legal/privacy_policy.dart:100` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đấu, rank, trận hiện tại, danh sách bạn bè, trạng thái trực tuyến '` |
| `lib/features/settings/legal/privacy_policy.dart:101` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và tin nhắn trò chuyện. Ứng dụng đọc trực tiếp từ máy chủ của Riot '` |
| `lib/features/settings/legal/privacy_policy.dart:102` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bằng đăng nhập Riot của bạn và có thể lưu bản sao tạm để bạn xem '` |
| `lib/features/settings/legal/privacy_policy.dart:103` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khi không có mạng.'` |
| `lib/features/settings/legal/privacy_policy.dart:104` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dữ liệu trò chơi:'` |
| `lib/features/settings/legal/privacy_policy.dart:107` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'wishlist, tùy chọn giao diện, cài đặt thông báo và nền tảng.'` |
| `lib/features/settings/legal/privacy_policy.dart:108` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Wishlist và cài đặt:'` |
| `lib/features/settings/legal/privacy_policy.dart:111` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tên và hình ảnh vật phẩm, đặc vụ, bản đồ lấy từ valorant-api.com, '` |
| `lib/features/settings/legal/privacy_policy.dart:112` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cùng các ảnh đã tải, được lưu tạm để ứng dụng chạy nhanh hơn.'` |
| `lib/features/settings/legal/privacy_policy.dart:113` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dữ liệu tạm:'` |
| `lib/features/settings/legal/privacy_policy.dart:116` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bản ghi kỹ thuật trên thiết bị về những gì ứng dụng đã làm (tên các '` |
| `lib/features/settings/legal/privacy_policy.dart:117` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'yêu cầu gửi đi, kết quả và thời gian), dùng để tìm lỗi. Bản ghi '` |
| `lib/features/settings/legal/privacy_policy.dart:118` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'được lọc để không chứa mật khẩu, dữ liệu đăng nhập Riot hay ID tài '` |
| `lib/features/settings/legal/privacy_policy.dart:119` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khoản, và chỉ rời khỏi thiết bị khi bạn tự chọn "Gửi báo lỗi cho '` |
| `lib/features/settings/legal/privacy_policy.dart:120` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN" trong Cài đặt > Nâng cao.'` |
| `lib/features/settings/legal/privacy_policy.dart:121` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Báo lỗi:'` |
| `lib/features/settings/legal/privacy_policy.dart:125` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dữ liệu được xử lý trên máy chủ Cộng đồng'` |
| `lib/features/settings/legal/privacy_policy.dart:127` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Máy chủ Cộng đồng là máy chủ do nhà phát hành tự vận hành. Dữ liệu '` |
| `lib/features/settings/legal/privacy_policy.dart:128` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'được lưu trong cơ sở dữ liệu và các tệp trên ổ đĩa của máy chủ đó. '` |
| `lib/features/settings/legal/privacy_policy.dart:129` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Kết nối từ Ứng dụng tới máy chủ này đi qua mạng của Cloudflare; '` |
| `lib/features/settings/legal/privacy_policy.dart:130` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cloudflare chỉ chuyển tiếp kết nối. Chỉ khi bạn dùng tính năng Cộng '` |
| `lib/features/settings/legal/privacy_policy.dart:131` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đồng, các dữ liệu dưới đây mới được gửi tới và lưu trên máy chủ này:'` |
| `lib/features/settings/legal/privacy_policy.dart:135` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot ID (tên và tag), khu vực, thẻ người chơi, rank và ngôn ngữ '` |
| `lib/features/settings/legal/privacy_policy.dart:136` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ứng dụng, do Ứng dụng gửi lên. Đây là thông tin công khai với '` |
| `lib/features/settings/legal/privacy_policy.dart:137` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'người dùng khác trong Cộng đồng.'` |
| `lib/features/settings/legal/privacy_policy.dart:138` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Hồ sơ Cộng đồng:'` |
| `lib/features/settings/legal/privacy_policy.dart:141` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quốc gia của Tài khoản Riot của bạn (do Riot cung cấp khi xác '` |
| `lib/features/settings/legal/privacy_policy.dart:142` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'minh, bạn không thể chỉnh sửa), dùng để hiển thị Cộng đồng theo '` |
| `lib/features/settings/legal/privacy_policy.dart:143` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quốc gia.'` |
| `lib/features/settings/legal/privacy_policy.dart:144` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quốc gia:'` |
| `lib/features/settings/legal/privacy_policy.dart:147` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'một mã băm một chiều (không thể suy ngược ra PUUID) được tạo từ '` |
| `lib/features/settings/legal/privacy_policy.dart:148` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'PUUID của bạn. Máy chủ không lưu và không trả về PUUID của bạn.'` |
| `lib/features/settings/legal/privacy_policy.dart:149` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mã người dùng:'` |
| `lib/features/settings/legal/privacy_policy.dart:152` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nội dung bài viết, hình ảnh bạn tải lên, thông tin cửa hàng hoặc '` |
| `lib/features/settings/legal/privacy_policy.dart:153` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chợ Đêm mà bạn chọn chia sẻ, bình luận, lượt thích và thời điểm '` |
| `lib/features/settings/legal/privacy_policy.dart:154` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đăng.'` |
| `lib/features/settings/legal/privacy_policy.dart:155` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bài đăng và bình luận:'` |
| `lib/features/settings/legal/privacy_policy.dart:158` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'số sao, nội dung nhận xét và lượt "hữu ích" bạn dành cho đánh giá '` |
| `lib/features/settings/legal/privacy_policy.dart:159` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của người khác. Những thông tin này hiển thị công khai cùng Riot '` |
| `lib/features/settings/legal/privacy_policy.dart:160` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ID của bạn.'` |
| `lib/features/settings/legal/privacy_policy.dart:161` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Đánh giá skin:'` |
| `lib/features/settings/legal/privacy_policy.dart:164` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mã tổ đội, chế độ chơi, khu vực, giới hạn rank, vai trò cần tìm, có '` |
| `lib/features/settings/legal/privacy_policy.dart:165` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'yêu cầu micro hay không, ngôn ngữ, quy mô tổ đội, số chỗ trống, ghi '` |
| `lib/features/settings/legal/privacy_policy.dart:166` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chú, trạng thái (mở, đủ người, đang chơi), số lượt bấm vào tổ đội, '` |
| `lib/features/settings/legal/privacy_policy.dart:167` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và tín hiệu "còn hoạt động" mà Ứng dụng gửi định kỳ khi bài đang '` |
| `lib/features/settings/legal/privacy_policy.dart:168` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mở. Bài tự hết hạn 30 phút sau tín hiệu cuối cùng. Mỗi người chỉ '` |
| `lib/features/settings/legal/privacy_policy.dart:169` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'có một bài đang hoạt động.'` |
| `lib/features/settings/legal/privacy_policy.dart:170` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bài tìm đồng đội:'` |
| `lib/features/settings/legal/privacy_policy.dart:173` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'skin bạn bình chọn, lượt thích và thời điểm thực hiện, dùng để xếp '` |
| `lib/features/settings/legal/privacy_policy.dart:174` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hạng skin được yêu thích.'` |
| `lib/features/settings/legal/privacy_policy.dart:175` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bình chọn và lượt thích:'` |
| `lib/features/settings/legal/privacy_policy.dart:178` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nội dung bị báo cáo, lý do và người báo cáo (dưới dạng mã người '` |
| `lib/features/settings/legal/privacy_policy.dart:179` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dùng), dùng để kiểm duyệt.'` |
| `lib/features/settings/legal/privacy_policy.dart:180` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Báo cáo vi phạm:'` |
| `lib/features/settings/legal/privacy_policy.dart:183` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'máy chủ ghi lại loại yêu cầu, đường dẫn, kết quả và thời gian xử '` |
| `lib/features/settings/legal/privacy_policy.dart:184` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lý của mỗi yêu cầu để vận hành và tìm lỗi. Địa chỉ IP chỉ được '` |
| `lib/features/settings/legal/privacy_policy.dart:185` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dùng dưới dạng mã băm có muối (mã băm một chiều có thêm một chuỗi '` |
| `lib/features/settings/legal/privacy_policy.dart:186` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ngẫu nhiên) để giới hạn số lần gửi yêu cầu, và không được ghi ở '` |
| `lib/features/settings/legal/privacy_policy.dart:187` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dạng đọc được. Cloudflare có thể xử lý địa chỉ IP khi chuyển tiếp '` |
| `lib/features/settings/legal/privacy_policy.dart:188` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'kết nối, theo chính sách riêng của họ.'` |
| `lib/features/settings/legal/privacy_policy.dart:189` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nhật ký truy cập của máy chủ:'` |
| `lib/features/settings/legal/privacy_policy.dart:192` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hình ảnh bạn đăng được lưu thành tệp trên ổ đĩa của máy chủ Cộng '` |
| `lib/features/settings/legal/privacy_policy.dart:193` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đồng và có thể mở qua một liên kết công khai. Cách xóa ảnh được '` |
| `lib/features/settings/legal/privacy_policy.dart:194` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nêu ở mục "Xóa dữ liệu".'` |
| `lib/features/settings/legal/privacy_policy.dart:195` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ảnh tải lên:'` |
| `lib/features/settings/legal/privacy_policy.dart:198` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'máy chủ được sao lưu hằng ngày; các bản sao lưu được giữ 14 ngày '` |
| `lib/features/settings/legal/privacy_policy.dart:199` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trên máy chủ của nhà phát hành.'` |
| `lib/features/settings/legal/privacy_policy.dart:200` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Sao lưu:'` |
| `lib/features/settings/legal/privacy_policy.dart:204` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mã truy cập Riot và xác minh Riot ID'` |
| `lib/features/settings/legal/privacy_policy.dart:206` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dữ liệu đăng nhập Riot của bạn (mã truy cập, mã quyền sở hữu và '` |
| `lib/features/settings/legal/privacy_policy.dart:207` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cookie) không bao giờ được gửi cho chúng tôi, trừ một ngoại lệ duy '` |
| `lib/features/settings/legal/privacy_policy.dart:208` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhất phục vụ tính năng Cộng đồng:'` |
| `lib/features/settings/legal/privacy_policy.dart:212` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng chỉ gửi mã truy cập Riot (access token) khi bạn lần đầu '` |
| `lib/features/settings/legal/privacy_policy.dart:213` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mở tính năng Cộng đồng và xác nhận đồng ý trong hộp thoại hiện ra '` |
| `lib/features/settings/legal/privacy_policy.dart:214` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'một lần, hoặc khi bạn kết nối lại sau khi lần đăng nhập Cộng đồng '` |
| `lib/features/settings/legal/privacy_policy.dart:215` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của bạn hết hạn. Nếu bạn không đồng ý, Cộng đồng không hoạt động '` |
| `lib/features/settings/legal/privacy_policy.dart:216` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và không có mã nào được gửi đi. Mã được gửi tới máy chủ ValVN qua '` |
| `lib/features/settings/legal/privacy_policy.dart:217` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'kết nối mã hóa (HTTPS).'` |
| `lib/features/settings/legal/privacy_policy.dart:220` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Máy chủ dùng mã này đúng một lần để hỏi máy chủ của Riot Games về '` |
| `lib/features/settings/legal/privacy_policy.dart:221` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thông tin định danh của bạn (PUUID và Riot ID), rồi hủy mã ngay '` |
| `lib/features/settings/legal/privacy_policy.dart:222` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lập tức. Mã không được lưu, không được ghi vào nhật ký của máy '` |
| `lib/features/settings/legal/privacy_policy.dart:223` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chủ và không được dùng cho bất kỳ mục đích nào khác.'` |
| `lib/features/settings/legal/privacy_policy.dart:226` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Máy chủ cấp cho Ứng dụng một mã đăng nhập Cộng đồng riêng, có hiệu '` |
| `lib/features/settings/legal/privacy_policy.dart:227` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lực 30 ngày. Mã này được lưu trong vùng lưu trữ bảo mật trên thiết '` |
| `lib/features/settings/legal/privacy_policy.dart:228` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bị và bị xóa khi bạn đăng xuất tài khoản.'` |
| `lib/features/settings/legal/privacy_policy.dart:231` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Máy chủ Cộng đồng không bao giờ thay mặt bạn thực hiện thao tác nào '` |
| `lib/features/settings/legal/privacy_policy.dart:232` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trên Tài khoản Riot.'` |
| `lib/features/settings/legal/privacy_policy.dart:236` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mục đích xử lý'` |
| `lib/features/settings/legal/privacy_policy.dart:239` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Hiển thị thông tin tài khoản, cửa hàng, bộ sưu tập, trận đấu và các '` |
| `lib/features/settings/legal/privacy_policy.dart:240` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tính năng bạn yêu cầu.'` |
| `lib/features/settings/legal/privacy_policy.dart:243` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Gửi thông báo ngay trên thiết bị về cửa hàng, wishlist và Chợ Đêm '` |
| `lib/features/settings/legal/privacy_policy.dart:244` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nếu bạn bật.'` |
| `lib/features/settings/legal/privacy_policy.dart:247` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Vận hành Cộng đồng: xác minh người đăng là chủ Riot ID, hiển thị '` |
| `lib/features/settings/legal/privacy_policy.dart:248` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bài đăng, bình luận, bài tìm đồng đội và bảng xếp hạng skin.'` |
| `lib/features/settings/legal/privacy_policy.dart:251` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bảo đảm an toàn: chống spam, lạm dụng và gian lận; kiểm duyệt nội '` |
| `lib/features/settings/legal/privacy_policy.dart:252` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dung bị báo cáo; giới hạn số lần gửi yêu cầu trong một khoảng thời '` |
| `lib/features/settings/legal/privacy_policy.dart:253` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'gian.'` |
| `lib/features/settings/legal/privacy_policy.dart:255` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tìm và sửa lỗi khi bạn chủ động gửi báo lỗi cho ValVN.'` |
| `lib/features/settings/legal/privacy_policy.dart:256` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tuân thủ nghĩa vụ theo quy định của pháp luật.'` |
| `lib/features/settings/legal/privacy_policy.dart:259` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi không sử dụng dữ liệu của bạn cho quảng cáo, không lập hồ '` |
| `lib/features/settings/legal/privacy_policy.dart:260` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'sơ hành vi và không bán, cho thuê hay trao đổi dữ liệu cá nhân.'` |
| `lib/features/settings/legal/privacy_policy.dart:263` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cơ sở pháp lý'` |
| `lib/features/settings/legal/privacy_policy.dart:266` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bạn đồng ý khi tiếp tục sử dụng Ứng dụng sau khi được thông báo về '` |
| `lib/features/settings/legal/privacy_policy.dart:267` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chính sách này, và đồng ý riêng khi bạn xác nhận hộp thoại kết nối '` |
| `lib/features/settings/legal/privacy_policy.dart:268` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cộng đồng, bật thông báo hay lưu thông tin đăng nhập. Bạn có thể '` |
| `lib/features/settings/legal/privacy_policy.dart:269` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'rút lại sự đồng ý bất cứ lúc nào.'` |
| `lib/features/settings/legal/privacy_policy.dart:270` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Sự đồng ý của bạn:'` |
| `lib/features/settings/legal/privacy_policy.dart:273` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'xử lý cần thiết để cung cấp các tính năng bạn yêu cầu theo Điều '` |
| `lib/features/settings/legal/privacy_policy.dart:274` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khoản sử dụng.'` |
| `lib/features/settings/legal/privacy_policy.dart:275` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thực hiện thỏa thuận:'` |
| `lib/features/settings/legal/privacy_policy.dart:278` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bảo vệ Cộng đồng khỏi spam, lạm dụng và gian lận, kiểm duyệt nội '` |
| `lib/features/settings/legal/privacy_policy.dart:279` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dung bị báo cáo và giữ an ninh cho máy chủ, với dữ liệu ở mức tối '` |
| `lib/features/settings/legal/privacy_policy.dart:280` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thiểu cần thiết.'` |
| `lib/features/settings/legal/privacy_policy.dart:281` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Lợi ích chính đáng:'` |
| `lib/features/settings/legal/privacy_policy.dart:284` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khi pháp luật yêu cầu, ví dụ phản hồi yêu cầu hợp pháp của cơ quan '` |
| `lib/features/settings/legal/privacy_policy.dart:285` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhà nước có thẩm quyền.'` |
| `lib/features/settings/legal/privacy_policy.dart:286` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nghĩa vụ pháp lý:'` |
| `lib/features/settings/legal/privacy_policy.dart:290` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chia sẻ dữ liệu'` |
| `lib/features/settings/legal/privacy_policy.dart:291` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi chỉ chia sẻ dữ liệu trong các trường hợp sau:'` |
| `lib/features/settings/legal/privacy_policy.dart:294` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng kết nối trực tiếp tới máy chủ của Riot Games bằng đăng '` |
| `lib/features/settings/legal/privacy_policy.dart:295` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhập Riot của bạn để đọc dữ liệu tài khoản và thực hiện thao tác '` |
| `lib/features/settings/legal/privacy_policy.dart:296` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bạn yêu cầu.'` |
| `lib/features/settings/legal/privacy_policy.dart:297` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot Games:'` |
| `lib/features/settings/legal/privacy_policy.dart:300` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng tải dữ liệu công khai về vật phẩm; không gửi thông tin '` |
| `lib/features/settings/legal/privacy_policy.dart:301` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tài khoản của bạn.'` |
| `lib/features/settings/legal/privacy_policy.dart:302` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'valorant-api.com:'` |
| `lib/features/settings/legal/privacy_policy.dart:305` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng có thể tải trạng thái máy chủ công khai của Riot và tệp '` |
| `lib/features/settings/legal/privacy_policy.dart:306` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thiết lập chung của ValVN; các yêu cầu này không kèm dữ liệu cá '` |
| `lib/features/settings/legal/privacy_policy.dart:307` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhân.'` |
| `lib/features/settings/legal/privacy_policy.dart:308` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tệp công khai:'` |
| `lib/features/settings/legal/privacy_policy.dart:311` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cung cấp mạng chuyển tiếp kết nối tới máy chủ Cộng đồng. Cloudflare '` |
| `lib/features/settings/legal/privacy_policy.dart:312` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'không lưu dữ liệu Cộng đồng của chúng tôi nhưng có thể xử lý dữ '` |
| `lib/features/settings/legal/privacy_policy.dart:313` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'liệu kỹ thuật như địa chỉ IP theo chính sách riêng của họ.'` |
| `lib/features/settings/legal/privacy_policy.dart:314` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cloudflare, Inc.:'` |
| `lib/features/settings/legal/privacy_policy.dart:317` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hồ sơ Cộng đồng, bài đăng, hình ảnh, bình luận và bài tìm đồng đội '` |
| `lib/features/settings/legal/privacy_policy.dart:318` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của bạn hiển thị với người dùng ValVN khác. Hình ảnh đã đăng có '` |
| `lib/features/settings/legal/privacy_policy.dart:319` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thể mở được qua một liên kết công khai.'` |
| `lib/features/settings/legal/privacy_policy.dart:320` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Người dùng khác:'` |
| `lib/features/settings/legal/privacy_policy.dart:323` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khi có yêu cầu hợp pháp theo quy định của pháp luật áp dụng cho nhà '` |
| `lib/features/settings/legal/privacy_policy.dart:324` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phát hành.'` |
| `lib/features/settings/legal/privacy_policy.dart:325` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cơ quan nhà nước có thẩm quyền:'` |
| `lib/features/settings/legal/privacy_policy.dart:329` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chuyển dữ liệu qua biên giới'` |
| `lib/features/settings/legal/privacy_policy.dart:331` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Máy chủ Cộng đồng do nhà phát hành tự vận hành. Kết nối tới máy chủ '` |
| `lib/features/settings/legal/privacy_policy.dart:332` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'này đi qua mạng toàn cầu của Cloudflare, Inc., nên dữ liệu có thể đi '` |
| `lib/features/settings/legal/privacy_policy.dart:333` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'qua nhiều quốc gia. Dữ liệu Cộng đồng bạn đăng hiển thị với người '` |
| `lib/features/settings/legal/privacy_policy.dart:334` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dùng ValVN ở mọi nơi. Khi bạn dùng Ứng dụng, thiết bị của bạn cũng '` |
| `lib/features/settings/legal/privacy_policy.dart:335` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'kết nối trực tiếp tới máy chủ của Riot Games. Chúng tôi áp dụng các '` |
| `lib/features/settings/legal/privacy_policy.dart:336` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'biện pháp bảo vệ phù hợp và thực hiện nghĩa vụ liên quan đến việc '` |
| `lib/features/settings/legal/privacy_policy.dart:337` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chuyển dữ liệu cá nhân qua biên giới theo pháp luật Việt Nam và, khi '` |
| `lib/features/settings/legal/privacy_policy.dart:338` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bạn ở nơi có quy định tương ứng, theo pháp luật nơi bạn sống.'` |
| `lib/features/settings/legal/privacy_policy.dart:341` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thời gian lưu trữ'` |
| `lib/features/settings/legal/privacy_policy.dart:344` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lưu cho đến khi bạn đăng xuất tài khoản tương ứng, xóa dữ liệu tạm '` |
| `lib/features/settings/legal/privacy_policy.dart:345` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hoặc gỡ Ứng dụng. Ảnh lưu tạm tự làm mới sau khoảng 30 ngày.'` |
| `lib/features/settings/legal/privacy_policy.dart:346` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dữ liệu trên thiết bị:'` |
| `lib/features/settings/legal/privacy_policy.dart:349` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tự hết hạn và ngừng hiển thị 30 phút sau tín hiệu "còn hoạt động" '` |
| `lib/features/settings/legal/privacy_policy.dart:350` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cuối cùng; dữ liệu hết hạn được xóa định kỳ.'` |
| `lib/features/settings/legal/privacy_policy.dart:351` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bài tìm đồng đội:'` |
| `lib/features/settings/legal/privacy_policy.dart:354` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lưu cho đến khi bạn xóa, hoặc khi chúng tôi gỡ do vi phạm, hoặc khi '` |
| `lib/features/settings/legal/privacy_policy.dart:355` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bạn yêu cầu xóa dữ liệu Cộng đồng.'` |
| `lib/features/settings/legal/privacy_policy.dart:356` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bài đăng, đánh giá, bình luận, bình chọn:'` |
| `lib/features/settings/legal/privacy_policy.dart:359` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chỉ giữ tối đa 12 tháng để xử lý vi phạm và phòng chống lạm dụng, '` |
| `lib/features/settings/legal/privacy_policy.dart:360` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'rồi máy chủ tự xóa. Báo cáo về nội dung đã bị xóa cũng bị xóa, và '` |
| `lib/features/settings/legal/privacy_policy.dart:361` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'báo cáo do chính bạn gửi được ẩn danh khi bạn xóa dữ liệu Cộng '` |
| `lib/features/settings/legal/privacy_policy.dart:362` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đồng.'` |
| `lib/features/settings/legal/privacy_policy.dart:363` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Báo cáo vi phạm:'` |
| `lib/features/settings/legal/privacy_policy.dart:366` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chỉ giữ mã băm có muối (của địa chỉ IP) để giới hạn số lần gửi yêu '` |
| `lib/features/settings/legal/privacy_policy.dart:367` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cầu; nhật ký kỹ thuật chỉ được giữ trong thời gian cần thiết để '` |
| `lib/features/settings/legal/privacy_policy.dart:368` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tìm lỗi và bảo mật.'` |
| `lib/features/settings/legal/privacy_policy.dart:369` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nhật ký truy cập của máy chủ:'` |
| `lib/features/settings/legal/privacy_policy.dart:372` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'giữ 14 ngày rồi bị ghi đè; nội dung đã xóa vì thế có thể còn trong '` |
| `lib/features/settings/legal/privacy_policy.dart:373` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bản sao lưu tối đa 14 ngày.'` |
| `lib/features/settings/legal/privacy_policy.dart:374` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bản sao lưu:'` |
| `lib/features/settings/legal/privacy_policy.dart:377` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hết hiệu lực sau 30 ngày và bị xóa khỏi thiết bị khi bạn đăng xuất.'` |
| `lib/features/settings/legal/privacy_policy.dart:378` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mã đăng nhập Cộng đồng:'` |
| `lib/features/settings/legal/privacy_policy.dart:382` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Xóa dữ liệu'` |
| `lib/features/settings/legal/privacy_policy.dart:383` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Trên thiết bị'` |
| `lib/features/settings/legal/privacy_policy.dart:386` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Đăng xuất một tài khoản trong Cài đặt sẽ xóa khỏi thiết bị dữ liệu '` |
| `lib/features/settings/legal/privacy_policy.dart:387` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đăng nhập Riot (mã truy cập và cookie), thông tin đăng nhập đã '` |
| `lib/features/settings/legal/privacy_policy.dart:388` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lưu, mã đăng nhập Cộng đồng, dữ liệu tạm và thông báo đã lên lịch '` |
| `lib/features/settings/legal/privacy_policy.dart:389` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của tài khoản đó. Wishlist được giữ lại để dùng khi bạn đăng nhập '` |
| `lib/features/settings/legal/privacy_policy.dart:390` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lại; bạn có thể tự xóa từng mục.'` |
| `lib/features/settings/legal/privacy_policy.dart:393` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'"Xóa dữ liệu tạm" trong Cài đặt > Nâng cao xóa ảnh, dữ liệu đã tải '` |
| `lib/features/settings/legal/privacy_policy.dart:394` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'để xem khi không có mạng và báo lỗi đã ghi trên thiết bị.'` |
| `lib/features/settings/legal/privacy_policy.dart:397` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Gỡ Ứng dụng sẽ xóa toàn bộ dữ liệu của Ứng dụng trên thiết bị.'` |
| `lib/features/settings/legal/privacy_policy.dart:400` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Trên máy chủ Cộng đồng'` |
| `lib/features/settings/legal/privacy_policy.dart:403` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn có thể tự xóa bài đăng, đánh giá, bình luận, bài tìm đồng đội và '` |
| `lib/features/settings/legal/privacy_policy.dart:404` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bỏ bình chọn ngay trong Ứng dụng.'` |
| `lib/features/settings/legal/privacy_policy.dart:407` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Để xóa toàn bộ dữ liệu Cộng đồng gắn với Riot ID của bạn, vào Cài '` |
| `lib/features/settings/legal/privacy_policy.dart:408` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đặt > "Dữ liệu Cộng đồng của bạn" > "Xóa dữ liệu Cộng đồng của '` |
| `lib/features/settings/legal/privacy_policy.dart:409` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tôi". Máy chủ sẽ xóa vĩnh viễn bài đăng, bình luận, đánh giá, lượt '` |
| `lib/features/settings/legal/privacy_policy.dart:410` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thích, bình chọn, bài tìm đồng đội, ảnh và tài khoản Cộng đồng của '` |
| `lib/features/settings/legal/privacy_policy.dart:411` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bạn. Việc này không thể hoàn tác. Bạn cũng có thể gửi email tới '` |
| `lib/features/settings/legal/privacy_policy.dart:412` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'$_email kèm Riot ID; chúng tôi có thể yêu cầu xác minh bạn là chủ '` |
| `lib/features/settings/legal/privacy_policy.dart:413` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tài khoản và xử lý trong vòng 30 ngày.'` |
| `lib/features/settings/legal/privacy_policy.dart:416` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Hình ảnh: tệp ảnh bị xóa cùng bài đăng hoặc tài khoản. Ảnh của nội '` |
| `lib/features/settings/legal/privacy_policy.dart:417` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dung bị ẩn vì bị báo cáo sẽ không còn truy cập công khai được và bị '` |
| `lib/features/settings/legal/privacy_policy.dart:418` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'xóa sau 30 ngày; ảnh đã tải lên nhưng không được dùng bị xóa sau 24 '` |
| `lib/features/settings/legal/privacy_policy.dart:419` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'giờ. Khi bạn tải ảnh lên, máy chủ gỡ thông tin vị trí và các dữ '` |
| `lib/features/settings/legal/privacy_policy.dart:420` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'liệu ẩn trong ảnh (siêu dữ liệu EXIF).'` |
| `lib/features/settings/legal/privacy_policy.dart:423` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nội dung đã xóa có thể còn trong bản sao lưu tối đa 14 ngày trước '` |
| `lib/features/settings/legal/privacy_policy.dart:424` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khi bị ghi đè.'` |
| `lib/features/settings/legal/privacy_policy.dart:427` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Lưu ý: đăng xuất khỏi Ứng dụng không tự động xóa nội dung bạn đã '` |
| `lib/features/settings/legal/privacy_policy.dart:428` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đăng trên máy chủ Cộng đồng.'` |
| `lib/features/settings/legal/privacy_policy.dart:432` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thông báo và tác vụ nền'` |
| `lib/features/settings/legal/privacy_policy.dart:434` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN chỉ dùng thông báo cục bộ, tức là thông báo do chính thiết bị '` |
| `lib/features/settings/legal/privacy_policy.dart:435` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của bạn tạo ra. Chúng tôi không vận hành máy chủ gửi thông báo đẩy và '` |
| `lib/features/settings/legal/privacy_policy.dart:436` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'không thu thập mã thiết bị. Ứng dụng đăng ký với hệ điều hành một '` |
| `lib/features/settings/legal/privacy_policy.dart:437` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tác vụ chạy nền định kỳ, chạy ngay trên thiết bị, để giữ đăng nhập '` |
| `lib/features/settings/legal/privacy_policy.dart:438` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot của bạn còn hiệu lực và, nếu bạn bật, đọc cửa hàng trực tiếp '` |
| `lib/features/settings/legal/privacy_policy.dart:439` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'từ Riot để báo skin trong wishlist hoặc Chợ Đêm. Bạn có thể tắt '` |
| `lib/features/settings/legal/privacy_policy.dart:440` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thông báo trong Cài đặt của Ứng dụng hoặc của hệ điều hành.'` |
| `lib/features/settings/legal/privacy_policy.dart:443` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dịch nội dung trên thiết bị'` |
| `lib/features/settings/legal/privacy_policy.dart:445` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Khi bạn chọn dịch nội dung Cộng đồng, ValVN dùng công cụ dịch ML Kit '` |
| `lib/features/settings/legal/privacy_policy.dart:446` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của Google chạy trên thiết bị. Nếu chưa có gói ngôn ngữ cần thiết, '` |
| `lib/features/settings/legal/privacy_policy.dart:447` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN hỏi bạn trước khi tải gói từ Google (khoảng 30 MB mỗi gói). '` |
| `lib/features/settings/legal/privacy_policy.dart:448` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Việc tải cần kết nối mạng và Google có thể nhận thông tin kỹ thuật '` |
| `lib/features/settings/legal/privacy_policy.dart:449` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của kết nối, như địa chỉ IP, theo chính sách của Google. Nội dung '` |
| `lib/features/settings/legal/privacy_policy.dart:450` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bài viết được dịch trên thiết bị, không gửi tới Google để dịch. '` |
| `lib/features/settings/legal/privacy_policy.dart:451` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn có thể không dùng tính năng này; ValVN không dùng chatbot hay '` |
| `lib/features/settings/legal/privacy_policy.dart:452` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dịch vụ tạo nội dung bằng AI.'` |
| `lib/features/settings/legal/privacy_policy.dart:455` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phân tích, quảng cáo và theo dõi'` |
| `lib/features/settings/legal/privacy_policy.dart:457` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN không tích hợp công cụ phân tích, công cụ tự động báo cáo sự '` |
| `lib/features/settings/legal/privacy_policy.dart:458` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cố, quảng cáo hay công cụ theo dõi của bên thứ ba. ValVN không dùng '` |
| `lib/features/settings/legal/privacy_policy.dart:459` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mã định danh quảng cáo và không theo dõi bạn giữa các ứng dụng hay '` |
| `lib/features/settings/legal/privacy_policy.dart:460` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trang web. Nếu điều này thay đổi trong tương lai, chúng tôi sẽ cập '` |
| `lib/features/settings/legal/privacy_policy.dart:461` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhật Chính sách và xin sự đồng ý của bạn khi pháp luật yêu cầu.'` |
| `lib/features/settings/legal/privacy_policy.dart:464` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bảo mật dữ liệu'` |
| `lib/features/settings/legal/privacy_policy.dart:467` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thông tin bí mật (dữ liệu đăng nhập Riot, thông tin đăng nhập đã '` |
| `lib/features/settings/legal/privacy_policy.dart:468` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lưu, mã đăng nhập Cộng đồng) chỉ được lưu trong vùng lưu trữ bảo '` |
| `lib/features/settings/legal/privacy_policy.dart:469` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mật của hệ điều hành (Keychain hoặc Keystore) và được xóa khi cài '` |
| `lib/features/settings/legal/privacy_policy.dart:470` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lại Ứng dụng.'` |
| `lib/features/settings/legal/privacy_policy.dart:472` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mọi kết nối mạng đều được mã hóa (HTTPS/TLS).'` |
| `lib/features/settings/legal/privacy_policy.dart:474` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Báo lỗi được lọc tự động để loại bỏ dữ liệu đăng nhập Riot, mật '` |
| `lib/features/settings/legal/privacy_policy.dart:475` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khẩu và ID tài khoản.'` |
| `lib/features/settings/legal/privacy_policy.dart:478` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Máy chủ Cộng đồng chỉ lưu mã băm một chiều của PUUID; giới hạn số '` |
| `lib/features/settings/legal/privacy_policy.dart:479` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lần gửi yêu cầu (dựa trên mã băm có muối của địa chỉ IP); chỉ cho '` |
| `lib/features/settings/legal/privacy_policy.dart:480` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phép bạn xóa nội dung của chính mình; và giữ khóa bí mật trong '` |
| `lib/features/settings/legal/privacy_policy.dart:481` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phần thiết lập riêng của máy chủ, không đưa vào mã nguồn.'` |
| `lib/features/settings/legal/privacy_policy.dart:484` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi chỉ thu thập dữ liệu ở mức tối thiểu cần thiết cho tính '` |
| `lib/features/settings/legal/privacy_policy.dart:485` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'năng.'` |
| `lib/features/settings/legal/privacy_policy.dart:489` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không có biện pháp nào an toàn tuyệt đối. Nếu xảy ra sự cố vi phạm dữ '` |
| `lib/features/settings/legal/privacy_policy.dart:490` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'liệu cá nhân, chúng tôi sẽ thông báo cho cơ quan có thẩm quyền và '` |
| `lib/features/settings/legal/privacy_policy.dart:491` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'người dùng bị ảnh hưởng theo quy định của pháp luật.'` |
| `lib/features/settings/legal/privacy_policy.dart:494` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Trẻ em'` |
| `lib/features/settings/legal/privacy_policy.dart:496` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng không dành cho trẻ em dưới 13 tuổi. Ở những nơi pháp luật '` |
| `lib/features/settings/legal/privacy_policy.dart:497` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quy định độ tuổi tối thiểu để tự đồng ý xử lý dữ liệu cao hơn (ví dụ '` |
| `lib/features/settings/legal/privacy_policy.dart:498` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'16 tuổi ở một số nước thuộc Liên minh châu Âu), bạn chỉ được sử dụng '` |
| `lib/features/settings/legal/privacy_policy.dart:499` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng, đặc biệt là tính năng Cộng đồng, khi đã đủ tuổi đó hoặc khi '` |
| `lib/features/settings/legal/privacy_policy.dart:500` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'có sự đồng ý và giám sát của cha, mẹ hoặc người giám hộ hợp pháp. '` |
| `lib/features/settings/legal/privacy_policy.dart:501` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nếu bạn là phụ huynh và cho rằng con mình đã cung cấp dữ liệu cho '` |
| `lib/features/settings/legal/privacy_policy.dart:502` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cộng đồng khi chưa có sự đồng ý, vui lòng liên hệ để chúng tôi xóa dữ '` |
| `lib/features/settings/legal/privacy_policy.dart:503` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'liệu đó.'` |
| `lib/features/settings/legal/privacy_policy.dart:506` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền của bạn'` |
| `lib/features/settings/legal/privacy_policy.dart:508` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Theo pháp luật Việt Nam về bảo vệ dữ liệu cá nhân (bao gồm Nghị định '` |
| `lib/features/settings/legal/privacy_policy.dart:509` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'13/2023/NĐ-CP), bạn có các quyền sau:'` |
| `lib/features/settings/legal/privacy_policy.dart:513` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'được biết về hoạt động xử lý dữ liệu của mình;'` |
| `lib/features/settings/legal/privacy_policy.dart:514` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền được biết:'` |
| `lib/features/settings/legal/privacy_policy.dart:517` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đồng ý hoặc không đồng ý cho xử lý dữ liệu;'` |
| `lib/features/settings/legal/privacy_policy.dart:518` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền đồng ý:'` |
| `lib/features/settings/legal/privacy_policy.dart:521` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'xem, chỉnh sửa hoặc yêu cầu chỉnh sửa dữ liệu của mình;'` |
| `lib/features/settings/legal/privacy_policy.dart:522` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền truy cập:'` |
| `lib/features/settings/legal/privacy_policy.dart:525` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'rút lại sự đồng ý đã cho;'` |
| `lib/features/settings/legal/privacy_policy.dart:526` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền rút lại sự đồng ý:'` |
| `lib/features/settings/legal/privacy_policy.dart:528` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'yêu cầu xóa dữ liệu của mình;'` |
| `lib/features/settings/legal/privacy_policy.dart:528` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền xóa dữ liệu:'` |
| `lib/features/settings/legal/privacy_policy.dart:530` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'yêu cầu hạn chế xử lý dữ liệu;'` |
| `lib/features/settings/legal/privacy_policy.dart:531` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền hạn chế xử lý:'` |
| `lib/features/settings/legal/privacy_policy.dart:534` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'yêu cầu được cung cấp dữ liệu của mình;'` |
| `lib/features/settings/legal/privacy_policy.dart:535` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền được cung cấp dữ liệu:'` |
| `lib/features/settings/legal/privacy_policy.dart:538` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phản đối việc xử lý dữ liệu nhằm mục đích không mong muốn;'` |
| `lib/features/settings/legal/privacy_policy.dart:539` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền phản đối xử lý:'` |
| `lib/features/settings/legal/privacy_policy.dart:542` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khiếu nại, tố cáo, khởi kiện và yêu cầu bồi thường thiệt hại theo '` |
| `lib/features/settings/legal/privacy_policy.dart:543` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quy định của pháp luật;'` |
| `lib/features/settings/legal/privacy_policy.dart:544` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền khiếu nại và yêu cầu bồi thường:'` |
| `lib/features/settings/legal/privacy_policy.dart:547` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tự bảo vệ dữ liệu cá nhân của mình.'` |
| `lib/features/settings/legal/privacy_policy.dart:548` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền tự bảo vệ:'` |
| `lib/features/settings/legal/privacy_policy.dart:552` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phần lớn dữ liệu nằm trên thiết bị và bạn có thể tự xem hoặc xóa ngay '` |
| `lib/features/settings/legal/privacy_policy.dart:553` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trong Ứng dụng. Với dữ liệu trên máy chủ Cộng đồng, hãy gửi yêu cầu '` |
| `lib/features/settings/legal/privacy_policy.dart:554` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tới $_email. Chúng tôi xử lý yêu cầu trong vòng 30 ngày và có thể cần '` |
| `lib/features/settings/legal/privacy_policy.dart:555` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'xác minh danh tính của bạn trước khi xử lý. Bạn cũng có thể tự tải '` |
| `lib/features/settings/legal/privacy_policy.dart:556` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bản sao dữ liệu Cộng đồng của mình (tệp JSON) tại Cài đặt > "Dữ liệu '` |
| `lib/features/settings/legal/privacy_policy.dart:557` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cộng đồng của bạn" > "Tải dữ liệu của tôi", và tự xóa dữ liệu đó '` |
| `lib/features/settings/legal/privacy_policy.dart:558` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ngay tại đây.'` |
| `lib/features/settings/legal/privacy_policy.dart:561` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền của bạn theo luật nơi bạn sống'` |
| `lib/features/settings/legal/privacy_policy.dart:563` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tùy nơi bạn sống, pháp luật địa phương có thể cho bạn thêm quyền. '` |
| `lib/features/settings/legal/privacy_policy.dart:564` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dù bạn ở đâu, bạn đều có thể thực hiện các quyền thực tế dưới đây '` |
| `lib/features/settings/legal/privacy_policy.dart:565` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bằng cách gửi email tới $_email; chúng tôi xử lý yêu cầu trong vòng '` |
| `lib/features/settings/legal/privacy_policy.dart:566` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'30 ngày và không phân biệt đối xử với bạn vì đã thực hiện quyền của '` |
| `lib/features/settings/legal/privacy_policy.dart:567` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mình.'` |
| `lib/features/settings/legal/privacy_policy.dart:571` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'biết chúng tôi giữ dữ liệu gì về bạn và nhận một bản sao;'` |
| `lib/features/settings/legal/privacy_policy.dart:572` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Truy cập:'` |
| `lib/features/settings/legal/privacy_policy.dart:575` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'yêu cầu xóa dữ liệu Cộng đồng gắn với Riot ID của bạn (xem mục '` |
| `lib/features/settings/legal/privacy_policy.dart:576` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'"Xóa dữ liệu");'` |
| `lib/features/settings/legal/privacy_policy.dart:577` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Xóa:'` |
| `lib/features/settings/legal/privacy_policy.dart:580` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'sửa dữ liệu không chính xác (hồ sơ Cộng đồng được làm mới từ tài '` |
| `lib/features/settings/legal/privacy_policy.dart:581` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khoản Riot mỗi lần bạn kết nối);'` |
| `lib/features/settings/legal/privacy_policy.dart:582` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chỉnh sửa:'` |
| `lib/features/settings/legal/privacy_policy.dart:585` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhận dữ liệu của bạn ở định dạng thông dụng;'` |
| `lib/features/settings/legal/privacy_policy.dart:586` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Di chuyển dữ liệu:'` |
| `lib/features/settings/legal/privacy_policy.dart:589` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phản đối hoặc yêu cầu hạn chế việc xử lý, và rút lại sự đồng ý bất '` |
| `lib/features/settings/legal/privacy_policy.dart:590` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cứ lúc nào;'` |
| `lib/features/settings/legal/privacy_policy.dart:591` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phản đối, hạn chế và rút lại đồng ý:'` |
| `lib/features/settings/legal/privacy_policy.dart:594` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khiếu nại tới cơ quan bảo vệ dữ liệu có thẩm quyền ở nơi bạn sống.'` |
| `lib/features/settings/legal/privacy_policy.dart:595` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Khiếu nại:'` |
| `lib/features/settings/legal/privacy_policy.dart:598` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Một số ví dụ về luật có thể áp dụng cho bạn:'` |
| `lib/features/settings/legal/privacy_policy.dart:601` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nếu bạn ở Liên minh châu Âu, Khu vực kinh tế châu Âu hoặc Vương quốc '` |
| `lib/features/settings/legal/privacy_policy.dart:602` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Anh: bạn có các quyền truy cập, chỉnh sửa, xóa, hạn chế, di chuyển '` |
| `lib/features/settings/legal/privacy_policy.dart:603` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dữ liệu, phản đối và rút lại sự đồng ý, cùng quyền khiếu nại tới cơ '` |
| `lib/features/settings/legal/privacy_policy.dart:604` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quan giám sát dữ liệu tại quốc gia bạn sống. Cơ sở xử lý dữ liệu '` |
| `lib/features/settings/legal/privacy_policy.dart:605` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'được nêu ở mục "Cơ sở pháp lý".'` |
| `lib/features/settings/legal/privacy_policy.dart:606` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'GDPR / UK GDPR:'` |
| `lib/features/settings/legal/privacy_policy.dart:609` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nếu bạn là cư dân California: bạn có quyền biết, xóa, sửa dữ liệu '` |
| `lib/features/settings/legal/privacy_policy.dart:610` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và từ chối việc "bán" hay "chia sẻ" dữ liệu. ValVN không bán và '` |
| `lib/features/settings/legal/privacy_policy.dart:611` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'không chia sẻ dữ liệu cá nhân cho quảng cáo theo ngữ cảnh khác.'` |
| `lib/features/settings/legal/privacy_policy.dart:612` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'CCPA / CPRA:'` |
| `lib/features/settings/legal/privacy_policy.dart:615` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nếu bạn ở Brazil: bạn có các quyền truy cập, chỉnh sửa, ẩn danh, '` |
| `lib/features/settings/legal/privacy_policy.dart:616` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'xóa, di chuyển dữ liệu và thông tin về việc chia sẻ dữ liệu.'` |
| `lib/features/settings/legal/privacy_policy.dart:617` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'LGPD:'` |
| `lib/features/settings/legal/privacy_policy.dart:620` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nếu bạn ở Trung Quốc đại lục hoặc nơi có luật tương tự: bạn có '` |
| `lib/features/settings/legal/privacy_policy.dart:621` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quyền biết, quyết định, hạn chế, từ chối, truy cập, sao chép, '` |
| `lib/features/settings/legal/privacy_policy.dart:622` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chỉnh sửa, xóa dữ liệu và yêu cầu giải thích về việc xử lý.'` |
| `lib/features/settings/legal/privacy_policy.dart:623` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'PIPL và luật tương tự:'` |
| `lib/features/settings/legal/privacy_policy.dart:626` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nếu bạn ở Việt Nam: các quyền nêu ở mục "Quyền của bạn" ở trên.'` |
| `lib/features/settings/legal/privacy_policy.dart:627` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nghị định 13/2023/NĐ-CP:'` |
| `lib/features/settings/legal/privacy_policy.dart:631` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi không thu thập nhiều dữ liệu hơn mức cần thiết và không '` |
| `lib/features/settings/legal/privacy_policy.dart:632` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thực hiện quyết định tự động có ảnh hưởng pháp lý tới bạn. Nếu bạn '` |
| `lib/features/settings/legal/privacy_policy.dart:633` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'không hài lòng với phản hồi của chúng tôi, bạn có quyền khiếu nại tới '` |
| `lib/features/settings/legal/privacy_policy.dart:634` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cơ quan có thẩm quyền ở nơi bạn sống.'` |
| `lib/features/settings/legal/privacy_policy.dart:637` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thay đổi Chính sách'` |
| `lib/features/settings/legal/privacy_policy.dart:639` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi có thể cập nhật Chính sách này khi Ứng dụng hoặc quy định '` |
| `lib/features/settings/legal/privacy_policy.dart:640` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'pháp luật thay đổi. Phiên bản và ngày hiệu lực luôn được ghi ở đầu văn '` |
| `lib/features/settings/legal/privacy_policy.dart:641` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bản. Với thay đổi quan trọng về cách xử lý dữ liệu, chúng tôi sẽ thông '` |
| `lib/features/settings/legal/privacy_policy.dart:642` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'báo trong Ứng dụng và xin lại sự đồng ý của bạn khi cần.'` |
| `lib/features/settings/legal/privacy_policy.dart:645` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Liên hệ'` |
| `lib/features/settings/legal/privacy_policy.dart:647` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mọi câu hỏi hoặc yêu cầu về quyền riêng tư và dữ liệu cá nhân, vui '` |
| `lib/features/settings/legal/privacy_policy.dart:648` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lòng liên hệ:'` |
| `lib/features/settings/legal/privacy_policy.dart:651` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bên kiểm soát dữ liệu:'` |
| `lib/features/settings/legal/privacy_policy.dart:652` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Email:'` |
| `lib/features/settings/legal/terms_of_service.dart:1` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_document.dart'` |
| `lib/features/settings/legal/terms_of_service.dart:2` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'legal_info.dart'` |
| `lib/features/settings/legal/terms_of_service.dart:9` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'terms'` |
| `lib/features/settings/legal/terms_of_service.dart:10` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Điều khoản sử dụng'` |
| `lib/features/settings/legal/terms_of_service.dart:11` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quy định khi bạn tải, cài đặt và sử dụng ValVN'` |
| `lib/features/settings/legal/terms_of_service.dart:12` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'1.0'` |
| `lib/features/settings/legal/terms_of_service.dart:15` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chào mừng bạn đến với ValVN. Điều khoản sử dụng này ("Điều khoản") là '` |
| `lib/features/settings/legal/terms_of_service.dart:16` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thỏa thuận ràng buộc giữa bạn và $_publisher ("chúng tôi") về việc tải, '` |
| `lib/features/settings/legal/terms_of_service.dart:17` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cài đặt và sử dụng ứng dụng ValVN trên iOS và Android, bao gồm cả các '` |
| `lib/features/settings/legal/terms_of_service.dart:18` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tính năng Cộng đồng (gọi chung là "Ứng dụng").'` |
| `lib/features/settings/legal/terms_of_service.dart:21` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tóm tắt: ValVN là ứng dụng đồng hành không chính thức, không thuộc Riot '` |
| `lib/features/settings/legal/terms_of_service.dart:22` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Games. Bạn đăng nhập bằng tài khoản Riot của chính mình trên trang chính '` |
| `lib/features/settings/legal/terms_of_service.dart:23` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thức của Riot. Bạn tự chịu trách nhiệm về tài khoản và mọi thao tác bạn '` |
| `lib/features/settings/legal/terms_of_service.dart:24` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thực hiện, cư xử văn minh trong Cộng đồng và không dùng ứng dụng để gian '` |
| `lib/features/settings/legal/terms_of_service.dart:25` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lận, tự động hóa hay khai thác trái phép. Ứng dụng được cung cấp nguyên '` |
| `lib/features/settings/legal/terms_of_service.dart:26` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trạng.'` |
| `lib/features/settings/legal/terms_of_service.dart:30` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chấp nhận Điều khoản'` |
| `lib/features/settings/legal/terms_of_service.dart:32` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bằng việc tải, cài đặt, đăng nhập hoặc tiếp tục sử dụng Ứng dụng, bạn '` |
| `lib/features/settings/legal/terms_of_service.dart:33` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'xác nhận đã đọc, hiểu và đồng ý với Điều khoản này, Chính sách quyền '` |
| `lib/features/settings/legal/terms_of_service.dart:34` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'riêng tư và Tiêu chuẩn cộng đồng của ValVN. Các văn bản này là một '` |
| `lib/features/settings/legal/terms_of_service.dart:35` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phần không tách rời của Điều khoản.'` |
| `lib/features/settings/legal/terms_of_service.dart:38` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nếu bạn không đồng ý với bất kỳ nội dung nào, vui lòng không sử dụng '` |
| `lib/features/settings/legal/terms_of_service.dart:39` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng và gỡ Ứng dụng khỏi thiết bị.'` |
| `lib/features/settings/legal/terms_of_service.dart:42` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Giải thích từ ngữ'` |
| `lib/features/settings/legal/terms_of_service.dart:45` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ứng dụng ValVN, các bản cập nhật, nội dung và dịch vụ đi kèm do '` |
| `lib/features/settings/legal/terms_of_service.dart:46` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chúng tôi cung cấp.'` |
| `lib/features/settings/legal/terms_of_service.dart:47` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'"Ứng dụng":'` |
| `lib/features/settings/legal/terms_of_service.dart:50` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tài khoản của bạn tại Riot Games dùng để chơi VALORANT.'` |
| `lib/features/settings/legal/terms_of_service.dart:51` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'"Tài khoản Riot":'` |
| `lib/features/settings/legal/terms_of_service.dart:54` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'các tính năng xã hội của ValVN như bảng tin, bài đăng, hình ảnh, '` |
| `lib/features/settings/legal/terms_of_service.dart:55` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bình luận, lượt thích, bình chọn skin và tìm đồng đội, vận hành '` |
| `lib/features/settings/legal/terms_of_service.dart:56` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trên máy chủ Cộng đồng của ValVN.'` |
| `lib/features/settings/legal/terms_of_service.dart:57` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'"Cộng đồng":'` |
| `lib/features/settings/legal/terms_of_service.dart:60` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mọi văn bản, hình ảnh, mã tổ đội, bình chọn, báo cáo và thông tin '` |
| `lib/features/settings/legal/terms_of_service.dart:61` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khác bạn gửi lên Cộng đồng.'` |
| `lib/features/settings/legal/terms_of_service.dart:62` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'"Nội dung người dùng":'` |
| `lib/features/settings/legal/terms_of_service.dart:66` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Điều kiện sử dụng'` |
| `lib/features/settings/legal/terms_of_service.dart:69` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn phải đủ điều kiện sở hữu và sử dụng Tài khoản Riot theo điều '` |
| `lib/features/settings/legal/terms_of_service.dart:70` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khoản của Riot Games, và từ đủ 13 tuổi trở lên (hoặc độ tuổi cao hơn '` |
| `lib/features/settings/legal/terms_of_service.dart:71` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mà luật nơi bạn sống yêu cầu, ví dụ 16 tuổi ở một số nước Liên minh '` |
| `lib/features/settings/legal/terms_of_service.dart:72` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'châu Âu).'` |
| `lib/features/settings/legal/terms_of_service.dart:75` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nếu bạn chưa đủ tuổi tự đồng ý theo luật nơi bạn sống (16 tuổi ở '` |
| `lib/features/settings/legal/terms_of_service.dart:76` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'một số nơi), bạn chỉ được sử dụng Ứng dụng khi cha, mẹ hoặc người '` |
| `lib/features/settings/legal/terms_of_service.dart:77` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'giám hộ hợp pháp đã đọc, đồng ý với Điều khoản này và Chính sách '` |
| `lib/features/settings/legal/terms_of_service.dart:78` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quyền riêng tư, đồng thời giám sát việc sử dụng của bạn.'` |
| `lib/features/settings/legal/terms_of_service.dart:81` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn không thuộc đối tượng bị pháp luật hiện hành cấm sử dụng dịch vụ '` |
| `lib/features/settings/legal/terms_of_service.dart:82` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và chưa từng bị chúng tôi chấm dứt quyền sử dụng Ứng dụng.'` |
| `lib/features/settings/legal/terms_of_service.dart:85` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn tự chịu trách nhiệm về thiết bị, kết nối mạng và chi phí dữ '` |
| `lib/features/settings/legal/terms_of_service.dart:86` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'liệu di động phát sinh khi sử dụng Ứng dụng.'` |
| `lib/features/settings/legal/terms_of_service.dart:90` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tài khoản Riot và thông tin đăng nhập'` |
| `lib/features/settings/legal/terms_of_service.dart:92` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn đăng nhập trong một cửa sổ web hiển thị trang đăng nhập chính thức '` |
| `lib/features/settings/legal/terms_of_service.dart:93` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'của Riot Games. ValVN không nhận, không đọc và không lưu mật khẩu mà '` |
| `lib/features/settings/legal/terms_of_service.dart:94` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bạn nhập vào trang đó. Sau khi đăng nhập, dữ liệu đăng nhập do Riot '` |
| `lib/features/settings/legal/terms_of_service.dart:95` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cấp (mã truy cập và cookie, tức là tệp giúp Riot nhớ bạn đã đăng '` |
| `lib/features/settings/legal/terms_of_service.dart:96` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhập) chỉ được lưu trong vùng lưu trữ bảo mật của hệ điều hành trên '` |
| `lib/features/settings/legal/terms_of_service.dart:97` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thiết bị của bạn.'` |
| `lib/features/settings/legal/terms_of_service.dart:101` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn chỉ được thêm vào Ứng dụng những Tài khoản Riot mà bạn sở hữu '` |
| `lib/features/settings/legal/terms_of_service.dart:102` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hoặc được chủ sở hữu cho phép hợp pháp.'` |
| `lib/features/settings/legal/terms_of_service.dart:105` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn chịu trách nhiệm giữ an toàn thiết bị, mật khẩu, mã xác thực '` |
| `lib/features/settings/legal/terms_of_service.dart:106` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hai lớp và mọi hoạt động diễn ra trên Tài khoản Riot của mình.'` |
| `lib/features/settings/legal/terms_of_service.dart:109` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tính năng "Thông tin đăng nhập đã lưu" là tùy chọn: nếu bạn tự lưu '` |
| `lib/features/settings/legal/terms_of_service.dart:110` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tên đăng nhập và mật khẩu, chúng chỉ nằm trong vùng lưu trữ bảo mật '` |
| `lib/features/settings/legal/terms_of_service.dart:111` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trên thiết bị và chỉ được điền vào trang đăng nhập của Riot khi bạn '` |
| `lib/features/settings/legal/terms_of_service.dart:112` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'yêu cầu. Bạn cân nhắc rủi ro khi lưu mật khẩu trên thiết bị dùng '` |
| `lib/features/settings/legal/terms_of_service.dart:113` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chung và có thể xóa thông tin này bất cứ lúc nào.'` |
| `lib/features/settings/legal/terms_of_service.dart:116` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Hãy đăng xuất khỏi Ứng dụng và đổi mật khẩu Riot ngay nếu bạn nghi '` |
| `lib/features/settings/legal/terms_of_service.dart:117` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ngờ thiết bị hoặc tài khoản bị truy cập trái phép.'` |
| `lib/features/settings/legal/terms_of_service.dart:120` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Việc sử dụng Tài khoản Riot luôn phải tuân thủ Điều khoản dịch vụ và '` |
| `lib/features/settings/legal/terms_of_service.dart:121` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'các chính sách của Riot Games. Riot Games có thể hạn chế hoặc khóa '` |
| `lib/features/settings/legal/terms_of_service.dart:122` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tài khoản của bạn theo chính sách riêng của họ; chúng tôi không có '` |
| `lib/features/settings/legal/terms_of_service.dart:123` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quyền can thiệp vào các quyết định đó.'` |
| `lib/features/settings/legal/terms_of_service.dart:127` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền sử dụng Ứng dụng'` |
| `lib/features/settings/legal/terms_of_service.dart:129` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Với điều kiện bạn tuân thủ Điều khoản này, chúng tôi cấp cho bạn quyền '` |
| `lib/features/settings/legal/terms_of_service.dart:130` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'có giới hạn, không độc quyền, không thể chuyển nhượng, không thể cấp '` |
| `lib/features/settings/legal/terms_of_service.dart:131` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phép lại và có thể thu hồi để cài đặt và sử dụng Ứng dụng trên các '` |
| `lib/features/settings/legal/terms_of_service.dart:132` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thiết bị mà bạn sở hữu hoặc kiểm soát, cho mục đích cá nhân, phi '` |
| `lib/features/settings/legal/terms_of_service.dart:133` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thương mại.'` |
| `lib/features/settings/legal/terms_of_service.dart:136` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN là phần mềm độc quyền, không phải phần mềm mã nguồn mở. Chúng '` |
| `lib/features/settings/legal/terms_of_service.dart:137` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tôi cấp phép sử dụng chứ không bán Ứng dụng cho bạn; mọi quyền không '` |
| `lib/features/settings/legal/terms_of_service.dart:138` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'được cấp rõ ràng trong Điều khoản này đều được bảo lưu.'` |
| `lib/features/settings/legal/terms_of_service.dart:141` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Các hành vi bị cấm'` |
| `lib/features/settings/legal/terms_of_service.dart:142` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Khi sử dụng Ứng dụng, bạn không được:'` |
| `lib/features/settings/legal/terms_of_service.dart:145` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Sao chép, sửa đổi, dịch ngược, giải mã, tháo rời, tạo tác phẩm phái '` |
| `lib/features/settings/legal/terms_of_service.dart:146` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'sinh hoặc cố gắng trích xuất mã nguồn của Ứng dụng, trừ khi pháp '` |
| `lib/features/settings/legal/terms_of_service.dart:147` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'luật bắt buộc cho phép.'` |
| `lib/features/settings/legal/terms_of_service.dart:150` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bán, cho thuê, cho mượn, phân phối lại, đăng tải lại hoặc khai thác '` |
| `lib/features/settings/legal/terms_of_service.dart:151` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thương mại Ứng dụng hay bất kỳ phần nào của Ứng dụng.'` |
| `lib/features/settings/legal/terms_of_service.dart:154` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dùng Ứng dụng, bot, script (đoạn mã tự chạy) hoặc công cụ tự động để '` |
| `lib/features/settings/legal/terms_of_service.dart:155` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'gian lận, can thiệp vào trò chơi, thu thập dữ liệu hàng loạt, spam '` |
| `lib/features/settings/legal/terms_of_service.dart:156` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hàng chờ, hoặc bất kỳ hành vi nào vi phạm chính sách của Riot Games.'` |
| `lib/features/settings/legal/terms_of_service.dart:159` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Truy cập hoặc cố truy cập tài khoản, dữ liệu, máy chủ hay hệ thống '` |
| `lib/features/settings/legal/terms_of_service.dart:160` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mà bạn không được phép; vượt qua giới hạn số lần gửi yêu cầu, cơ '` |
| `lib/features/settings/legal/terms_of_service.dart:161` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chế bảo mật hoặc kiểm duyệt của Ứng dụng và máy chủ Cộng đồng.'` |
| `lib/features/settings/legal/terms_of_service.dart:164` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mạo danh người khác, cung cấp thông tin sai lệch về danh tính hoặc '` |
| `lib/features/settings/legal/terms_of_service.dart:165` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot ID, hoặc sử dụng tài khoản của người khác khi chưa được phép.'` |
| `lib/features/settings/legal/terms_of_service.dart:168` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Phát tán mã độc, gây quá tải, làm gián đoạn hoặc làm suy giảm hoạt '` |
| `lib/features/settings/legal/terms_of_service.dart:169` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'động của Ứng dụng, máy chủ Cộng đồng hay dịch vụ của bên thứ ba.'` |
| `lib/features/settings/legal/terms_of_service.dart:172` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Sử dụng Ứng dụng cho mục đích trái pháp luật Việt Nam hoặc pháp luật '` |
| `lib/features/settings/legal/terms_of_service.dart:173` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nơi bạn cư trú.'` |
| `lib/features/settings/legal/terms_of_service.dart:177` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thao tác trên Tài khoản Riot'` |
| `lib/features/settings/legal/terms_of_service.dart:179` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Một số tính năng cho phép thay đổi trạng thái Tài khoản Riot của bạn, '` |
| `lib/features/settings/legal/terms_of_service.dart:180` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ví dụ: đổi trang bị, chọn hoặc khóa đặc vụ, tham gia hay rời tổ đội, '` |
| `lib/features/settings/legal/terms_of_service.dart:181` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bắt đầu hoặc hủy tìm trận, rời trận đấu.'` |
| `lib/features/settings/legal/terms_of_service.dart:185` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Các thao tác này chỉ được thực hiện khi chính bạn bấm nút tương ứng; '` |
| `lib/features/settings/legal/terms_of_service.dart:186` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng không tự động thực hiện thay bạn.'` |
| `lib/features/settings/legal/terms_of_service.dart:189` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Với thao tác có thể dẫn đến hình phạt trong trò chơi (ví dụ rời trận, '` |
| `lib/features/settings/legal/terms_of_service.dart:190` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'né trận), Ứng dụng sẽ hiển thị cảnh báo và yêu cầu bạn xác nhận.'` |
| `lib/features/settings/legal/terms_of_service.dart:193` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn hoàn toàn chịu trách nhiệm về hậu quả của các thao tác mình thực '` |
| `lib/features/settings/legal/terms_of_service.dart:194` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hiện, bao gồm hình phạt, mất điểm xếp hạng (RR), hạn chế hàng chờ '` |
| `lib/features/settings/legal/terms_of_service.dart:195` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hoặc biện pháp khác do Riot Games áp dụng.'` |
| `lib/features/settings/legal/terms_of_service.dart:199` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cộng đồng và nội dung người dùng'` |
| `lib/features/settings/legal/terms_of_service.dart:200` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Xác minh Riot ID'` |
| `lib/features/settings/legal/terms_of_service.dart:202` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Để dùng Cộng đồng, Ứng dụng xác minh Riot ID của bạn với Riot Games '` |
| `lib/features/settings/legal/terms_of_service.dart:203` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thông qua máy chủ Cộng đồng của ValVN, như mô tả trong Chính sách '` |
| `lib/features/settings/legal/terms_of_service.dart:204` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quyền riêng tư. Tên hiển thị của bạn trong Cộng đồng là Riot ID đã '` |
| `lib/features/settings/legal/terms_of_service.dart:205` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'được xác minh, kèm thẻ người chơi, rank và khu vực.'` |
| `lib/features/settings/legal/terms_of_service.dart:207` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Trách nhiệm với nội dung'` |
| `lib/features/settings/legal/terms_of_service.dart:210` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn chịu trách nhiệm về mọi Nội dung người dùng bạn đăng và cam kết '` |
| `lib/features/settings/legal/terms_of_service.dart:211` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'có đủ quyền đối với nội dung đó (ví dụ quyền sử dụng ảnh chụp màn '` |
| `lib/features/settings/legal/terms_of_service.dart:212` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hình, hình ảnh bạn tải lên).'` |
| `lib/features/settings/legal/terms_of_service.dart:215` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nội dung của bạn phải tuân thủ Tiêu chuẩn cộng đồng và pháp luật. '` |
| `lib/features/settings/legal/terms_of_service.dart:216` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nghiêm cấm nội dung vi phạm pháp luật áp dụng, xúc phạm, quấy rối, '` |
| `lib/features/settings/legal/terms_of_service.dart:217` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thù ghét, khiêu dâm, bạo lực, lừa đảo, spam, quảng cáo trái phép, '` |
| `lib/features/settings/legal/terms_of_service.dart:218` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mua bán tài khoản, dịch vụ cày thuê hoặc phần mềm gian lận, và nội '` |
| `lib/features/settings/legal/terms_of_service.dart:219` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dung tiết lộ thông tin cá nhân của người khác.'` |
| `lib/features/settings/legal/terms_of_service.dart:222` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bài tìm đồng đội có thể chứa mã tổ đội; bất kỳ ai xem bài đều có thể '` |
| `lib/features/settings/legal/terms_of_service.dart:223` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dùng mã đó để vào tổ đội của bạn cho đến khi bài hết hạn (30 phút) '` |
| `lib/features/settings/legal/terms_of_service.dart:224` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hoặc bạn tắt mã trong trò chơi.'` |
| `lib/features/settings/legal/terms_of_service.dart:227` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền bạn cấp cho chúng tôi'` |
| `lib/features/settings/legal/terms_of_service.dart:229` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn vẫn là chủ sở hữu Nội dung người dùng của mình. Khi đăng, bạn cấp '` |
| `lib/features/settings/legal/terms_of_service.dart:230` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cho chúng tôi quyền không độc quyền, miễn phí, có hiệu lực trên toàn '` |
| `lib/features/settings/legal/terms_of_service.dart:231` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thế giới. Quyền này cho phép chúng tôi lưu trữ, sao chép kỹ thuật, '` |
| `lib/features/settings/legal/terms_of_service.dart:232` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'định dạng lại (ví dụ nén hoặc đổi kích thước ảnh) và hiển thị nội '` |
| `lib/features/settings/legal/terms_of_service.dart:233` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dung đó cho người dùng khác trong Ứng dụng, chỉ nhằm mục đích vận '` |
| `lib/features/settings/legal/terms_of_service.dart:234` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hành Cộng đồng. Quyền này chấm dứt khi nội dung bị xóa khỏi hệ thống, '` |
| `lib/features/settings/legal/terms_of_service.dart:235` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trừ bản sao lưu còn tồn tại trong thời gian ngắn hoặc trường hợp pháp '` |
| `lib/features/settings/legal/terms_of_service.dart:236` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'luật yêu cầu lưu giữ.'` |
| `lib/features/settings/legal/terms_of_service.dart:238` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Báo cáo và kiểm duyệt'` |
| `lib/features/settings/legal/terms_of_service.dart:241` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn có thể báo cáo bài đăng, bình luận hoặc bài tìm đồng đội vi '` |
| `lib/features/settings/legal/terms_of_service.dart:242` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phạm ngay trong Ứng dụng. Nội dung nhận đủ số báo cáo từ nhiều '` |
| `lib/features/settings/legal/terms_of_service.dart:243` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'người dùng khác nhau có thể bị tự động ẩn trong khi chờ xem xét.'` |
| `lib/features/settings/legal/terms_of_service.dart:246` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi có quyền, nhưng không có nghĩa vụ, xem xét, ẩn, gỡ bỏ nội '` |
| `lib/features/settings/legal/terms_of_service.dart:247` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dung, hạn chế hoặc khóa quyền sử dụng Cộng đồng của bất kỳ ai vi '` |
| `lib/features/settings/legal/terms_of_service.dart:248` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phạm Điều khoản hoặc Tiêu chuẩn cộng đồng, có hoặc không cần báo '` |
| `lib/features/settings/legal/terms_of_service.dart:249` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trước.'` |
| `lib/features/settings/legal/terms_of_service.dart:252` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi không kiểm tra trước mọi nội dung và không chịu trách '` |
| `lib/features/settings/legal/terms_of_service.dart:253` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhiệm về Nội dung người dùng do người khác đăng. Quan điểm trong nội '` |
| `lib/features/settings/legal/terms_of_service.dart:254` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dung đó thuộc về người đăng.'` |
| `lib/features/settings/legal/terms_of_service.dart:257` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi có thể cung cấp thông tin cho cơ quan nhà nước có thẩm '` |
| `lib/features/settings/legal/terms_of_service.dart:258` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quyền khi có yêu cầu hợp pháp.'` |
| `lib/features/settings/legal/terms_of_service.dart:262` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Quyền sở hữu trí tuệ'` |
| `lib/features/settings/legal/terms_of_service.dart:264` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng, bao gồm mã nguồn, thiết kế giao diện, biểu tượng, tên và '` |
| `lib/features/settings/legal/terms_of_service.dart:265` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'logo ValVN, văn bản và các tài liệu đi kèm, thuộc quyền sở hữu của '` |
| `lib/features/settings/legal/terms_of_service.dart:266` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'$_publisher và được bảo hộ theo pháp luật về sở hữu trí tuệ.'` |
| `lib/features/settings/legal/terms_of_service.dart:269` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'VALORANT, Riot Games cùng tên, hình ảnh, biểu tượng và nội dung trong '` |
| `lib/features/settings/legal/terms_of_service.dart:270` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trò chơi (skin, đặc vụ, bản đồ, rank…) thuộc quyền sở hữu của Riot '` |
| `lib/features/settings/legal/terms_of_service.dart:271` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Games, Inc. và được hiển thị trong Ứng dụng chỉ nhằm mục đích tham '` |
| `lib/features/settings/legal/terms_of_service.dart:272` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chiếu cho người chơi. Việc hiển thị này không chuyển giao cho bạn hay '` |
| `lib/features/settings/legal/terms_of_service.dart:273` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cho chúng tôi bất kỳ quyền nào đối với các tài sản đó.'` |
| `lib/features/settings/legal/terms_of_service.dart:276` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Dịch vụ của bên thứ ba'` |
| `lib/features/settings/legal/terms_of_service.dart:277` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng hoạt động dựa trên các dịch vụ bên thứ ba sau:'` |
| `lib/features/settings/legal/terms_of_service.dart:280` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đăng nhập, dữ liệu tài khoản, cửa hàng, bộ sưu tập, trận đấu, bạn bè '` |
| `lib/features/settings/legal/terms_of_service.dart:281` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và trò chuyện được lấy trực tiếp từ máy chủ của Riot Games.'` |
| `lib/features/settings/legal/terms_of_service.dart:282` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Riot Games:'` |
| `lib/features/settings/legal/terms_of_service.dart:285` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tên, hình ảnh và dữ liệu công khai của vật phẩm, đặc vụ, bản đồ, '` |
| `lib/features/settings/legal/terms_of_service.dart:286` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'rank do một dự án cộng đồng độc lập cung cấp.'` |
| `lib/features/settings/legal/terms_of_service.dart:287` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'valorant-api.com:'` |
| `lib/features/settings/legal/terms_of_service.dart:290` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mạng chuyển tiếp kết nối tới máy chủ Cộng đồng do chúng tôi tự vận '` |
| `lib/features/settings/legal/terms_of_service.dart:291` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hành.'` |
| `lib/features/settings/legal/terms_of_service.dart:292` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cloudflare:'` |
| `lib/features/settings/legal/terms_of_service.dart:295` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phân phối Ứng dụng và cập nhật.'` |
| `lib/features/settings/legal/terms_of_service.dart:296` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'App Store và Google Play:'` |
| `lib/features/settings/legal/terms_of_service.dart:300` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Các dịch vụ này có điều khoản và chính sách riêng mà bạn cần tuân thủ. '` |
| `lib/features/settings/legal/terms_of_service.dart:301` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi không kiểm soát và không chịu trách nhiệm về tính sẵn sàng, '` |
| `lib/features/settings/legal/terms_of_service.dart:302` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'độ chính xác hay thay đổi của các dịch vụ đó. Nếu Riot Games thay đổi '` |
| `lib/features/settings/legal/terms_of_service.dart:303` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hoặc ngừng cung cấp cách kết nối kỹ thuật mà Ứng dụng dùng để làm '` |
| `lib/features/settings/legal/terms_of_service.dart:304` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'việc với Riot, một số tính năng có thể tạm thời hoặc vĩnh viễn không '` |
| `lib/features/settings/legal/terms_of_service.dart:305` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hoạt động.'` |
| `lib/features/settings/legal/terms_of_service.dart:308` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Không phải sản phẩm chính thức của Riot Games'` |
| `lib/features/settings/legal/terms_of_service.dart:310` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ValVN là ứng dụng độc lập, không được Riot Games xác nhận, tài trợ, '` |
| `lib/features/settings/legal/terms_of_service.dart:311` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'giám sát hay liên kết dưới bất kỳ hình thức nào, và không phản ánh '` |
| `lib/features/settings/legal/terms_of_service.dart:312` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quan điểm của Riot Games hay bất kỳ ai tham gia sản xuất hoặc quản lý '` |
| `lib/features/settings/legal/terms_of_service.dart:313` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'các sản phẩm của Riot Games. Riot Games không chịu trách nhiệm hỗ trợ '` |
| `lib/features/settings/legal/terms_of_service.dart:314` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'cho Ứng dụng; vui lòng liên hệ chúng tôi thay vì Riot Games khi có vấn '` |
| `lib/features/settings/legal/terms_of_service.dart:315` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đề với ValVN.'` |
| `lib/features/settings/legal/terms_of_service.dart:318` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Miễn trừ bảo đảm'` |
| `lib/features/settings/legal/terms_of_service.dart:320` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Trong phạm vi tối đa pháp luật cho phép, Ứng dụng được cung cấp "nguyên '` |
| `lib/features/settings/legal/terms_of_service.dart:321` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trạng" và "theo khả năng sẵn có", không kèm bất kỳ bảo đảm nào, dù rõ '` |
| `lib/features/settings/legal/terms_of_service.dart:322` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ràng hay ngụ ý, bao gồm bảo đảm về khả năng thương mại, sự phù hợp cho '` |
| `lib/features/settings/legal/terms_of_service.dart:323` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'một mục đích cụ thể, tính chính xác hoặc không vi phạm.'` |
| `lib/features/settings/legal/terms_of_service.dart:326` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi không bảo đảm Ứng dụng hoạt động liên tục, không có lỗi, '` |
| `lib/features/settings/legal/terms_of_service.dart:327` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tương thích với mọi thiết bị, hay dữ liệu hiển thị (giá, cửa hàng, '` |
| `lib/features/settings/legal/terms_of_service.dart:328` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thống kê, thời gian làm mới, thông báo) luôn đầy đủ, chính xác và kịp '` |
| `lib/features/settings/legal/terms_of_service.dart:329` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thời. Thông báo cửa hàng và wishlist phụ thuộc vào hệ điều hành và có '` |
| `lib/features/settings/legal/terms_of_service.dart:330` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'thể đến muộn hoặc không đến.'` |
| `lib/features/settings/legal/terms_of_service.dart:333` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Giới hạn trách nhiệm'` |
| `lib/features/settings/legal/terms_of_service.dart:335` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Trong phạm vi tối đa pháp luật cho phép, chúng tôi không chịu trách '` |
| `lib/features/settings/legal/terms_of_service.dart:336` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhiệm đối với bất kỳ thiệt hại gián tiếp, ngẫu nhiên, đặc biệt hay hệ '` |
| `lib/features/settings/legal/terms_of_service.dart:337` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quả nào, bao gồm mất dữ liệu, mất vật phẩm hay tiền ảo trong trò chơi, '` |
| `lib/features/settings/legal/terms_of_service.dart:338` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'mất điểm xếp hạng, hình phạt hoặc việc Tài khoản Riot bị hạn chế hay '` |
| `lib/features/settings/legal/terms_of_service.dart:339` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khóa, phát sinh từ hoặc liên quan đến việc bạn sử dụng hay không thể '` |
| `lib/features/settings/legal/terms_of_service.dart:340` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'sử dụng Ứng dụng.'` |
| `lib/features/settings/legal/terms_of_service.dart:343` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Vì Ứng dụng được cung cấp miễn phí, tổng trách nhiệm của chúng tôi đối '` |
| `lib/features/settings/legal/terms_of_service.dart:344` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'với mọi khiếu nại liên quan đến Ứng dụng, trong phạm vi pháp luật cho '` |
| `lib/features/settings/legal/terms_of_service.dart:345` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'phép, không vượt quá số tiền bạn đã trả trực tiếp cho chúng tôi để sử '` |
| `lib/features/settings/legal/terms_of_service.dart:346` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dụng Ứng dụng trong 12 tháng trước sự kiện phát sinh khiếu nại (nếu '` |
| `lib/features/settings/legal/terms_of_service.dart:347` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'có). Điều khoản này không loại trừ trách nhiệm mà pháp luật áp dụng '` |
| `lib/features/settings/legal/terms_of_service.dart:348` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'không cho phép loại trừ, bao gồm quyền của người tiêu dùng theo pháp '` |
| `lib/features/settings/legal/terms_of_service.dart:349` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'luật Việt Nam hoặc pháp luật nơi bạn cư trú.'` |
| `lib/features/settings/legal/terms_of_service.dart:352` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Trách nhiệm bồi hoàn'` |
| `lib/features/settings/legal/terms_of_service.dart:354` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn đồng ý bồi hoàn và bảo vệ chúng tôi khỏi các khiếu nại, thiệt hại '` |
| `lib/features/settings/legal/terms_of_service.dart:355` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'và chi phí hợp lý (bao gồm phí luật sư) phát sinh từ việc bạn vi phạm '` |
| `lib/features/settings/legal/terms_of_service.dart:356` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Điều khoản này, vi phạm quyền của bên thứ ba hoặc từ Nội dung người '` |
| `lib/features/settings/legal/terms_of_service.dart:357` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'dùng mà bạn đăng tải.'` |
| `lib/features/settings/legal/terms_of_service.dart:360` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Tạm ngừng và chấm dứt'` |
| `lib/features/settings/legal/terms_of_service.dart:363` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn có thể ngừng sử dụng bất cứ lúc nào bằng cách đăng xuất và gỡ '` |
| `lib/features/settings/legal/terms_of_service.dart:364` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Ứng dụng. Cách xóa dữ liệu Cộng đồng trên máy chủ được hướng dẫn '` |
| `lib/features/settings/legal/terms_of_service.dart:365` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'trong Chính sách quyền riêng tư.'` |
| `lib/features/settings/legal/terms_of_service.dart:368` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi có thể tạm ngừng hoặc chấm dứt quyền sử dụng Ứng dụng hay '` |
| `lib/features/settings/legal/terms_of_service.dart:369` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Cộng đồng của bạn nếu bạn vi phạm Điều khoản, theo yêu cầu của cơ '` |
| `lib/features/settings/legal/terms_of_service.dart:370` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'quan có thẩm quyền, hoặc để bảo vệ người dùng khác và hệ thống.'` |
| `lib/features/settings/legal/terms_of_service.dart:373` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi có thể thay đổi, tạm ngừng hoặc ngừng cung cấp toàn bộ '` |
| `lib/features/settings/legal/terms_of_service.dart:374` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hay một phần Ứng dụng, và sẽ cố gắng thông báo trước trong Ứng dụng '` |
| `lib/features/settings/legal/terms_of_service.dart:375` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khi hợp lý.'` |
| `lib/features/settings/legal/terms_of_service.dart:378` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Khi chấm dứt, quyền sử dụng được cấp cho bạn chấm dứt ngay; các điều '` |
| `lib/features/settings/legal/terms_of_service.dart:379` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khoản về sở hữu trí tuệ, miễn trừ bảo đảm, giới hạn trách nhiệm, bồi '` |
| `lib/features/settings/legal/terms_of_service.dart:380` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hoàn và giải quyết tranh chấp vẫn còn hiệu lực.'` |
| `lib/features/settings/legal/terms_of_service.dart:384` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Thay đổi Điều khoản'` |
| `lib/features/settings/legal/terms_of_service.dart:386` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Chúng tôi có thể cập nhật Điều khoản theo thời gian. Phiên bản và ngày '` |
| `lib/features/settings/legal/terms_of_service.dart:387` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hiệu lực luôn được ghi ở đầu văn bản. Với thay đổi quan trọng, chúng '` |
| `lib/features/settings/legal/terms_of_service.dart:388` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'tôi sẽ thông báo trong Ứng dụng trước khi thay đổi có hiệu lực. Việc '` |
| `lib/features/settings/legal/terms_of_service.dart:389` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bạn tiếp tục sử dụng Ứng dụng sau ngày hiệu lực đồng nghĩa với việc '` |
| `lib/features/settings/legal/terms_of_service.dart:390` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'bạn chấp nhận Điều khoản đã cập nhật.'` |
| `lib/features/settings/legal/terms_of_service.dart:393` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Luật áp dụng và giải quyết tranh chấp'` |
| `lib/features/settings/legal/terms_of_service.dart:395` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Điều khoản này được điều chỉnh và giải thích theo pháp luật nước Cộng '` |
| `lib/features/settings/legal/terms_of_service.dart:396` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'hòa xã hội chủ nghĩa Việt Nam.'` |
| `lib/features/settings/legal/terms_of_service.dart:399` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mọi tranh chấp phát sinh trước hết được giải quyết thông qua thương '` |
| `lib/features/settings/legal/terms_of_service.dart:400` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lượng, hòa giải thiện chí. Bạn vui lòng liên hệ chúng tôi qua email '` |
| `lib/features/settings/legal/terms_of_service.dart:401` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'để cùng giải quyết. Nếu không thể giải quyết trong vòng 30 ngày kể từ '` |
| `lib/features/settings/legal/terms_of_service.dart:402` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'ngày một bên thông báo tranh chấp, tranh chấp sẽ được đưa ra Tòa án '` |
| `lib/features/settings/legal/terms_of_service.dart:403` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nhân dân có thẩm quyền tại Việt Nam, trừ khi pháp luật về bảo vệ quyền '` |
| `lib/features/settings/legal/terms_of_service.dart:404` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'lợi người tiêu dùng ở nơi bạn cư trú cho phép bạn lựa chọn cơ chế '` |
| `lib/features/settings/legal/terms_of_service.dart:405` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khác. Điều khoản này không làm mất các quyền bắt buộc mà pháp luật '` |
| `lib/features/settings/legal/terms_of_service.dart:406` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'nơi bạn sống dành cho người tiêu dùng và người dùng dịch vụ.'` |
| `lib/features/settings/legal/terms_of_service.dart:409` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Điều khoản chung'` |
| `lib/features/settings/legal/terms_of_service.dart:412` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nếu một điều khoản bị cơ quan có thẩm quyền tuyên vô hiệu, các điều '` |
| `lib/features/settings/legal/terms_of_service.dart:413` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khoản còn lại vẫn giữ nguyên hiệu lực.'` |
| `lib/features/settings/legal/terms_of_service.dart:416` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Việc chúng tôi chưa thực thi một quyền không có nghĩa là từ bỏ quyền '` |
| `lib/features/settings/legal/terms_of_service.dart:417` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'đó.'` |
| `lib/features/settings/legal/terms_of_service.dart:420` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Bạn không được chuyển giao quyền và nghĩa vụ theo Điều khoản này khi '` |
| `lib/features/settings/legal/terms_of_service.dart:421` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'chưa có sự đồng ý bằng văn bản của chúng tôi.'` |
| `lib/features/settings/legal/terms_of_service.dart:424` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Điều khoản được lập bằng tiếng Việt. Nếu có bản dịch sang ngôn ngữ '` |
| `lib/features/settings/legal/terms_of_service.dart:425` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'khác và có mâu thuẫn, bản tiếng Việt được ưu tiên áp dụng.'` |
| `lib/features/settings/legal/terms_of_service.dart:429` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Liên hệ'` |
| `lib/features/settings/legal/terms_of_service.dart:431` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Mọi câu hỏi, góp ý hoặc khiếu nại về Điều khoản này, vui lòng liên hệ:'` |
| `lib/features/settings/legal/terms_of_service.dart:434` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Nhà phát hành:'` |
| `lib/features/settings/legal/terms_of_service.dart:435` | Pháp lý/siêu dữ liệu — đã đọc, giữ dữ kiện | `'Email:'` |

## Lời hiển thị ngoài file chuỗi

Kiểm tra bổ sung: toàn bộ `lib/core/l10n/**`, ARB và mã sinh W0, widget/semantics/tooltip, thông báo và chữ chia sẻ. Danh sách dưới giữ mọi literal có dấu tiếng Việt ngoài file chuỗi/pháp lý (gồm cả lỗi nội bộ và mẫu ngày để reviewer phân biệt); không suy diễn mọi literal thành chữ người chơi thấy. Các lỗi nội bộ đi qua `describeError`/`describeCommunityError`.

| File:dòng | Phân loại | Literal nguồn |
|---|---|---|
| `lib/core/l10n/app_locale.dart:66` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'Español (España)'` |
| `lib/core/l10n/app_locale.dart:78` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'Español (Latinoamérica)'` |
| `lib/core/l10n/app_locale.dart:89` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'Français'` |
| `lib/core/l10n/app_locale.dart:158` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'Português (Brasil)'` |
| `lib/core/l10n/app_locale.dart:193` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'Türkçe'` |
| `lib/core/l10n/app_locale.dart:205` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'Tiếng Việt'` |
| `lib/core/l10n/formats.dart:198` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'İ'` |
| `lib/core/l10n/formats.dart:199` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ß'` |
| `lib/core/l10n/formats.dart:203` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'İ'` |
| `lib/core/l10n/formats.dart:203` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ı'` |
| `lib/core/util/search_fold_table.dart:38` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'þ'` |
| `lib/core/util/search_fold_table.dart:108` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ħ'` |
| `lib/core/util/search_fold_table.dart:119` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ĳ'` |
| `lib/core/util/search_fold_table.dart:130` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ŀ'` |
| `lib/core/util/search_fold_table.dart:139` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ŋ'` |
| `lib/core/util/search_fold_table.dart:166` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ŧ'` |
| `lib/core/util/search_fold_table.dart:191` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƃ'` |
| `lib/core/util/search_fold_table.dart:192` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƅ'` |
| `lib/core/util/search_fold_table.dart:194` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƈ'` |
| `lib/core/util/search_fold_table.dart:197` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƌ'` |
| `lib/core/util/search_fold_table.dart:198` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǝ'` |
| `lib/core/util/search_fold_table.dart:201` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƒ'` |
| `lib/core/util/search_fold_table.dart:206` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƙ'` |
| `lib/core/util/search_fold_table.dart:212` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƣ'` |
| `lib/core/util/search_fold_table.dart:213` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƥ'` |
| `lib/core/util/search_fold_table.dart:215` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƨ'` |
| `lib/core/util/search_fold_table.dart:217` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƭ'` |
| `lib/core/util/search_fold_table.dart:223` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƴ'` |
| `lib/core/util/search_fold_table.dart:224` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƶ'` |
| `lib/core/util/search_fold_table.dart:226` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƹ'` |
| `lib/core/util/search_fold_table.dart:227` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƽ'` |
| `lib/core/util/search_fold_table.dart:228` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǆ'` |
| `lib/core/util/search_fold_table.dart:229` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǆ'` |
| `lib/core/util/search_fold_table.dart:230` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǉ'` |
| `lib/core/util/search_fold_table.dart:231` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǉ'` |
| `lib/core/util/search_fold_table.dart:232` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǌ'` |
| `lib/core/util/search_fold_table.dart:233` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǌ'` |
| `lib/core/util/search_fold_table.dart:256` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǥ'` |
| `lib/core/util/search_fold_table.dart:268` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǳ'` |
| `lib/core/util/search_fold_table.dart:269` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ǳ'` |
| `lib/core/util/search_fold_table.dart:272` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƕ'` |
| `lib/core/util/search_fold_table.dart:273` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƿ'` |
| `lib/core/util/search_fold_table.dart:310` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ȝ'` |
| `lib/core/util/search_fold_table.dart:313` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƞ'` |
| `lib/core/util/search_fold_table.dart:314` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ȣ'` |
| `lib/core/util/search_fold_table.dart:315` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ȥ'` |
| `lib/core/util/search_fold_table.dart:331` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ȼ'` |
| `lib/core/util/search_fold_table.dart:332` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƚ'` |
| `lib/core/util/search_fold_table.dart:334` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ɂ'` |
| `lib/core/util/search_fold_table.dart:335` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ƀ'` |
| `lib/core/util/search_fold_table.dart:338` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ɇ'` |
| `lib/core/util/search_fold_table.dart:339` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ɉ'` |
| `lib/core/util/search_fold_table.dart:340` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ɋ'` |
| `lib/core/util/search_fold_table.dart:341` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ɍ'` |
| `lib/core/util/search_fold_table.dart:342` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ɏ'` |
| `lib/core/util/search_fold_table.dart:727` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ſ'` |
| `lib/core/util/search_fold_table.dart:819` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ỻ'` |
| `lib/core/util/search_fold_table.dart:820` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ỽ'` |
| `lib/core/util/search_fold_table.dart:821` | Rà nơi gọi; nội bộ/định dạng/nội dung game | `'ỿ'` |

## iOS và W0

- `ios/Runner/Info.plist:66`: <string>Chọn ảnh từ thư viện để đính kèm vào bài đăng của bạn trên Cộng đồng ValVN. ValVN chỉ dùng những ảnh bạn chọn.</string>
- `lib/l10n/arb/app_vi.arb:3`: "smokePlain": "Kiểm tra sinh mã",
- `lib/l10n/arb/app_vi.arb:8`: "smokeGreeting": "Xin chào, {name}!",
- `lib/l10n/arb/app_vi.arb:17`: "x-example": "Xin chào, Nguyễn Văn A!"
- `lib/l10n/arb/app_vi.arb:19`: "smokeCount": "{n, plural, other{{n} mục}}",
- `lib/l10n/arb/app_vi.arb:28`: "x-example": "5 mục"
