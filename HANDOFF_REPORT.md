# Bàn giao WP-COPY

Ngày 30/09/2026 · nhánh `ndh0408/codex-wp-copy` · người thực hiện: Codex.

Đã merge `claude/jolly-hawking-23o2j8` bằng `9e46bfe`, không xung đột. Đã đọc gói bàn giao, quy ước, audit và lịch sử; tiếp tục từ `8880595` và WIP `8ac79f3`. Hoàn tất kiểm kê, hướng dẫn giọng văn và phần sửa client thuộc WP-COPY. Không push, không merge vào nhánh chính, không deploy, không dùng emulator/adb/thiết bị thật. Không sửa `server/**`, `lib/main.dart`, `lib/app/app.dart` ngoài nội dung có sẵn do merge nền tảng.

## Từng phát hiện

Chi tiết và dẫn chiếu nguồn ở [AUDIT_COPY.md](docs/audit/AUDIT_COPY.md), [COPY_INVENTORY.md](docs/audit/COPY_INVENTORY.md) và [COPY_SERVER_MESSAGES.md](docs/audit/COPY_SERVER_MESSAGES.md). Kiểm kê gồm 2.917 literal nguồn (bao gồm khóa nội bộ, placeholder và siêu dữ liệu), 20 file chuỗi cũ + 1 lớp lời lỗi mới, cây pháp lý, phần iOS/W0 và chuỗi ngoài file chuỗi.

| Phát hiện | Trạng thái | Việc đã làm / lý do phần còn lại |
|---|---|---|
| CP-01 — console/nhật ký | Xong | Giữ việc bỏ màn hình từ WIP; route `/settings/log` chuyển về Cài đặt, có widget test. |
| CP-02 — nhóm Nâng cao | Xong | Chỉ có Gửi báo lỗi cho ValVN và Xóa dữ liệu tạm; báo lỗi dùng bảng chia sẻ, bản dựng chỉ hiện ở Giới thiệu. |
| CP-03 — lỗi máy chủ nguyên văn, GL-15 | Xong phía client / một phần tổng thể | Không hiện `serverMessage`, `messageEn`, JSON, tên trường hay params. Ánh xạ reason kiểm duyệt/hạn chế, giữ nút thử lại cho 503. Các reason máy chủ còn thiếu được liệt kê file:dòng để Claude/WP-SRV bổ sung. |
| CP-04 — lỗi UI kỹ thuật | Xong trong các màn hiện có | Dùng mẫu thân thiện; giữ mã/trường lỗi trong exception nội bộ. Bộ bắt lỗi chung là CP-13. |
| CP-05 — token/cache/session/shard/URL | Xong phần lời | Dùng đăng nhập, dữ liệu tạm, báo lỗi, cập nhật và tên máy chủ đầy đủ; fallback máy chủ/nền tảng không lộ mã lạ. Nguồn bảng giá có nhãn dễ đọc và liên kết thật. |
| CP-06 — văn dịch máy | Xong | Sửa cột mốc, loại phần thưởng, lời KAST và lỗi phụ kiện; không đoán nguyên nhân chưa biết. |
| CP-07 — lời không nhất quán | Xong | Skin được yêu thích, Bỏ lọc, Điền tài khoản đã lưu; lỗi và trạng thái trống nêu việc tiếp theo. |
| CP-08 — thuật ngữ VALORANT | Xong rà | Đối chiếu bảng thuật ngữ §8; giữ tên nội dung game. Tên mới chưa xác minh được ghi trong VOICE để review bằng client thật. |
| CP-09 — báo lỗi/GL-37 | Xong ở ranh giới chia sẻ | Lọc lại nội dung trước xuất, gồm Riot ID Unicode/mật khẩu; tên tệp trung lập, có test che dữ liệu. Chờ phiên bản thật khi bấm gửi, vẫn gửi được khi không lấy được phiên bản. Bộ ghi log chung thuộc WP-CORE. |
| CP-10 — pháp lý/CS-09 | Xong phần lời | Kế thừa bản viết lại dễ đọc, giữ quyền/nghĩa vụ/số ngày/liên hệ/miễn trừ; hộp đồng ý không hứa PUUID luôn ở lại máy hoặc chỉ xác minh một lần suốt đời, có cách rút lại. |
| CP-11 — Google ML Kit, CS-10/AR-033/PR-30 | Xong theo D1 | Giữ dịch miễn phí trên thiết bị; thông báo rõ tải gói từ Google sau khi hỏi, bài viết không gửi tới Google để dịch. Bổ sung trong app và Markdown, không khẳng định về telemetry chưa kiểm chứng. |
| CP-12 — định vị app/thời gian/chia sẻ, GL-21/26/27 | Xong phần copy | Không tự gọi app chỉ dành cho Việt Nam hoặc hứa đã dịch 18 ngôn ngữ; giờ theo thiết bị; quyền ảnh rõ phạm vi; tên tệp ASCII trung lập. Scheduler và các bản dịch ARB thuộc gói sau. |
| CP-13 — khung lỗi khi chạy thật | Bỏ qua sửa, đã bàn giao | Theo ranh giới WP-COPY không sửa main/app. Yêu cầu cụ thể bên dưới và VOICE §9. |
| CP-14 — tên quốc gia/viết tắt, GL-29/35 | Một phần | Đã kiểm kê; CLDR/ARB thuộc COUNTRIES/I18N. Giữ fallback ISO/T2/CN/T-B-H hiện có để không bịa tên hay đổi cơ chế trước cutover. |
| CP-15 — số liệu và xóa dữ liệu, PR-04/08, AR-002/003/014/016/018 | Bỏ qua thay hành vi | WP-DOMAIN/WP-CORE sở hữu phép tính, lịch sử và xóa/giữ dữ liệu. Claude cần nối lại lời pháp lý/cài đặt sau khi gộp các gói đó. |
| CP-16 — test literal/hợp đồng chuỗi W0 | Xong | Cập nhật literal cũ; thêm test privacy/lỗi có reason. Khôi phục 15 member SettingsStrings bị WIP xóa bằng lời thân thiện, không phục hồi màn console. Đăng ký namespace mới communityError và kiểm thử codemod. |

