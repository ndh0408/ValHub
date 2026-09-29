<!-- Tệp tạo tự động từ lib/features/settings/legal/. Không sửa tay: sửa nội dung Dart rồi chạy `dart run tool/export_legal_docs.dart`. -->

# Chính sách quyền riêng tư

**ValVN** · Phiên bản 1.0 · Hiệu lực từ: 29/09/2026

Chính sách này giải thích cách ValVN thu thập, sử dụng, lưu trữ và bảo vệ dữ liệu cá nhân của bạn, và các quyền của bạn đối với dữ liệu đó. Chính sách được xây dựng theo pháp luật Việt Nam về bảo vệ dữ liệu cá nhân (Nghị định 13/2023/NĐ-CP), đồng thời tính đến các quy định bạn có thể được hưởng ở nơi bạn sống như GDPR, UK GDPR, CCPA/CPRA hay LGPD (xem mục "Quyền của bạn theo luật nơi bạn sống"). ValVN dành cho người chơi VALORANT ở mọi quốc gia.

> Tóm tắt: Phần lớn dữ liệu của bạn chỉ nằm trên thiết bị. Token và cookie Riot được lưu trong vùng lưu trữ bảo mật của hệ điều hành và không gửi cho chúng tôi, với một ngoại lệ duy nhất: khi bạn lần đầu mở Cộng đồng và xác nhận hộp thoại đồng ý một lần, access token được gửi tới máy chủ ValVN để xác minh Riot ID rồi bị hủy ngay. Máy chủ không lưu PUUID. ValVN không có quảng cáo, không dùng công cụ phân tích hay theo dõi và không bán dữ liệu của bạn.

## 1. Bên kiểm soát và xử lý dữ liệu

Nguyễn Đức Huy ("chúng tôi") là bên quyết định mục đích và phương tiện xử lý dữ liệu cá nhân trong ValVN (bên kiểm soát và xử lý dữ liệu cá nhân). Thông tin liên hệ có ở mục cuối của Chính sách này.

## 2. Phạm vi áp dụng

Chính sách áp dụng cho ứng dụng ValVN trên iOS và Android ở mọi quốc gia, bao gồm các tính năng Cộng đồng. Chính sách không áp dụng cho dịch vụ của Riot Games, valorant-api.com, Apple, Google hay các bên thứ ba khác; việc xử lý dữ liệu của họ tuân theo chính sách riêng của từng bên.

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

Máy chủ Cộng đồng là một máy chủ do nhà phát hành tự vận hành (chạy trong container Docker, dữ liệu lưu trong cơ sở dữ liệu SQLite và tệp trên ổ đĩa của máy chủ đó). Lưu lượng từ Ứng dụng tới máy chủ đi qua mạng của Cloudflare (Cloudflare Tunnel), Cloudflare chỉ chuyển tiếp lưu lượng. Chỉ khi bạn sử dụng tính năng Cộng đồng, các dữ liệu sau được gửi tới và lưu trên máy chủ này:

