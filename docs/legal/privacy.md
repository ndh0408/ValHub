<!-- Tệp tạo tự động từ lib/features/settings/legal/. Không sửa tay: sửa nội dung Dart rồi chạy `dart run tool/export_legal_docs.dart`. -->

# Chính sách quyền riêng tư

**ValVN** · Phiên bản 1.0 · Hiệu lực từ: 29/09/2026

Chính sách này giải thích cách ValVN thu thập, sử dụng, lưu trữ và bảo vệ dữ liệu cá nhân của bạn, và các quyền của bạn đối với dữ liệu đó. Chính sách được xây dựng theo Luật Bảo vệ dữ liệu cá nhân, Nghị định 13/2023/NĐ-CP về bảo vệ dữ liệu cá nhân và các văn bản pháp luật Việt Nam có liên quan.

> Tóm tắt: Phần lớn dữ liệu của bạn chỉ nằm trên thiết bị. Token và cookie Riot được lưu trong vùng lưu trữ bảo mật của hệ điều hành và không gửi cho chúng tôi, với một ngoại lệ duy nhất: khi bạn kết nối Cộng đồng, access token được gửi tới máy chủ ValVN để xác minh Riot ID rồi bị hủy ngay. Máy chủ không lưu PUUID. ValVN không có quảng cáo, không dùng công cụ phân tích hay theo dõi và không bán dữ liệu của bạn.

## 1. Bên kiểm soát và xử lý dữ liệu

Nguyễn Đức Huy ("chúng tôi") là bên quyết định mục đích và phương tiện xử lý dữ liệu cá nhân trong ValVN (bên kiểm soát và xử lý dữ liệu cá nhân). Thông tin liên hệ có ở mục cuối của Chính sách này.

## 2. Phạm vi áp dụng

Chính sách áp dụng cho ứng dụng ValVN trên iOS và Android, bao gồm các tính năng Cộng đồng. Chính sách không áp dụng cho dịch vụ của Riot Games, valorant-api.com, Apple, Google hay các bên thứ ba khác; việc xử lý dữ liệu của họ tuân theo chính sách riêng của từng bên.

## 3. Dữ liệu được xử lý trên thiết bị của bạn

Các dữ liệu sau được tạo ra hoặc lấy về trong quá trình sử dụng và chỉ được lưu trên thiết bị của bạn. Chúng tôi không nhận được các dữ liệu này.