## File chính

- [VOICE.md](docs/design/VOICE.md): giọng đồng đội, thuật ngữ, bảng thay thế, mẫu lỗi/trống/đồng ý/thông báo, quy tắc placeholder/số nhiều và phụ lục điểm nối.
- `lib/core/l10n/*_strings.dart`, `lib/features/*/*_strings.dart`: chỉ sửa giá trị chuỗi; giữ tên/chữ ký member hiện có, kể cả 15 member cũ được khôi phục.
- [community_exception.dart](lib/features/community/data/community_exception.dart), [community_error_strings.dart](lib/core/l10n/community_error_strings.dart): reason và lời lỗi trong app, không render phản hồi thô.
- [bug_report.dart](lib/features/settings/data/bug_report.dart), [app_info_sections.dart](lib/features/settings/ui/sections/app_info_sections.dart): lọc tệp ở ranh giới chia sẻ, lấy phiên bản đúng, giữ hành động xóa dữ liệu tạm.
- [privacy_policy.dart](lib/features/settings/legal/privacy_policy.dart), [privacy.md](docs/legal/privacy.md): công bố Google theo D1. Bản Markdown được sinh lại bằng công cụ hiện có, test parity xanh.
- `test/features/{community,settings,home,live_game,store,wishlist}/**`, `test/l10n/l10n_fmt_test.dart`, `tool/l10n_codemod/**`, `tool/l10n_fmt.dart`: test hành vi/copy và đăng ký namespace mới. Không thêm phụ thuộc.

## Rủi ro và điểm nối cho Claude