- **Hồ sơ Cộng đồng:** Riot ID (tên và tag), khu vực, thẻ người chơi, rank và ngôn ngữ ứng dụng do Ứng dụng gửi lên. Đây là thông tin công khai với người dùng khác trong Cộng đồng.
- **Quốc gia:** quốc gia của Tài khoản Riot của bạn (do Riot cung cấp khi xác minh, bạn không thể chỉnh sửa), dùng để hiển thị Cộng đồng theo quốc gia.
- **Mã người dùng:** một mã băm một chiều (SHA-256 kèm khóa bí mật) được tạo từ PUUID. Máy chủ không lưu và không trả về PUUID của bạn.
- **Bài đăng và bình luận:** nội dung bài viết, hình ảnh bạn tải lên, dữ liệu cửa hàng hoặc Chợ Đêm bạn chọn chia sẻ, bình luận, lượt thích và thời điểm đăng.
- **Đánh giá skin:** số sao, nội dung nhận xét và lượt "hữu ích" bạn dành cho đánh giá của người khác, hiển thị công khai cùng Riot ID của bạn.
- **Bài tìm đồng đội (LFG):** mã tổ đội, chế độ chơi, khu vực, giới hạn rank, vai trò cần tìm, có yêu cầu micro hay không, ngôn ngữ, quy mô tổ đội, số chỗ trống, ghi chú, trạng thái (mở, đủ người, đang chơi), số lượt bấm vào tổ đội và tín hiệu "còn hoạt động" mà Ứng dụng gửi định kỳ khi bài đang mở. Bài tự hết hạn 30 phút sau tín hiệu cuối cùng; mỗi người chỉ có một bài đang hoạt động.
- **Bình chọn và lượt thích:** skin bạn bình chọn, lượt thích và thời điểm thực hiện, dùng để xếp hạng skin được yêu thích.
- **Báo cáo vi phạm:** nội dung bị báo cáo, lý do và người báo cáo (dưới dạng mã người dùng), dùng cho kiểm duyệt.
- **Nhật ký truy cập của máy chủ:** máy chủ ghi lại phương thức, đường dẫn, mã trạng thái và thời gian xử lý của mỗi yêu cầu để vận hành và chẩn đoán lỗi. Địa chỉ IP chỉ được dùng dưới dạng mã băm có muối để giới hạn tần suất yêu cầu, không được ghi ở dạng đọc được. Cloudflare có thể xử lý địa chỉ IP khi chuyển tiếp lưu lượng theo chính sách riêng của họ.
- **Ảnh tải lên:** hình ảnh bạn đăng được lưu dưới dạng tệp trên ổ đĩa của máy chủ Cộng đồng và có thể truy cập qua đường dẫn công khai. Việc xóa ảnh được nêu ở mục "Xóa dữ liệu".
- **Sao lưu:** máy chủ được sao lưu hằng ngày; các bản sao lưu được giữ 14 ngày trên máy chủ của nhà phát hành.

## 5. Token Riot và xác minh Riot ID

Token và cookie Riot của bạn không bao giờ được gửi cho chúng tôi, với một ngoại lệ duy nhất phục vụ tính năng Cộng đồng:

- Ứng dụng chỉ gửi access token khi bạn lần đầu mở tính năng Cộng đồng và xác nhận hộp thoại đồng ý một lần (và khi bạn kết nối lại sau khi phiên Cộng đồng hết hạn). Nếu bạn không đồng ý, Cộng đồng không hoạt động và không có token nào được gửi đi. Token được gửi qua kết nối mã hóa HTTPS tới máy chủ ValVN.
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

- **Sự đồng ý của bạn:** bạn đồng ý khi tiếp tục sử dụng Ứng dụng sau khi được thông báo về Chính sách này, và đồng ý riêng khi bạn xác nhận hộp thoại kết nối Cộng đồng, bật thông báo hay lưu ghi chú đăng nhập. Bạn có thể rút lại sự đồng ý bất cứ lúc nào.
- **Thực hiện thỏa thuận:** xử lý cần thiết để cung cấp các tính năng bạn yêu cầu theo Điều khoản sử dụng.
- **Lợi ích chính đáng:** bảo vệ Cộng đồng khỏi spam, lạm dụng và gian lận, kiểm duyệt nội dung bị báo cáo và duy trì an ninh của máy chủ, với dữ liệu ở mức tối thiểu cần thiết.
- **Nghĩa vụ pháp lý:** khi pháp luật yêu cầu, ví dụ phản hồi yêu cầu hợp pháp của cơ quan nhà nước có thẩm quyền.

## 8. Chia sẻ dữ liệu

Chúng tôi chỉ chia sẻ dữ liệu trong các trường hợp sau:

- **Riot Games:** Ứng dụng kết nối trực tiếp tới máy chủ của Riot Games bằng phiên đăng nhập của bạn để đọc dữ liệu tài khoản và thực hiện thao tác bạn yêu cầu.
- **valorant-api.com:** Ứng dụng tải dữ liệu công khai về vật phẩm; không gửi thông tin tài khoản của bạn.
- **Tệp công khai:** Ứng dụng có thể tải trạng thái máy chủ công khai của Riot và tệp cấu hình tĩnh của ValVN; các yêu cầu này không kèm dữ liệu cá nhân.
- **Cloudflare, Inc.:** cung cấp mạng chuyển tiếp (Cloudflare Tunnel) cho lưu lượng tới máy chủ Cộng đồng. Cloudflare không lưu dữ liệu Cộng đồng của chúng tôi nhưng có thể xử lý dữ liệu kỹ thuật như địa chỉ IP theo chính sách riêng của họ.
- **Người dùng khác:** hồ sơ Cộng đồng, bài đăng, hình ảnh, bình luận và bài tìm đồng đội của bạn hiển thị với người dùng ValVN khác. Hình ảnh đã đăng có thể được truy cập qua đường dẫn công khai.
- **Cơ quan nhà nước có thẩm quyền:** khi có yêu cầu hợp pháp theo quy định của pháp luật áp dụng cho nhà phát hành.