- **Phiên đăng nhập Riot:** token truy cập, token quyền sở hữu và cookie phiên do Riot cấp sau khi bạn đăng nhập trên trang chính thức của Riot. Lưu trong Keychain (iOS) hoặc vùng lưu trữ mã hóa được bảo vệ bởi Keystore (Android). ValVN không bao giờ thấy mật khẩu bạn nhập vào trang của Riot.
- **Ghi chú đăng nhập (tùy chọn):** nếu bạn chủ động lưu tên đăng nhập và mật khẩu Riot để đăng nhập lại nhanh, ghi chú này chỉ nằm trong vùng lưu trữ bảo mật trên thiết bị, không bao giờ được ghi nhật ký hay gửi đi đâu, ngoại trừ được điền vào trang đăng nhập chính thức của Riot khi bạn yêu cầu.
- **Danh sách tài khoản:** Riot ID (tên#tag), mã định danh người chơi (PUUID), khu vực, nền tảng, thẻ người chơi, cấp độ và rank của các tài khoản bạn thêm vào, dùng để hiển thị danh sách và chuyển đổi tài khoản.
- **Dữ liệu trò chơi:** cửa hàng, ví, bộ sưu tập, trang bị, Battle Pass, hợp đồng, lịch sử đấu, rank, trận hiện tại, danh sách bạn bè, trạng thái trực tuyến và tin nhắn trò chuyện. Ứng dụng đọc trực tiếp từ máy chủ Riot bằng phiên đăng nhập của bạn và có thể lưu bản sao tạm để xem ngoại tuyến.
- **Wishlist và cài đặt:** wishlist, tùy chọn giao diện, cài đặt thông báo và nền tảng.
- **Bộ nhớ đệm nội dung:** tên, hình ảnh vật phẩm, đặc vụ, bản đồ từ valorant-api.com và ảnh đã tải, lưu tạm để ứng dụng chạy nhanh hơn.
- **Nhật ký phiên:** nhật ký kỹ thuật (tên yêu cầu, mã trạng thái, thời gian) giúp chẩn đoán lỗi. Nhật ký được lọc để không chứa mật khẩu, token, cookie hay ID tài khoản, và chỉ rời khỏi thiết bị khi bạn tự chia sẻ.

## 4. Dữ liệu được xử lý trên máy chủ Cộng đồng

Chỉ khi bạn sử dụng tính năng Cộng đồng, các dữ liệu sau được gửi tới và lưu trên máy chủ cộng đồng của ValVN:

- **Hồ sơ Cộng đồng:** Riot ID (tên và tag), khu vực, thẻ người chơi và rank do Ứng dụng gửi lên. Đây là thông tin công khai với người dùng khác trong Cộng đồng.
- **Mã người dùng:** một mã băm một chiều (SHA-256 kèm khóa bí mật) được tạo từ PUUID. Máy chủ không lưu và không trả về PUUID của bạn.
- **Bài đăng và bình luận:** nội dung bài viết, hình ảnh bạn tải lên, dữ liệu cửa hàng hoặc Chợ Đêm bạn chọn chia sẻ, bình luận, lượt thích và thời điểm đăng.
- **Bài tìm đồng đội (LFG):** khu vực, chế độ chơi, mã tổ đội, số chỗ trống, rank và ghi chú. Bài tự hết hạn sau 30 phút; mỗi người chỉ có một bài đang hoạt động.
- **Bình chọn skin:** skin bạn bình chọn và thời điểm bình chọn, dùng để xếp hạng skin được yêu thích.
- **Báo cáo vi phạm:** nội dung bị báo cáo, lý do và người báo cáo (dưới dạng mã người dùng), dùng cho kiểm duyệt.
- **Dữ liệu kỹ thuật:** địa chỉ IP, loại yêu cầu và thời điểm được hạ tầng Cloudflare xử lý để truyền tải, bảo mật, chống lạm dụng và giới hạn tần suất.

## 5. Token Riot và xác minh Riot ID

Token và cookie Riot của bạn không bao giờ được gửi cho chúng tôi, với một ngoại lệ duy nhất phục vụ tính năng Cộng đồng:

- Khi bạn kết nối (hoặc kết nối lại) Cộng đồng, Ứng dụng gửi access token Riot qua kết nối mã hóa HTTPS tới máy chủ ValVN.
- Máy chủ dùng token này đúng một lần để hỏi máy chủ của Riot Games thông tin định danh của bạn (PUUID và Riot ID), sau đó hủy token ngay lập tức. Token không được lưu, không được ghi nhật ký và không được dùng cho bất kỳ mục đích nào khác.
- Máy chủ cấp cho Ứng dụng một phiên Cộng đồng riêng (hiệu lực 30 ngày), được lưu trong vùng lưu trữ bảo mật trên thiết bị và bị xóa khi bạn đăng xuất tài khoản.
- Máy chủ Cộng đồng không bao giờ thay mặt bạn thực hiện thao tác nào trên Tài khoản Riot.

## 6. Mục đích xử lý

- Hiển thị thông tin tài khoản, cửa hàng, bộ sưu tập, trận đấu và các tính năng bạn yêu cầu.
- Gửi thông báo cục bộ về cửa hàng, wishlist và Chợ Đêm nếu bạn bật.
- Vận hành Cộng đồng: xác minh người đăng là chủ Riot ID, hiển thị bài đăng, bình luận, bài tìm đồng đội và bảng xếp hạng skin.
- Bảo đảm an toàn: chống spam, lạm dụng, gian lận; kiểm duyệt nội dung bị báo cáo; giới hạn tần suất.
- Chẩn đoán và khắc phục lỗi khi bạn chủ động gửi nhật ký phiên.
- Tuân thủ nghĩa vụ theo quy định của pháp luật.

Chúng tôi không sử dụng dữ liệu của bạn cho quảng cáo, không lập hồ sơ hành vi và không bán, cho thuê hay trao đổi dữ liệu cá nhân.

## 7. Cơ sở pháp lý

- **Sự đồng ý của bạn:** bạn đồng ý khi tiếp tục sử dụng Ứng dụng sau khi được thông báo về Chính sách này, và đồng ý riêng khi bạn kết nối Cộng đồng, bật thông báo hay lưu ghi chú đăng nhập. Bạn có thể rút lại sự đồng ý bất cứ lúc nào.
- **Thực hiện thỏa thuận:** xử lý cần thiết để cung cấp các tính năng bạn yêu cầu theo Điều khoản sử dụng.
- **Nghĩa vụ pháp lý:** khi pháp luật yêu cầu, ví dụ phản hồi yêu cầu hợp pháp của cơ quan nhà nước có thẩm quyền.

## 8. Chia sẻ dữ liệu

Chúng tôi chỉ chia sẻ dữ liệu trong các trường hợp sau:

- **Riot Games:** Ứng dụng kết nối trực tiếp tới máy chủ của Riot Games bằng phiên đăng nhập của bạn để đọc dữ liệu tài khoản và thực hiện thao tác bạn yêu cầu.
- **valorant-api.com:** Ứng dụng tải dữ liệu công khai về vật phẩm; không gửi thông tin tài khoản của bạn.
- **Tệp công khai:** Ứng dụng có thể tải trạng thái máy chủ công khai của Riot và tệp cấu hình tĩnh của ValVN; các yêu cầu này không kèm dữ liệu cá nhân.
- **Cloudflare, Inc.:** nhà cung cấp hạ tầng (Cloudflare Workers, cơ sở dữ liệu D1, lưu trữ R2) xử lý dữ liệu Cộng đồng thay mặt chúng tôi theo hợp đồng dịch vụ.
- **Người dùng khác:** hồ sơ Cộng đồng, bài đăng, hình ảnh, bình luận và bài tìm đồng đội của bạn hiển thị với người dùng ValVN khác. Hình ảnh đã đăng có thể được truy cập qua đường dẫn công khai.
- **Cơ quan nhà nước có thẩm quyền:** khi có yêu cầu hợp pháp theo quy định của pháp luật Việt Nam.

## 9. Chuyển dữ liệu ra nước ngoài

Máy chủ Cộng đồng chạy trên mạng lưới toàn cầu của Cloudflare, Inc. (Hoa Kỳ), nên dữ liệu Cộng đồng có thể được xử lý và lưu trữ tại các trung tâm dữ liệu ngoài Việt Nam. Tương tự, khi bạn sử dụng Ứng dụng, thiết bị của bạn kết nối trực tiếp tới máy chủ của Riot Games ở nước ngoài. Chúng tôi áp dụng các biện pháp bảo vệ phù hợp và thực hiện nghĩa vụ liên quan đến chuyển dữ liệu cá nhân ra nước ngoài theo quy định của pháp luật Việt Nam.

## 10. Thời gian lưu trữ

- **Dữ liệu trên thiết bị:** lưu cho đến khi bạn đăng xuất tài khoản tương ứng, xóa bộ nhớ đệm hoặc gỡ Ứng dụng. Bộ nhớ đệm ảnh tự làm mới sau khoảng 30 ngày.
- **Bài tìm đồng đội:** tự hết hạn và ngừng hiển thị sau 30 phút; dữ liệu hết hạn được xóa định kỳ.
- **Bài đăng, hình ảnh, bình luận, bình chọn:** lưu cho đến khi bạn xóa, hoặc khi chúng tôi gỡ do vi phạm, hoặc khi bạn yêu cầu xóa dữ liệu Cộng đồng.
- **Báo cáo vi phạm:** lưu trong thời gian cần thiết để xử lý vi phạm và phòng chống lạm dụng, tối đa 12 tháng, trừ khi pháp luật yêu cầu lâu hơn.
- **Phiên Cộng đồng:** hết hiệu lực sau 30 ngày và bị xóa khỏi thiết bị khi bạn đăng xuất.

## 11. Xóa dữ liệu

### Trên thiết bị

- Đăng xuất một tài khoản trong Cài đặt sẽ xóa token, cookie, ghi chú đăng nhập, phiên Cộng đồng, dữ liệu đã lưu tạm và thông báo đã lên lịch của tài khoản đó khỏi thiết bị. Wishlist được giữ lại để dùng khi bạn đăng nhập lại; bạn có thể tự xóa từng mục.
- "Xóa bộ nhớ đệm" trong Cài đặt xóa ảnh và dữ liệu ngoại tuyến; "Xóa nhật ký" xóa nhật ký phiên.
- Gỡ Ứng dụng sẽ xóa toàn bộ dữ liệu của Ứng dụng trên thiết bị.

### Trên máy chủ Cộng đồng

- Bạn có thể tự xóa bài đăng, bình luận, bài tìm đồng đội và bỏ bình chọn ngay trong Ứng dụng.
- Để xóa toàn bộ dữ liệu Cộng đồng gắn với Riot ID của bạn, hãy gửi email tới ndh0408@gmail.com kèm Riot ID. Chúng tôi có thể yêu cầu xác minh bạn là chủ tài khoản trước khi xử lý và sẽ phản hồi trong thời hạn pháp luật quy định.
- Lưu ý: đăng xuất khỏi Ứng dụng không tự động xóa nội dung bạn đã đăng trên máy chủ Cộng đồng.

## 12. Thông báo và tác vụ nền

ValVN chỉ dùng thông báo cục bộ do chính thiết bị tạo ra; chúng tôi không vận hành máy chủ gửi thông báo đẩy và không thu thập mã thiết bị. Ứng dụng đăng ký với hệ điều hành một tác vụ nền định kỳ chạy ngay trên thiết bị để giữ phiên đăng nhập còn hiệu lực và, nếu bạn bật, đọc cửa hàng trực tiếp từ Riot để báo skin trong wishlist hoặc Chợ Đêm. Bạn có thể tắt thông báo trong Cài đặt của Ứng dụng hoặc của hệ điều hành.

## 13. Phân tích, quảng cáo và theo dõi

ValVN không tích hợp công cụ phân tích, báo cáo sự cố tự động, quảng cáo hay theo dõi của bên thứ ba, không dùng mã định danh quảng cáo và không theo dõi bạn giữa các ứng dụng hay trang web. Nếu điều này thay đổi trong tương lai, chúng tôi sẽ cập nhật Chính sách và xin sự đồng ý của bạn khi pháp luật yêu cầu.

## 14. Bảo mật dữ liệu

- Thông tin bí mật (token, cookie, ghi chú đăng nhập, phiên Cộng đồng) chỉ được lưu trong Keychain hoặc Keystore của hệ điều hành và được xóa khi cài lại Ứng dụng.
- Mọi kết nối mạng đều được mã hóa bằng HTTPS/TLS.
- Nhật ký được lọc tự động để loại bỏ token, cookie, mật khẩu và ID tài khoản.
- Máy chủ Cộng đồng chỉ lưu mã băm của PUUID, giới hạn tần suất yêu cầu, chỉ cho phép bạn xóa nội dung của chính mình và kiểm soát quyền truy cập vào khóa bí mật.
- Chúng tôi chỉ thu thập dữ liệu ở mức tối thiểu cần thiết cho tính năng.

Không có biện pháp nào an toàn tuyệt đối. Nếu xảy ra sự cố vi phạm dữ liệu cá nhân, chúng tôi sẽ thông báo cho cơ quan có thẩm quyền và người dùng bị ảnh hưởng theo quy định của pháp luật.

## 15. Trẻ em

Ứng dụng không dành cho trẻ em dưới 13 tuổi. Người dùng dưới 16 tuổi chỉ được sử dụng Ứng dụng, đặc biệt là tính năng Cộng đồng, khi có sự đồng ý và giám sát của cha, mẹ hoặc người giám hộ hợp pháp theo quy định của pháp luật. Nếu bạn là phụ huynh và cho rằng con mình đã cung cấp dữ liệu cho Cộng đồng khi chưa có sự đồng ý, vui lòng liên hệ để chúng tôi xóa dữ liệu đó.

## 16. Quyền của bạn

Theo pháp luật Việt Nam về bảo vệ dữ liệu cá nhân (bao gồm Nghị định 13/2023/NĐ-CP), bạn có các quyền sau:

- **Quyền được biết:** được biết về hoạt động xử lý dữ liệu của mình;
- **Quyền đồng ý:** đồng ý hoặc không đồng ý cho xử lý dữ liệu;
- **Quyền truy cập:** xem, chỉnh sửa hoặc yêu cầu chỉnh sửa dữ liệu của mình;
- **Quyền rút lại sự đồng ý:** rút lại sự đồng ý đã cho;
- **Quyền xóa dữ liệu:** yêu cầu xóa dữ liệu của mình;
- **Quyền hạn chế xử lý:** yêu cầu hạn chế xử lý dữ liệu;
- **Quyền được cung cấp dữ liệu:** yêu cầu được cung cấp dữ liệu của mình;
- **Quyền phản đối xử lý:** phản đối việc xử lý dữ liệu nhằm mục đích không mong muốn;
- **Quyền khiếu nại và yêu cầu bồi thường:** khiếu nại, tố cáo, khởi kiện và yêu cầu bồi thường thiệt hại theo quy định của pháp luật;
- **Quyền tự bảo vệ:** tự bảo vệ dữ liệu cá nhân của mình.

Phần lớn dữ liệu nằm trên thiết bị và bạn có thể tự xem hoặc xóa ngay trong Ứng dụng. Với dữ liệu trên máy chủ Cộng đồng, hãy gửi yêu cầu tới ndh0408@gmail.com. Chúng tôi sẽ phản hồi trong thời hạn pháp luật quy định và có thể cần xác minh danh tính của bạn trước khi xử lý.

## 17. Thay đổi Chính sách

Chúng tôi có thể cập nhật Chính sách này khi Ứng dụng hoặc quy định pháp luật thay đổi. Phiên bản và ngày hiệu lực luôn được ghi ở đầu văn bản. Với thay đổi quan trọng về cách xử lý dữ liệu, chúng tôi sẽ thông báo trong Ứng dụng và xin lại sự đồng ý của bạn khi cần.

## 18. Liên hệ

Mọi câu hỏi hoặc yêu cầu về quyền riêng tư và dữ liệu cá nhân, vui lòng liên hệ:

- **Bên kiểm soát dữ liệu:** Nguyễn Đức Huy
- **Email:** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. Bảo lưu mọi quyền.
