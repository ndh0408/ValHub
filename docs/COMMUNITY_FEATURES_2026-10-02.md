# Cộng đồng — bố cục, trạng thái trống và chia sẻ bài, 02/10/2026

Tiếp tục sau tài nguyên dùng chung `04e6288`, theo phản hồi bố cục và câu hỏi đăng bài/thích/share. Đây là checkpoint, **không phải nghiệm thu toàn bộ dự án**; xem [COMPLETION_STATUS.md](COMPLETION_STATUS.md).

## Chức năng và thay đổi

- Đăng bài chữ/ảnh, thích/bỏ thích, bình luận và khoe cửa hàng/Chợ Đêm đã có; full suite chạy lại các luồng này. Việc ghi vẫn yêu cầu tham gia trước; từ chối không gửi bài/like/comment. Không tự đăng bài thật trên tài khoản của chủ dự án trong đợt này.
- Thêm nút **Chia sẻ** vào PostCard dùng ở cả Bảng tin và màn chi tiết. Chia sẻ native gửi tiêu đề tác giả công khai, đoạn xem trước tối đa 160 grapheme và link bài; không gửi Riot token, account selector hay dữ liệu đăng nhập. Có khóa bấm liên tục, báo lỗi/thử lại và origin cho popover iPad. Thanh like/comment/share có thể xuống dòng khi chữ lớn. Icon phù hợp Android/iOS.
- Link hiện tại là `valvn://post/<id>`; kiểm tra parse mở đúng `/post/<id>` và không chuyển tài khoản. Người nhận cần VanHub đã cài. **HTTPS App/Universal Links và trang cho người chưa cài vẫn chưa hoàn thành**; không giả định đã có domain association.
- Thanh người chưa tham gia rút còn trạng thái ngắn và nút Tham gia; chuyển xuống dòng ở cửa sổ hẹp/chữ lớn. Bỏ đoạn giải thích quyền riêng tư lặp lại ở cuối bảng tin; sheet xác nhận tham gia và liên kết pháp lý giữ nguyên.
- Trạng thái trống phân biệt scope server thực sự áp dụng, người đã/chưa tham gia và bộ lọc ngôn ngữ thực sự gửi trong request. Scope quốc tế không gợi chọn Quốc tế lần nữa. Language filter còn nhớ nhưng không được gửi trong request country không tạo lời gợi sai.
- Nút Đăng bài dùng đỏ đậm như filled button, test contrast với chữ trắng đạt ngưỡng 4,5:1. Resources/manifest/parity được tái sinh cho lời mới; versionCode **4003**.

## Kiểm tra

| Kiểm tra | Kết quả |
|---|---|
| Toàn bộ Flutter tests trên source cuối | **4.195 passed**, `.vanhub-community-all-tests-final.log` |
| Analyzer | **0 issues**, `.vanhub-community-analyze.log` |
| Native share integration, Android API 35 / emulator 5582 | **1 passed**: production share provider mở chooser thật, controller xác nhận bài tổng hợp, Back hủy rồi nút dùng lại được; không chọn ứng dụng đích/gửi nội dung |
| Native share bằng chứng | `dist/review/emulator/vanhub-post-share-native/{chooser.png,chooser.xml,results.json}` |
| ARB validator | **0 errors / 0 warnings** |
| Extract/parity check | Byte-stable; **1.612 members / 1.754 messages / 52 structural members còn lại** |
| Global verify | **1.762 production references / 762 Vietnamese literals**, analyzer errors rỗng, cutover **chưa đạt**; giảm 5 references so với checkpoint dùng chung |
| APK release cuối | Build code **4003** đạt, chữ ký **Android Debug** xác minh đạt |
| Public-flow trên APK cuối / emulator 5582 | **10 cases passed**, không có fatal/unhandled exception trong logcat của lượt chạy |
| Emulator có cửa sổ 5580 | `install -r` đạt; Settings/switcher đủ metadata hai tài khoản hiện có; thanh tab không che switcher; Cộng đồng có banner ngắn và lời trống đúng scope country/region đang xem; không đổi tài khoản/consent hoặc đăng bài |
| Whitespace | `git diff --check` đạt |

APK: `dist/review/VanHub-community-features-20261002.apk`. SHA-256: **`B1CE1C1AD400EBC14E7D55B427C40A27B6E607D6494C48C625F25A9FD9F8254A`**. APK này ký debug để kiểm tra; chưa upload store/deploy production. Public results ở `dist/review/emulator/vanhub-community-release-smoke/results.json`; ảnh/XML tài khoản thật ở `dist/review/private-account-ui/community-features`, chỉ giữ cục bộ.

## Giới hạn còn lại

Tests đăng/thích/bình luận dùng API fixture; native sharing dùng bài tổng hợp riêng. Chưa xác nhận thao tác ghi trên server production hay hai thiết bị thật; không đưa bài giả vào bản phát hành. Native iOS chưa chạy trên Mac. Chỉ UI Việt đang ship; quốc tế hóa, moderation 18 ngôn ngữ, Community unread/activity, domain links và các mục tổng thể còn mở. Backend không đổi implementation trong phase này; 867 backend tests là checkpoint trước, không phải chạy lại hôm nay.

Hook đã có bridge ngoài thư mục tạm và shortcut launcher, xem [WINDOWS_HOOK_FIX_2026-10-02.md](WINDOWS_HOOK_FIX_2026-10-02.md); vẫn cần xác nhận khi đóng/mở Orca thật.