## 9. Chuyển dữ liệu qua biên giới

Máy chủ Cộng đồng do nhà phát hành tự vận hành; lưu lượng tới máy chủ đi qua mạng toàn cầu của Cloudflare, Inc. nên có thể đi qua nhiều quốc gia. Dữ liệu Cộng đồng bạn đăng hiển thị với người dùng ValVN ở mọi nơi. Khi bạn sử dụng Ứng dụng, thiết bị của bạn cũng kết nối trực tiếp tới máy chủ của Riot Games. Chúng tôi áp dụng các biện pháp bảo vệ phù hợp và thực hiện nghĩa vụ liên quan đến chuyển dữ liệu cá nhân qua biên giới theo pháp luật Việt Nam và, khi bạn ở nơi có quy định tương ứng, theo pháp luật nơi bạn sống.

## 10. Thời gian lưu trữ

- **Dữ liệu trên thiết bị:** lưu cho đến khi bạn đăng xuất tài khoản tương ứng, xóa bộ nhớ đệm hoặc gỡ Ứng dụng. Bộ nhớ đệm ảnh tự làm mới sau khoảng 30 ngày.
- **Bài tìm đồng đội:** tự hết hạn và ngừng hiển thị 30 phút sau tín hiệu "còn hoạt động" cuối cùng; dữ liệu hết hạn được xóa định kỳ.
- **Bài đăng, đánh giá, bình luận, bình chọn:** lưu cho đến khi bạn xóa, hoặc khi chúng tôi gỡ do vi phạm, hoặc khi bạn yêu cầu xóa dữ liệu Cộng đồng.
- **Báo cáo vi phạm:** chúng tôi cam kết chỉ giữ báo cáo trong thời gian cần thiết để xử lý vi phạm và phòng chống lạm dụng, và xóa hoặc ẩn danh chúng khi không còn cần thiết, trừ khi pháp luật yêu cầu giữ lâu hơn.
- **Nhật ký truy cập của máy chủ:** chỉ mã băm có muối phục vụ giới hạn tần suất; nhật ký kỹ thuật chỉ giữ trong thời gian cần để chẩn đoán lỗi và bảo mật.
- **Bản sao lưu:** giữ 14 ngày rồi bị ghi đè; nội dung đã xóa vì thế có thể còn trong bản sao lưu tối đa 14 ngày.
- **Phiên Cộng đồng:** hết hiệu lực sau 30 ngày và bị xóa khỏi thiết bị khi bạn đăng xuất.

## 11. Xóa dữ liệu

### Trên thiết bị

- Đăng xuất một tài khoản trong Cài đặt sẽ xóa token, cookie, ghi chú đăng nhập, phiên Cộng đồng, dữ liệu đã lưu tạm và thông báo đã lên lịch của tài khoản đó khỏi thiết bị. Wishlist được giữ lại để dùng khi bạn đăng nhập lại; bạn có thể tự xóa từng mục.
- "Xóa bộ nhớ đệm" trong Cài đặt xóa ảnh và dữ liệu ngoại tuyến; "Xóa nhật ký" xóa nhật ký phiên.
- Gỡ Ứng dụng sẽ xóa toàn bộ dữ liệu của Ứng dụng trên thiết bị.

### Trên máy chủ Cộng đồng

