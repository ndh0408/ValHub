import 'legal_document.dart';
import 'legal_info.dart';

const _publisher = LegalInfo.publisherName;
const _email = LegalInfo.contactEmail;

/// Chính sách quyền riêng tư ValVN.
///
/// Facts must match the code: Riot secrets only in secure storage
/// (`SecureStore`), the only Riot token that leaves the device goes to
/// `POST /v1/auth/riot` (docs/community-api.md) after a one-time consent,
/// no analytics / ads / crash SDK, local notifications only, scrubbed error
/// report (the session log; it leaves the device only when the user picks
/// "Gửi báo lỗi cho ValVN"). The community server is a self-hosted Docker
/// container (Node + SQLite + files on disk) reached through a Cloudflare
/// Tunnel; features the server does not implement yet (deleting images with
/// a post, data export) are written as commitments with a response time,
/// never as done.
///
/// The text shown to users is deliberately in plain words. Implementation
/// names (Docker, SQLite, Cloudflare Tunnel, SHA-256 with a secret key) are
/// not printed, only the facts they stand for: a self-operated server with a
/// database and files on its disk, Cloudflare only relays the connection,
/// and the PUUID is stored only as a one-way hash.
const privacyPolicy = LegalDocument(
  id: 'privacy',
  title: 'Chính sách quyền riêng tư',
  summary: 'Dữ liệu nào được xử lý, ở đâu và quyền của bạn',
  version: '1.0',
  preamble: [
    LegalParagraph(
      'Chính sách này giải thích cách ValVN thu thập, sử dụng, lưu trữ và bảo '
      'vệ dữ liệu cá nhân của bạn, cũng như các quyền của bạn đối với dữ liệu '
      'đó. Chính sách được xây dựng theo pháp luật Việt Nam về bảo vệ dữ liệu '
      'cá nhân (Nghị định 13/2023/NĐ-CP), đồng thời tính đến các quy định bạn '
      'có thể được hưởng ở nơi bạn sống, như GDPR, UK GDPR, CCPA/CPRA hay LGPD '
      '(xem mục "Quyền của bạn theo luật nơi bạn sống"). ValVN dành cho người '
      'chơi VALORANT ở mọi quốc gia.',
    ),
    LegalCallout(
      'Tóm tắt: Phần lớn dữ liệu của bạn chỉ nằm trên thiết bị. Dữ liệu đăng '
      'nhập Riot của bạn được lưu trong vùng lưu trữ bảo mật của hệ điều hành '
      'và không gửi cho chúng tôi, trừ một trường hợp duy nhất: khi bạn lần '
      'đầu mở Cộng đồng và xác nhận đồng ý trong hộp thoại hiện ra một lần, '
      'mã truy cập Riot (access token) được gửi tới máy chủ ValVN để xác minh '
      'Riot ID, rồi bị hủy ngay. Máy chủ không lưu PUUID (mã định danh người '
      'chơi của bạn). ValVN không có quảng cáo, không dùng công cụ phân tích '
      'hay theo dõi và không bán dữ liệu của bạn.',
    ),
  ],
  sections: [
    LegalSection('Bên kiểm soát và xử lý dữ liệu', [
      LegalParagraph(
        '$_publisher ("chúng tôi") là bên quyết định mục đích và phương tiện '
        'xử lý dữ liệu cá nhân trong ValVN (bên kiểm soát và xử lý dữ liệu cá '
        'nhân). Thông tin liên hệ có ở mục cuối của Chính sách này.',
      ),
    ]),
    LegalSection('Phạm vi áp dụng', [
      LegalParagraph(
        'Chính sách áp dụng cho ứng dụng ValVN trên iOS và Android ở mọi quốc '
        'gia, bao gồm các tính năng Cộng đồng. Chính sách không áp dụng cho '
        'dịch vụ của Riot Games, valorant-api.com, Apple, Google hay các bên '
        'thứ ba khác. Mỗi bên xử lý dữ liệu theo chính sách riêng của họ.',
      ),
    ]),
    LegalSection('Dữ liệu được xử lý trên thiết bị của bạn', [
      LegalParagraph(
        'Các dữ liệu dưới đây được tạo ra hoặc tải về khi bạn dùng ứng dụng, '
        'và chỉ được lưu trên thiết bị của bạn. Chúng tôi không nhận được các '
        'dữ liệu này.',
      ),
      LegalList([
        LegalItem(
          'dữ liệu do Riot cấp cho ứng dụng sau khi bạn đăng nhập trên trang '
          'chính thức của Riot, gồm mã truy cập (access token), mã quyền sở '
          'hữu (entitlement token) và cookie đăng nhập (tệp giúp Riot nhớ '
          'rằng bạn đã đăng nhập). Chúng được lưu trong Keychain (iOS) hoặc '
          'vùng lưu trữ mã hóa do Keystore bảo vệ (Android). ValVN không bao '
          'giờ thấy mật khẩu bạn nhập vào trang của Riot.',
          lead: 'Dữ liệu đăng nhập Riot:',
        ),
        LegalItem(
          'nếu bạn tự chọn lưu tên đăng nhập và mật khẩu Riot để đăng nhập lại '
          'nhanh hơn, thông tin này chỉ nằm trong vùng lưu trữ bảo mật trên '
          'thiết bị. Nó không bao giờ bị ghi vào báo lỗi hay gửi đi đâu, trừ '
          'việc được điền vào trang đăng nhập chính thức của Riot khi bạn yêu '
          'cầu.',
          lead: 'Thông tin đăng nhập đã lưu (tùy chọn):',
        ),
        LegalItem(
          'Riot ID (tên#tag), mã định danh người chơi (PUUID), khu vực, nền '
          'tảng, thẻ người chơi, cấp độ và rank của các tài khoản bạn thêm '
          'vào. Ứng dụng dùng chúng để hiển thị danh sách và chuyển đổi giữa '
          'các tài khoản.',
          lead: 'Danh sách tài khoản:',
        ),
        LegalItem(
          'cửa hàng, ví, bộ sưu tập, trang bị, Battle Pass, hợp đồng, lịch sử '
          'đấu, rank, trận hiện tại, danh sách bạn bè, trạng thái trực tuyến '
          'và tin nhắn trò chuyện. Ứng dụng đọc trực tiếp từ máy chủ của Riot '
          'bằng đăng nhập Riot của bạn và có thể lưu bản sao tạm để bạn xem '
          'khi không có mạng.',
          lead: 'Dữ liệu trò chơi:',
        ),
        LegalItem(
          'wishlist, tùy chọn giao diện, cài đặt thông báo và nền tảng.',
          lead: 'Wishlist và cài đặt:',
        ),
        LegalItem(
          'tên và hình ảnh vật phẩm, đặc vụ, bản đồ lấy từ valorant-api.com, '
          'cùng các ảnh đã tải, được lưu tạm để ứng dụng chạy nhanh hơn.',
          lead: 'Dữ liệu tạm:',
        ),
        LegalItem(
          'bản ghi kỹ thuật trên thiết bị về những gì ứng dụng đã làm (tên các '
          'yêu cầu gửi đi, kết quả và thời gian), dùng để tìm lỗi. Bản ghi '
          'được lọc để không chứa mật khẩu, dữ liệu đăng nhập Riot hay ID tài '
          'khoản, và chỉ rời khỏi thiết bị khi bạn tự chọn "Gửi báo lỗi cho '
          'ValVN" trong Cài đặt > Nâng cao.',
          lead: 'Báo lỗi:',
        ),
      ]),
    ]),
    LegalSection('Dữ liệu được xử lý trên máy chủ Cộng đồng', [
      LegalParagraph(
        'Máy chủ Cộng đồng là máy chủ do nhà phát hành tự vận hành. Dữ liệu '
        'được lưu trong cơ sở dữ liệu và các tệp trên ổ đĩa của máy chủ đó. '
        'Kết nối từ Ứng dụng tới máy chủ này đi qua mạng của Cloudflare; '
        'Cloudflare chỉ chuyển tiếp kết nối. Chỉ khi bạn dùng tính năng Cộng '
        'đồng, các dữ liệu dưới đây mới được gửi tới và lưu trên máy chủ này:',
      ),
      LegalList([
        LegalItem(
          'Riot ID (tên và tag), khu vực, thẻ người chơi, rank và ngôn ngữ '
          'ứng dụng, do Ứng dụng gửi lên. Đây là thông tin công khai với '
          'người dùng khác trong Cộng đồng.',
          lead: 'Hồ sơ Cộng đồng:',
        ),
        LegalItem(
          'quốc gia của Tài khoản Riot của bạn (do Riot cung cấp khi xác '
          'minh, bạn không thể chỉnh sửa), dùng để hiển thị Cộng đồng theo '
          'quốc gia.',
          lead: 'Quốc gia:',
        ),
        LegalItem(
          'một mã băm một chiều (không thể suy ngược ra PUUID) được tạo từ '
          'PUUID của bạn. Máy chủ không lưu và không trả về PUUID của bạn.',
          lead: 'Mã người dùng:',
        ),
        LegalItem(
          'nội dung bài viết, hình ảnh bạn tải lên, thông tin cửa hàng hoặc '
          'Chợ Đêm mà bạn chọn chia sẻ, bình luận, lượt thích và thời điểm '
          'đăng.',
          lead: 'Bài đăng và bình luận:',
        ),
        LegalItem(
          'số sao, nội dung nhận xét và lượt "hữu ích" bạn dành cho đánh giá '
          'của người khác. Những thông tin này hiển thị công khai cùng Riot '
          'ID của bạn.',
          lead: 'Đánh giá skin:',
        ),
        LegalItem(
          'mã tổ đội, chế độ chơi, khu vực, giới hạn rank, vai trò cần tìm, có '
          'yêu cầu micro hay không, ngôn ngữ, quy mô tổ đội, số chỗ trống, ghi '
          'chú, trạng thái (mở, đủ người, đang chơi), số lượt bấm vào tổ đội, '
          'và tín hiệu "còn hoạt động" mà Ứng dụng gửi định kỳ khi bài đang '
          'mở. Bài tự hết hạn 30 phút sau tín hiệu cuối cùng. Mỗi người chỉ '
          'có một bài đang hoạt động.',
          lead: 'Bài tìm đồng đội:',
        ),
        LegalItem(
          'skin bạn bình chọn, lượt thích và thời điểm thực hiện, dùng để xếp '
          'hạng skin được yêu thích.',
          lead: 'Bình chọn và lượt thích:',
        ),
        LegalItem(
          'nội dung bị báo cáo, lý do và người báo cáo (dưới dạng mã người '
          'dùng), dùng để kiểm duyệt.',
          lead: 'Báo cáo vi phạm:',
        ),
        LegalItem(
          'máy chủ ghi lại loại yêu cầu, đường dẫn, kết quả và thời gian xử '
          'lý của mỗi yêu cầu để vận hành và tìm lỗi. Địa chỉ IP chỉ được '
          'dùng dưới dạng mã băm có muối (mã băm một chiều có thêm một chuỗi '
          'ngẫu nhiên) để giới hạn số lần gửi yêu cầu, và không được ghi ở '
          'dạng đọc được. Cloudflare có thể xử lý địa chỉ IP khi chuyển tiếp '
          'kết nối, theo chính sách riêng của họ.',
          lead: 'Nhật ký truy cập của máy chủ:',
        ),
        LegalItem(
          'hình ảnh bạn đăng được lưu thành tệp trên ổ đĩa của máy chủ Cộng '
          'đồng và có thể mở qua một liên kết công khai. Cách xóa ảnh được '
          'nêu ở mục "Xóa dữ liệu".',
          lead: 'Ảnh tải lên:',
        ),
        LegalItem(
          'máy chủ được sao lưu hằng ngày; các bản sao lưu được giữ 14 ngày '
          'trên máy chủ của nhà phát hành.',
          lead: 'Sao lưu:',
        ),
      ]),
    ]),
    LegalSection('Mã truy cập Riot và xác minh Riot ID', [
      LegalParagraph(
        'Dữ liệu đăng nhập Riot của bạn (mã truy cập, mã quyền sở hữu và '
        'cookie) không bao giờ được gửi cho chúng tôi, trừ một ngoại lệ duy '
        'nhất phục vụ tính năng Cộng đồng:',
      ),
      LegalList([
        LegalItem(
          'Ứng dụng chỉ gửi mã truy cập Riot (access token) khi bạn lần đầu '
          'mở tính năng Cộng đồng và xác nhận đồng ý trong hộp thoại hiện ra '
          'một lần, hoặc khi bạn kết nối lại sau khi lần đăng nhập Cộng đồng '
          'của bạn hết hạn. Nếu bạn không đồng ý, Cộng đồng không hoạt động '
          'và không có mã nào được gửi đi. Mã được gửi tới máy chủ ValVN qua '
          'kết nối mã hóa (HTTPS).',
        ),
        LegalItem(
          'Máy chủ dùng mã này đúng một lần để hỏi máy chủ của Riot Games về '
          'thông tin định danh của bạn (PUUID và Riot ID), rồi hủy mã ngay '
          'lập tức. Mã không được lưu, không được ghi vào nhật ký của máy '
          'chủ và không được dùng cho bất kỳ mục đích nào khác.',
        ),
        LegalItem(
          'Máy chủ cấp cho Ứng dụng một mã đăng nhập Cộng đồng riêng, có hiệu '
          'lực 30 ngày. Mã này được lưu trong vùng lưu trữ bảo mật trên thiết '
          'bị và bị xóa khi bạn đăng xuất tài khoản.',
        ),
        LegalItem(
          'Máy chủ Cộng đồng không bao giờ thay mặt bạn thực hiện thao tác nào '
          'trên Tài khoản Riot.',
        ),
      ]),
    ]),
    LegalSection('Mục đích xử lý', [
      LegalList([
        LegalItem(
          'Hiển thị thông tin tài khoản, cửa hàng, bộ sưu tập, trận đấu và các '
          'tính năng bạn yêu cầu.',
        ),
        LegalItem(
          'Gửi thông báo ngay trên thiết bị về cửa hàng, wishlist và Chợ Đêm '
          'nếu bạn bật.',
        ),
        LegalItem(
          'Vận hành Cộng đồng: xác minh người đăng là chủ Riot ID, hiển thị '
          'bài đăng, bình luận, bài tìm đồng đội và bảng xếp hạng skin.',
        ),
        LegalItem(
          'Bảo đảm an toàn: chống spam, lạm dụng và gian lận; kiểm duyệt nội '
          'dung bị báo cáo; giới hạn số lần gửi yêu cầu trong một khoảng thời '
          'gian.',
        ),
        LegalItem('Tìm và sửa lỗi khi bạn chủ động gửi báo lỗi cho ValVN.'),
        LegalItem('Tuân thủ nghĩa vụ theo quy định của pháp luật.'),
      ]),
      LegalParagraph(
        'Chúng tôi không sử dụng dữ liệu của bạn cho quảng cáo, không lập hồ '
        'sơ hành vi và không bán, cho thuê hay trao đổi dữ liệu cá nhân.',
      ),
    ]),
    LegalSection('Cơ sở pháp lý', [
      LegalList([
        LegalItem(
          'bạn đồng ý khi tiếp tục sử dụng Ứng dụng sau khi được thông báo về '
          'Chính sách này, và đồng ý riêng khi bạn xác nhận hộp thoại kết nối '
          'Cộng đồng, bật thông báo hay lưu thông tin đăng nhập. Bạn có thể '
          'rút lại sự đồng ý bất cứ lúc nào.',
          lead: 'Sự đồng ý của bạn:',
        ),
        LegalItem(
          'xử lý cần thiết để cung cấp các tính năng bạn yêu cầu theo Điều '
          'khoản sử dụng.',
          lead: 'Thực hiện thỏa thuận:',
        ),
        LegalItem(
          'bảo vệ Cộng đồng khỏi spam, lạm dụng và gian lận, kiểm duyệt nội '
          'dung bị báo cáo và giữ an ninh cho máy chủ, với dữ liệu ở mức tối '
          'thiểu cần thiết.',
          lead: 'Lợi ích chính đáng:',
        ),
        LegalItem(
          'khi pháp luật yêu cầu, ví dụ phản hồi yêu cầu hợp pháp của cơ quan '
          'nhà nước có thẩm quyền.',
          lead: 'Nghĩa vụ pháp lý:',
        ),
      ]),
    ]),
    LegalSection('Chia sẻ dữ liệu', [
      LegalParagraph('Chúng tôi chỉ chia sẻ dữ liệu trong các trường hợp sau:'),
      LegalList([
        LegalItem(
          'Ứng dụng kết nối trực tiếp tới máy chủ của Riot Games bằng đăng '
          'nhập Riot của bạn để đọc dữ liệu tài khoản và thực hiện thao tác '
          'bạn yêu cầu.',
          lead: 'Riot Games:',
        ),
        LegalItem(
          'Ứng dụng tải dữ liệu công khai về vật phẩm; không gửi thông tin '
          'tài khoản của bạn.',
          lead: 'valorant-api.com:',
        ),
        LegalItem(
          'Ứng dụng có thể tải trạng thái máy chủ công khai của Riot và tệp '
          'thiết lập chung của ValVN; các yêu cầu này không kèm dữ liệu cá '
          'nhân.',
          lead: 'Tệp công khai:',
        ),
        LegalItem(
          'cung cấp mạng chuyển tiếp kết nối tới máy chủ Cộng đồng. Cloudflare '
          'không lưu dữ liệu Cộng đồng của chúng tôi nhưng có thể xử lý dữ '
          'liệu kỹ thuật như địa chỉ IP theo chính sách riêng của họ.',
          lead: 'Cloudflare, Inc.:',
        ),
        LegalItem(
          'hồ sơ Cộng đồng, bài đăng, hình ảnh, bình luận và bài tìm đồng đội '
          'của bạn hiển thị với người dùng ValVN khác. Hình ảnh đã đăng có '
          'thể mở được qua một liên kết công khai.',
          lead: 'Người dùng khác:',
        ),
        LegalItem(
          'khi có yêu cầu hợp pháp theo quy định của pháp luật áp dụng cho nhà '
          'phát hành.',
          lead: 'Cơ quan nhà nước có thẩm quyền:',
        ),
      ]),
    ]),
    LegalSection('Chuyển dữ liệu qua biên giới', [
      LegalParagraph(
        'Máy chủ Cộng đồng do nhà phát hành tự vận hành. Kết nối tới máy chủ '
        'này đi qua mạng toàn cầu của Cloudflare, Inc., nên dữ liệu có thể đi '
        'qua nhiều quốc gia. Dữ liệu Cộng đồng bạn đăng hiển thị với người '
        'dùng ValVN ở mọi nơi. Khi bạn dùng Ứng dụng, thiết bị của bạn cũng '
        'kết nối trực tiếp tới máy chủ của Riot Games. Chúng tôi áp dụng các '
        'biện pháp bảo vệ phù hợp và thực hiện nghĩa vụ liên quan đến việc '
        'chuyển dữ liệu cá nhân qua biên giới theo pháp luật Việt Nam và, khi '
        'bạn ở nơi có quy định tương ứng, theo pháp luật nơi bạn sống.',
      ),
    ]),
    LegalSection('Thời gian lưu trữ', [
      LegalList([
        LegalItem(
          'lưu cho đến khi bạn đăng xuất tài khoản tương ứng, xóa dữ liệu tạm '
          'hoặc gỡ Ứng dụng. Ảnh lưu tạm tự làm mới sau khoảng 30 ngày.',
          lead: 'Dữ liệu trên thiết bị:',
        ),
        LegalItem(
          'tự hết hạn và ngừng hiển thị 30 phút sau tín hiệu "còn hoạt động" '
          'cuối cùng; dữ liệu hết hạn được xóa định kỳ.',
          lead: 'Bài tìm đồng đội:',
        ),
        LegalItem(
          'lưu cho đến khi bạn xóa, hoặc khi chúng tôi gỡ do vi phạm, hoặc khi '
          'bạn yêu cầu xóa dữ liệu Cộng đồng.',
          lead: 'Bài đăng, đánh giá, bình luận, bình chọn:',
        ),
        LegalItem(
          'chỉ giữ tối đa 12 tháng để xử lý vi phạm và phòng chống lạm dụng, '
          'rồi máy chủ tự xóa. Báo cáo về nội dung đã bị xóa cũng bị xóa, và '
          'báo cáo do chính bạn gửi được ẩn danh khi bạn xóa dữ liệu Cộng '
          'đồng.',
          lead: 'Báo cáo vi phạm:',
        ),
        LegalItem(
          'chỉ giữ mã băm có muối (của địa chỉ IP) để giới hạn số lần gửi yêu '
          'cầu; nhật ký kỹ thuật chỉ được giữ trong thời gian cần thiết để '
          'tìm lỗi và bảo mật.',
          lead: 'Nhật ký truy cập của máy chủ:',
        ),
        LegalItem(
          'giữ 14 ngày rồi bị ghi đè; nội dung đã xóa vì thế có thể còn trong '
          'bản sao lưu tối đa 14 ngày.',
          lead: 'Bản sao lưu:',
        ),
        LegalItem(
          'hết hiệu lực sau 30 ngày và bị xóa khỏi thiết bị khi bạn đăng xuất.',
          lead: 'Mã đăng nhập Cộng đồng:',
        ),
      ]),
    ]),
    LegalSection('Xóa dữ liệu', [
      LegalSubheading('Trên thiết bị'),
      LegalList([
        LegalItem(
          'Đăng xuất một tài khoản trong Cài đặt sẽ xóa khỏi thiết bị dữ liệu '
          'đăng nhập Riot (mã truy cập và cookie), thông tin đăng nhập đã '
          'lưu, mã đăng nhập Cộng đồng, dữ liệu tạm và thông báo đã lên lịch '
          'của tài khoản đó. Wishlist được giữ lại để dùng khi bạn đăng nhập '
          'lại; bạn có thể tự xóa từng mục.',
        ),
        LegalItem(
          '"Xóa dữ liệu tạm" trong Cài đặt > Nâng cao xóa ảnh, dữ liệu đã tải '
          'để xem khi không có mạng và báo lỗi đã ghi trên thiết bị.',
        ),
        LegalItem(
          'Gỡ Ứng dụng sẽ xóa toàn bộ dữ liệu của Ứng dụng trên thiết bị.',
        ),
      ]),
      LegalSubheading('Trên máy chủ Cộng đồng'),
      LegalList([
        LegalItem(
          'Bạn có thể tự xóa bài đăng, đánh giá, bình luận, bài tìm đồng đội và '
          'bỏ bình chọn ngay trong Ứng dụng.',
        ),
        LegalItem(
          'Để xóa toàn bộ dữ liệu Cộng đồng gắn với Riot ID của bạn, vào Cài '
          'đặt > "Dữ liệu Cộng đồng của bạn" > "Xóa dữ liệu Cộng đồng của '
          'tôi". Máy chủ sẽ xóa vĩnh viễn bài đăng, bình luận, đánh giá, lượt '
          'thích, bình chọn, bài tìm đồng đội, ảnh và tài khoản Cộng đồng của '
          'bạn. Việc này không thể hoàn tác. Bạn cũng có thể gửi email tới '
          '$_email kèm Riot ID; chúng tôi có thể yêu cầu xác minh bạn là chủ '
          'tài khoản và xử lý trong vòng 30 ngày.',
        ),
        LegalItem(
          'Hình ảnh: tệp ảnh bị xóa cùng bài đăng hoặc tài khoản. Ảnh của nội '
          'dung bị ẩn vì bị báo cáo sẽ không còn truy cập công khai được và bị '
          'xóa sau 30 ngày; ảnh đã tải lên nhưng không được dùng bị xóa sau 24 '
          'giờ. Khi bạn tải ảnh lên, máy chủ gỡ thông tin vị trí và các dữ '
          'liệu ẩn trong ảnh (siêu dữ liệu EXIF).',
        ),
        LegalItem(
          'Nội dung đã xóa có thể còn trong bản sao lưu tối đa 14 ngày trước '
          'khi bị ghi đè.',
        ),
        LegalItem(
          'Lưu ý: đăng xuất khỏi Ứng dụng không tự động xóa nội dung bạn đã '
          'đăng trên máy chủ Cộng đồng.',
        ),
      ]),
    ]),
    LegalSection('Thông báo và tác vụ nền', [
      LegalParagraph(
        'ValVN chỉ dùng thông báo cục bộ, tức là thông báo do chính thiết bị '
        'của bạn tạo ra. Chúng tôi không vận hành máy chủ gửi thông báo đẩy và '
        'không thu thập mã thiết bị. Ứng dụng đăng ký với hệ điều hành một '
        'tác vụ chạy nền định kỳ, chạy ngay trên thiết bị, để giữ đăng nhập '
        'Riot của bạn còn hiệu lực và, nếu bạn bật, đọc cửa hàng trực tiếp '
        'từ Riot để báo skin trong wishlist hoặc Chợ Đêm. Bạn có thể tắt '
        'thông báo trong Cài đặt của Ứng dụng hoặc của hệ điều hành.',
      ),
    ]),
    LegalSection('Phân tích, quảng cáo và theo dõi', [
      LegalParagraph(
        'ValVN không tích hợp công cụ phân tích, công cụ tự động báo cáo sự '
        'cố, quảng cáo hay công cụ theo dõi của bên thứ ba. ValVN không dùng '
        'mã định danh quảng cáo và không theo dõi bạn giữa các ứng dụng hay '
        'trang web. Nếu điều này thay đổi trong tương lai, chúng tôi sẽ cập '
        'nhật Chính sách và xin sự đồng ý của bạn khi pháp luật yêu cầu.',
      ),
    ]),
    LegalSection('Bảo mật dữ liệu', [
      LegalList([
        LegalItem(
          'Thông tin bí mật (dữ liệu đăng nhập Riot, thông tin đăng nhập đã '
          'lưu, mã đăng nhập Cộng đồng) chỉ được lưu trong vùng lưu trữ bảo '
          'mật của hệ điều hành (Keychain hoặc Keystore) và được xóa khi cài '
          'lại Ứng dụng.',
        ),
        LegalItem('Mọi kết nối mạng đều được mã hóa (HTTPS/TLS).'),
        LegalItem(
          'Báo lỗi được lọc tự động để loại bỏ dữ liệu đăng nhập Riot, mật '
          'khẩu và ID tài khoản.',
        ),
        LegalItem(
          'Máy chủ Cộng đồng chỉ lưu mã băm một chiều của PUUID; giới hạn số '
          'lần gửi yêu cầu (dựa trên mã băm có muối của địa chỉ IP); chỉ cho '
          'phép bạn xóa nội dung của chính mình; và giữ khóa bí mật trong '
          'phần thiết lập riêng của máy chủ, không đưa vào mã nguồn.',
        ),
        LegalItem(
          'Chúng tôi chỉ thu thập dữ liệu ở mức tối thiểu cần thiết cho tính '
          'năng.',
        ),
      ]),
      LegalParagraph(
        'Không có biện pháp nào an toàn tuyệt đối. Nếu xảy ra sự cố vi phạm dữ '
        'liệu cá nhân, chúng tôi sẽ thông báo cho cơ quan có thẩm quyền và '
        'người dùng bị ảnh hưởng theo quy định của pháp luật.',
      ),
    ]),
    LegalSection('Trẻ em', [
      LegalParagraph(
        'Ứng dụng không dành cho trẻ em dưới 13 tuổi. Ở những nơi pháp luật '
        'quy định độ tuổi tối thiểu để tự đồng ý xử lý dữ liệu cao hơn (ví dụ '
        '16 tuổi ở một số nước thuộc Liên minh châu Âu), bạn chỉ được sử dụng '
        'Ứng dụng, đặc biệt là tính năng Cộng đồng, khi đã đủ tuổi đó hoặc khi '
        'có sự đồng ý và giám sát của cha, mẹ hoặc người giám hộ hợp pháp. '
        'Nếu bạn là phụ huynh và cho rằng con mình đã cung cấp dữ liệu cho '
        'Cộng đồng khi chưa có sự đồng ý, vui lòng liên hệ để chúng tôi xóa dữ '
        'liệu đó.',
      ),
    ]),
    LegalSection('Quyền của bạn', [
      LegalParagraph(
        'Theo pháp luật Việt Nam về bảo vệ dữ liệu cá nhân (bao gồm Nghị định '
        '13/2023/NĐ-CP), bạn có các quyền sau:',
      ),
      LegalList([
        LegalItem(
          'được biết về hoạt động xử lý dữ liệu của mình;',
          lead: 'Quyền được biết:',
        ),
        LegalItem(
          'đồng ý hoặc không đồng ý cho xử lý dữ liệu;',
          lead: 'Quyền đồng ý:',
        ),
        LegalItem(
          'xem, chỉnh sửa hoặc yêu cầu chỉnh sửa dữ liệu của mình;',
          lead: 'Quyền truy cập:',
        ),
        LegalItem(
          'rút lại sự đồng ý đã cho;',
          lead: 'Quyền rút lại sự đồng ý:',
        ),
        LegalItem('yêu cầu xóa dữ liệu của mình;', lead: 'Quyền xóa dữ liệu:'),
        LegalItem(
          'yêu cầu hạn chế xử lý dữ liệu;',
          lead: 'Quyền hạn chế xử lý:',
        ),
        LegalItem(
          'yêu cầu được cung cấp dữ liệu của mình;',
          lead: 'Quyền được cung cấp dữ liệu:',
        ),
        LegalItem(
          'phản đối việc xử lý dữ liệu nhằm mục đích không mong muốn;',
          lead: 'Quyền phản đối xử lý:',
        ),
        LegalItem(
          'khiếu nại, tố cáo, khởi kiện và yêu cầu bồi thường thiệt hại theo '
          'quy định của pháp luật;',
          lead: 'Quyền khiếu nại và yêu cầu bồi thường:',
        ),
        LegalItem(
          'tự bảo vệ dữ liệu cá nhân của mình.',
          lead: 'Quyền tự bảo vệ:',
        ),
      ]),
      LegalParagraph(
        'Phần lớn dữ liệu nằm trên thiết bị và bạn có thể tự xem hoặc xóa ngay '
        'trong Ứng dụng. Với dữ liệu trên máy chủ Cộng đồng, hãy gửi yêu cầu '
        'tới $_email. Chúng tôi xử lý yêu cầu trong vòng 30 ngày và có thể cần '
        'xác minh danh tính của bạn trước khi xử lý. Bạn cũng có thể tự tải '
        'bản sao dữ liệu Cộng đồng của mình (tệp JSON) tại Cài đặt > "Dữ liệu '
        'Cộng đồng của bạn" > "Tải dữ liệu của tôi", và tự xóa dữ liệu đó '
        'ngay tại đây.',
      ),
    ]),
    LegalSection('Quyền của bạn theo luật nơi bạn sống', [
      LegalParagraph(
        'Tùy nơi bạn sống, pháp luật địa phương có thể cho bạn thêm quyền. '
        'Dù bạn ở đâu, bạn đều có thể thực hiện các quyền thực tế dưới đây '
        'bằng cách gửi email tới $_email; chúng tôi xử lý yêu cầu trong vòng '
        '30 ngày và không phân biệt đối xử với bạn vì đã thực hiện quyền của '
        'mình.',
      ),
      LegalList([
        LegalItem(
          'biết chúng tôi giữ dữ liệu gì về bạn và nhận một bản sao;',
          lead: 'Truy cập:',
        ),
        LegalItem(
          'yêu cầu xóa dữ liệu Cộng đồng gắn với Riot ID của bạn (xem mục '
          '"Xóa dữ liệu");',
          lead: 'Xóa:',
        ),
        LegalItem(
          'sửa dữ liệu không chính xác (hồ sơ Cộng đồng được làm mới từ tài '
          'khoản Riot mỗi lần bạn kết nối);',
          lead: 'Chỉnh sửa:',
        ),
        LegalItem(
          'nhận dữ liệu của bạn ở định dạng thông dụng;',
          lead: 'Di chuyển dữ liệu:',
        ),
        LegalItem(
          'phản đối hoặc yêu cầu hạn chế việc xử lý, và rút lại sự đồng ý bất '
          'cứ lúc nào;',
          lead: 'Phản đối, hạn chế và rút lại đồng ý:',
        ),
        LegalItem(
          'khiếu nại tới cơ quan bảo vệ dữ liệu có thẩm quyền ở nơi bạn sống.',
          lead: 'Khiếu nại:',
        ),
      ]),
      LegalParagraph('Một số ví dụ về luật có thể áp dụng cho bạn:'),
      LegalList([
        LegalItem(
          'nếu bạn ở Liên minh châu Âu, Khu vực kinh tế châu Âu hoặc Vương quốc '
          'Anh: bạn có các quyền truy cập, chỉnh sửa, xóa, hạn chế, di chuyển '
          'dữ liệu, phản đối và rút lại sự đồng ý, cùng quyền khiếu nại tới cơ '
          'quan giám sát dữ liệu tại quốc gia bạn sống. Cơ sở xử lý dữ liệu '
          'được nêu ở mục "Cơ sở pháp lý".',
          lead: 'GDPR / UK GDPR:',
        ),
        LegalItem(
          'nếu bạn là cư dân California: bạn có quyền biết, xóa, sửa dữ liệu '
          'và từ chối việc "bán" hay "chia sẻ" dữ liệu. ValVN không bán và '
          'không chia sẻ dữ liệu cá nhân cho quảng cáo theo ngữ cảnh khác.',
          lead: 'CCPA / CPRA:',
        ),
        LegalItem(
          'nếu bạn ở Brazil: bạn có các quyền truy cập, chỉnh sửa, ẩn danh, '
          'xóa, di chuyển dữ liệu và thông tin về việc chia sẻ dữ liệu.',
          lead: 'LGPD:',
        ),
        LegalItem(
          'nếu bạn ở Trung Quốc đại lục hoặc nơi có luật tương tự: bạn có '
          'quyền biết, quyết định, hạn chế, từ chối, truy cập, sao chép, '
          'chỉnh sửa, xóa dữ liệu và yêu cầu giải thích về việc xử lý.',
          lead: 'PIPL và luật tương tự:',
        ),
        LegalItem(
          'nếu bạn ở Việt Nam: các quyền nêu ở mục "Quyền của bạn" ở trên.',
          lead: 'Nghị định 13/2023/NĐ-CP:',
        ),
      ]),
      LegalParagraph(
        'Chúng tôi không thu thập nhiều dữ liệu hơn mức cần thiết và không '
        'thực hiện quyết định tự động có ảnh hưởng pháp lý tới bạn. Nếu bạn '
        'không hài lòng với phản hồi của chúng tôi, bạn có quyền khiếu nại tới '
        'cơ quan có thẩm quyền ở nơi bạn sống.',
      ),
    ]),
    LegalSection('Thay đổi Chính sách', [
      LegalParagraph(
        'Chúng tôi có thể cập nhật Chính sách này khi Ứng dụng hoặc quy định '
        'pháp luật thay đổi. Phiên bản và ngày hiệu lực luôn được ghi ở đầu văn '
        'bản. Với thay đổi quan trọng về cách xử lý dữ liệu, chúng tôi sẽ thông '
        'báo trong Ứng dụng và xin lại sự đồng ý của bạn khi cần.',
      ),
    ]),
    LegalSection('Liên hệ', [
      LegalParagraph(
        'Mọi câu hỏi hoặc yêu cầu về quyền riêng tư và dữ liệu cá nhân, vui '
        'lòng liên hệ:',
      ),
      LegalList([
        LegalItem(_publisher, lead: 'Bên kiểm soát dữ liệu:'),
        LegalItem(_email, lead: 'Email:'),
      ]),
    ]),
  ],
);