1. **Khung lỗi thân thiện khi chạy thật:** đặt `ErrorWidget.builder` cho release, icon + lời thân thiện + semantics, không `exceptionAsString`/stack trace/ID. `FlutterError.onError` và `PlatformDispatcher.instance.onError` chỉ ghi nội bộ loại lỗi đã lọc; debug giữ hỗ trợ chẩn đoán. WP-COPY chỉ ghi yêu cầu, chưa triển khai.
2. **Máy chủ cũ/validation thiếu reason:** hiện chỉ thấy câu dự phòng thay vì nguyên văn hạn mức ảnh. Bổ sung reason ổn định trong các vị trí ở COPY_SERVER_MESSAGES, rồi ánh xạ lời tương ứng; tuyệt đối không mở lại fallback `serverMessage`.
3. **Thông báo màn hình khóa:** nội dung vẫn có tên tài khoản để phân biệt nhiều tài khoản; WP-CORE cần bản công khai không lộ Riot ID. Không thay placeholder tên tài khoản trong gói này.
4. **Sau khi gộp CORE/DOMAIN:** lời xác nhận đăng xuất, giữ/xóa dữ liệu cục bộ, lịch sử RR/cửa hàng và số skin mua cùng lúc phải khớp hành vi mới. Bản này không tự sửa các sự kiện pháp lý chưa được triển khai trên nhánh.
5. **QA trực quan:** chưa chạy trên thiết bị; Claude kiểm tra nhãn Điền tài khoản đã lưu, tên máy chủ dài, phần Nâng cao, iPad share origin và nội dung tiếng Việt mới. Test hiện có đã chạy cả bố cục pháp lý ở 360dp với cỡ chữ 2.0.
6. **Ngoại lệ placeholder:** `errorApi(int status)` (WIP trước) và `priceSource(String url)` giữ chữ ký nhưng không hiện status/URL để tránh lộ kỹ thuật. Riot ID/mã tổ đội/nội dung game/nguồn ghi công/trang Riot chính thức được giữ đúng ngữ cảnh. Mỗi dòng báo lỗi xuất có thể bị rút gọn ở 200 ký tự theo bộ lọc nội bộ.

## Kiểm tra

Chạy qua PowerShell với `$env:Path="D:\Dev\Flutter\3.47.5\flutter\bin;$env:Path"`.

| Lệnh | Kết quả |
|---|---|
| `flutter pub get` | Thành công, không đổi phụ thuộc/lockfile |
| `dart format lib test tool` | Đã format |
| `dart format --output=none --set-exit-if-changed lib test tool` | 620 file, 0 file thay đổi |
| `flutter analyze --no-pub` | 0 vấn đề |
| `flutter test --no-pub --concurrency=4 --reporter expanded` | Toàn bộ 2.007 test xanh, 0 lỗi (lượt cuối 1 phút 56 giây) |
| `dart test --reporter expanded` tại `tool/l10n_codemod` | 23 test xanh, 0 lỗi |
| `dart run tool/export_legal_docs.dart` | Sinh lại 4 tài liệu; test parity xanh |
| Diff sau merge đối với `server/**`, `main.dart`, `app.dart` | Rỗng |

Các lượt đầu phát hiện literal cũ từ WIP, bảng knownClasses còn đếm 20 và chưa chờ packageInfo nên báo lỗi thiếu phiên bản. Đã sửa, không tắt lint/skip test. Các kết quả xanh trên là sau các sửa đó.

## Commit

- Kế thừa `8880595` — Giọng văn (WIP 1): hướng dẫn giọng văn và thuật ngữ.
- Kế thừa `8ac79f3` — WIP trước khi bàn giao: lời/pháp lý và bỏ console.
- `9e46bfe` — Merge nền tảng `claude/jolly-hawking-23o2j8` vào worktree, không xung đột.
- `1767c36` — WIP: hoàn thiện lời người chơi và che lỗi kỹ thuật Cộng đồng.
- `dcbf296` — WIP: chốt kiểm kê giọng văn, quyền dịch và tương thích chuỗi.
- Commit chứa báo cáo này — **Hoàn tất WP-COPY: bàn giao nội dung và kiểm tra xanh**; tra SHA bằng `git log -1 --oneline` sau commit (không tự ghi SHA của chính commit vào nội dung).