- Bạn có thể tự xóa bài đăng, đánh giá, bình luận, bài tìm đồng đội và bỏ bình chọn ngay trong Ứng dụng.
- Để xóa toàn bộ dữ liệu Cộng đồng gắn với Riot ID của bạn, hãy gửi email tới ndh0408@gmail.com kèm Riot ID. Chúng tôi có thể yêu cầu xác minh bạn là chủ tài khoản trước khi xử lý và xử lý yêu cầu trong vòng 30 ngày.
- Hình ảnh: hiện máy chủ chưa tự động xóa tệp ảnh khi bạn xóa bài đăng. Chúng tôi cam kết xóa ảnh của bạn trong vòng 30 ngày kể từ khi nhận được yêu cầu qua email. Nếu và khi chức năng này được triển khai, ảnh sẽ được xóa cùng bài đăng hoặc tài khoản và Chính sách sẽ được cập nhật.
- Nội dung đã xóa có thể còn trong bản sao lưu tối đa 14 ngày trước khi bị ghi đè.
- Lưu ý: đăng xuất khỏi Ứng dụng không tự động xóa nội dung bạn đã đăng trên máy chủ Cộng đồng.

## 12. Thông báo và tác vụ nền

ValVN chỉ dùng thông báo cục bộ do chính thiết bị tạo ra; chúng tôi không vận hành máy chủ gửi thông báo đẩy và không thu thập mã thiết bị. Ứng dụng đăng ký với hệ điều hành một tác vụ nền định kỳ chạy ngay trên thiết bị để giữ phiên đăng nhập còn hiệu lực và, nếu bạn bật, đọc cửa hàng trực tiếp từ Riot để báo skin trong wishlist hoặc Chợ Đêm. Bạn có thể tắt thông báo trong Cài đặt của Ứng dụng hoặc của hệ điều hành.

## 13. Phân tích, quảng cáo và theo dõi

ValVN không tích hợp công cụ phân tích, báo cáo sự cố tự động, quảng cáo hay theo dõi của bên thứ ba, không dùng mã định danh quảng cáo và không theo dõi bạn giữa các ứng dụng hay trang web. Nếu điều này thay đổi trong tương lai, chúng tôi sẽ cập nhật Chính sách và xin sự đồng ý của bạn khi pháp luật yêu cầu.

## 14. Bảo mật dữ liệu

- Thông tin bí mật (token, cookie, ghi chú đăng nhập, phiên Cộng đồng) chỉ được lưu trong Keychain hoặc Keystore của hệ điều hành và được xóa khi cài lại Ứng dụng.
- Mọi kết nối mạng đều được mã hóa bằng HTTPS/TLS.
- Nhật ký được lọc tự động để loại bỏ token, cookie, mật khẩu và ID tài khoản.
- Máy chủ Cộng đồng chỉ lưu mã băm của PUUID, giới hạn tần suất yêu cầu (dựa trên mã băm có muối của địa chỉ IP), chỉ cho phép bạn xóa nội dung của chính mình và giữ khóa bí mật trong cấu hình máy chủ, không đưa vào mã nguồn.
- Chúng tôi chỉ thu thập dữ liệu ở mức tối thiểu cần thiết cho tính năng.

Không có biện pháp nào an toàn tuyệt đối. Nếu xảy ra sự cố vi phạm dữ liệu cá nhân, chúng tôi sẽ thông báo cho cơ quan có thẩm quyền và người dùng bị ảnh hưởng theo quy định của pháp luật.

## 15. Trẻ em

Ứng dụng không dành cho trẻ em dưới 13 tuổi. Ở những nơi pháp luật quy định độ tuổi tối thiểu để tự đồng ý xử lý dữ liệu cao hơn (ví dụ 16 tuổi ở một số nước thuộc Liên minh châu Âu), bạn chỉ được sử dụng Ứng dụng, đặc biệt là tính năng Cộng đồng, khi đã đủ tuổi đó hoặc khi có sự đồng ý và giám sát của cha, mẹ hoặc người giám hộ hợp pháp. Nếu bạn là phụ huynh và cho rằng con mình đã cung cấp dữ liệu cho Cộng đồng khi chưa có sự đồng ý, vui lòng liên hệ để chúng tôi xóa dữ liệu đó.

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

Phần lớn dữ liệu nằm trên thiết bị và bạn có thể tự xem hoặc xóa ngay trong Ứng dụng. Với dữ liệu trên máy chủ Cộng đồng, hãy gửi yêu cầu tới ndh0408@gmail.com. Chúng tôi xử lý yêu cầu trong vòng 30 ngày và có thể cần xác minh danh tính của bạn trước khi xử lý. Hiện chúng tôi chưa có công cụ tự động xuất dữ liệu: yêu cầu cung cấp bản sao dữ liệu được xử lý thủ công và trả lời bằng tệp văn bản thông dụng trong cùng thời hạn.

## 17. Quyền của bạn theo luật nơi bạn sống

Tùy nơi bạn sống, pháp luật địa phương có thể cho bạn thêm quyền. Dù bạn ở đâu, bạn đều có thể thực hiện các quyền thực tế dưới đây bằng cách gửi email tới ndh0408@gmail.com; chúng tôi xử lý yêu cầu trong vòng 30 ngày và không phân biệt đối xử với bạn vì đã thực hiện quyền của mình.

- **Truy cập:** biết chúng tôi giữ dữ liệu gì về bạn và nhận một bản sao;
- **Xóa:** yêu cầu xóa dữ liệu Cộng đồng gắn với Riot ID của bạn (xem mục "Xóa dữ liệu");
- **Chỉnh sửa:** sửa dữ liệu không chính xác (hồ sơ Cộng đồng được làm mới từ tài khoản Riot mỗi lần bạn kết nối);
- **Di chuyển dữ liệu:** nhận dữ liệu của bạn ở định dạng thông dụng;
- **Phản đối, hạn chế và rút lại đồng ý:** phản đối hoặc yêu cầu hạn chế việc xử lý, và rút lại sự đồng ý bất cứ lúc nào;
- **Khiếu nại:** khiếu nại tới cơ quan bảo vệ dữ liệu có thẩm quyền ở nơi bạn sống.

Một số ví dụ về luật có thể áp dụng cho bạn:

- **GDPR / UK GDPR:** nếu bạn ở Liên minh châu Âu, Khu vực kinh tế châu Âu hoặc Vương quốc Anh: bạn có các quyền truy cập, chỉnh sửa, xóa, hạn chế, di chuyển dữ liệu, phản đối và rút lại sự đồng ý, cùng quyền khiếu nại tới cơ quan giám sát dữ liệu tại quốc gia bạn sống. Cơ sở xử lý dữ liệu được nêu ở mục "Cơ sở pháp lý".
- **CCPA / CPRA:** nếu bạn là cư dân California: bạn có quyền biết, xóa, sửa dữ liệu và từ chối việc "bán" hay "chia sẻ" dữ liệu. ValVN không bán và không chia sẻ dữ liệu cá nhân cho quảng cáo theo ngữ cảnh khác.
- **LGPD:** nếu bạn ở Brazil: bạn có các quyền truy cập, chỉnh sửa, ẩn danh, xóa, di chuyển dữ liệu và thông tin về việc chia sẻ dữ liệu.
- **PIPL và luật tương tự:** nếu bạn ở Trung Quốc đại lục hoặc nơi có luật tương tự: bạn có quyền biết, quyết định, hạn chế, từ chối, truy cập, sao chép, chỉnh sửa, xóa dữ liệu và yêu cầu giải thích về việc xử lý.
- **Nghị định 13/2023/NĐ-CP:** nếu bạn ở Việt Nam: các quyền nêu ở mục "Quyền của bạn" ở trên.

Chúng tôi không thu thập nhiều dữ liệu hơn mức cần thiết và không thực hiện quyết định tự động có ảnh hưởng pháp lý tới bạn. Nếu bạn không hài lòng với phản hồi của chúng tôi, bạn có quyền khiếu nại tới cơ quan có thẩm quyền ở nơi bạn sống.

## 18. Thay đổi Chính sách

Chúng tôi có thể cập nhật Chính sách này khi Ứng dụng hoặc quy định pháp luật thay đổi. Phiên bản và ngày hiệu lực luôn được ghi ở đầu văn bản. Với thay đổi quan trọng về cách xử lý dữ liệu, chúng tôi sẽ thông báo trong Ứng dụng và xin lại sự đồng ý của bạn khi cần.

## 19. Liên hệ

Mọi câu hỏi hoặc yêu cầu về quyền riêng tư và dữ liệu cá nhân, vui lòng liên hệ:

- **Bên kiểm soát dữ liệu:** Nguyễn Đức Huy
- **Email:** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. Bảo lưu mọi quyền.
