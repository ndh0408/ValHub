import 'legal_document.dart';
import 'legal_info.dart';

const _publisher = LegalInfo.publisherName;
const _email = LegalInfo.contactEmail;

/// Điều khoản sử dụng ValVN.
const termsOfService = LegalDocument(
  id: 'terms',
  title: 'Điều khoản sử dụng',
  summary: 'Quy định khi bạn tải, cài đặt và sử dụng ValVN',
  version: '1.0',
  preamble: [
    LegalParagraph(
      'Chào mừng bạn đến với ValVN. Điều khoản sử dụng này ("Điều khoản") là '
      'thỏa thuận ràng buộc giữa bạn và $_publisher ("chúng tôi") về việc tải, '
      'cài đặt và sử dụng ứng dụng ValVN trên iOS và Android, bao gồm cả các '
      'tính năng Cộng đồng (gọi chung là "Ứng dụng").',
    ),
    LegalCallout(
      'Tóm tắt: ValVN là ứng dụng đồng hành không chính thức, không thuộc Riot '
      'Games. Bạn đăng nhập bằng tài khoản Riot của chính mình trên trang chính '
      'thức của Riot, tự chịu trách nhiệm về tài khoản và mọi thao tác bạn thực '
      'hiện, cư xử văn minh trong Cộng đồng và không dùng ứng dụng để gian lận, '
      'tự động hóa hay khai thác trái phép. Ứng dụng được cung cấp nguyên trạng.',
    ),
  ],
  sections: [
    LegalSection('Chấp nhận Điều khoản', [
      LegalParagraph(
        'Bằng việc tải, cài đặt, đăng nhập hoặc tiếp tục sử dụng Ứng dụng, bạn '
        'xác nhận đã đọc, hiểu và đồng ý với Điều khoản này, Chính sách quyền '
        'riêng tư và Tiêu chuẩn cộng đồng của ValVN. Các văn bản này là một '
        'phần không tách rời của Điều khoản.',
      ),
      LegalParagraph(
        'Nếu bạn không đồng ý với bất kỳ nội dung nào, vui lòng không sử dụng '
        'Ứng dụng và gỡ Ứng dụng khỏi thiết bị.',
      ),
    ]),
    LegalSection('Giải thích từ ngữ', [
      LegalList([
        LegalItem(
          'ứng dụng ValVN, các bản cập nhật, nội dung và dịch vụ đi kèm do '
          'chúng tôi cung cấp.',
          lead: '"Ứng dụng":',
        ),
        LegalItem(
          'tài khoản của bạn tại Riot Games dùng để chơi VALORANT.',
          lead: '"Tài khoản Riot":',
        ),
        LegalItem(
          'các tính năng xã hội của ValVN như bảng tin, bài đăng, hình ảnh, '
          'bình luận, lượt thích, bình chọn skin và tìm đồng đội (LFG), vận '
          'hành trên máy chủ cộng đồng của ValVN.',
          lead: '"Cộng đồng":',
        ),
        LegalItem(
          'mọi văn bản, hình ảnh, mã tổ đội, bình chọn, báo cáo và thông tin '
          'khác bạn gửi lên Cộng đồng.',
          lead: '"Nội dung người dùng":',
        ),
      ]),
    ]),
    LegalSection('Điều kiện sử dụng', [
      LegalList([
        LegalItem(
          'Bạn phải đủ điều kiện sở hữu và sử dụng Tài khoản Riot theo điều '
          'khoản của Riot Games, và từ đủ 13 tuổi trở lên.',
        ),
        LegalItem(
          'Nếu bạn dưới 16 tuổi, bạn chỉ được sử dụng Ứng dụng khi cha, mẹ '
          'hoặc người giám hộ hợp pháp đã đọc, đồng ý với Điều khoản này và '
          'Chính sách quyền riêng tư, đồng thời giám sát việc sử dụng của bạn.',
        ),
        LegalItem(
          'Bạn không thuộc đối tượng bị pháp luật hiện hành cấm sử dụng dịch vụ '
          'và chưa từng bị chúng tôi chấm dứt quyền sử dụng Ứng dụng.',
        ),
        LegalItem(
          'Bạn tự chịu trách nhiệm về thiết bị, kết nối mạng và chi phí dữ '
          'liệu di động phát sinh khi sử dụng Ứng dụng.',
        ),
      ]),
    ]),
    LegalSection('Tài khoản Riot và thông tin đăng nhập', [
      LegalParagraph(
        'Bạn đăng nhập trong một cửa sổ web hiển thị trang đăng nhập chính thức '
        'của Riot Games. ValVN không nhận, không đọc và không lưu mật khẩu mà '
        'bạn nhập vào trang đó. Sau khi đăng nhập, phiên đăng nhập (token và '
        'cookie) chỉ được lưu trong vùng lưu trữ bảo mật của hệ điều hành trên '
        'thiết bị của bạn.',
      ),
      LegalList([
        LegalItem(
          'Bạn chỉ được thêm vào Ứng dụng những Tài khoản Riot mà bạn sở hữu '
          'hoặc được chủ sở hữu cho phép hợp pháp.',
        ),
        LegalItem(
          'Bạn chịu trách nhiệm giữ an toàn thiết bị, mật khẩu, mã xác thực '
          'hai lớp và mọi hoạt động diễn ra trên Tài khoản Riot của mình.',
        ),
        LegalItem(
          'Tính năng "Ghi chú đăng nhập" là tùy chọn: nếu bạn tự lưu tên đăng '
          'nhập và mật khẩu, chúng chỉ nằm trong vùng lưu trữ bảo mật trên '
          'thiết bị và chỉ được điền vào trang đăng nhập của Riot khi bạn yêu '
          'cầu. Bạn cân nhắc rủi ro khi lưu mật khẩu trên thiết bị dùng chung '
          'và có thể xóa ghi chú bất cứ lúc nào.',
        ),
        LegalItem(
          'Hãy đăng xuất khỏi Ứng dụng và đổi mật khẩu Riot ngay nếu bạn nghi '
          'ngờ thiết bị hoặc tài khoản bị truy cập trái phép.',
        ),
        LegalItem(
          'Việc sử dụng Tài khoản Riot luôn phải tuân thủ Điều khoản dịch vụ và '
          'các chính sách của Riot Games. Riot Games có thể hạn chế hoặc khóa '
          'tài khoản của bạn theo chính sách riêng của họ; chúng tôi không có '
          'quyền can thiệp vào các quyết định đó.',
        ),
      ]),
    ]),
    LegalSection('Quyền sử dụng Ứng dụng', [
      LegalParagraph(
        'Với điều kiện bạn tuân thủ Điều khoản này, chúng tôi cấp cho bạn quyền '
        'có giới hạn, không độc quyền, không thể chuyển nhượng, không thể cấp '
        'phép lại và có thể thu hồi để cài đặt và sử dụng Ứng dụng trên các '
        'thiết bị mà bạn sở hữu hoặc kiểm soát, cho mục đích cá nhân, phi '
        'thương mại.',
      ),
      LegalParagraph(
        'ValVN là phần mềm độc quyền, không phải phần mềm mã nguồn mở. Chúng '
        'tôi cấp phép sử dụng chứ không bán Ứng dụng cho bạn; mọi quyền không '
        'được cấp rõ ràng trong Điều khoản này đều được bảo lưu.',
      ),
    ]),
    LegalSection('Các hành vi bị cấm', [
      LegalParagraph('Khi sử dụng Ứng dụng, bạn không được:'),
      LegalList([
        LegalItem(
          'Sao chép, sửa đổi, dịch ngược, giải mã, tháo rời, tạo tác phẩm phái '
          'sinh hoặc cố gắng trích xuất mã nguồn của Ứng dụng, trừ khi pháp '
          'luật bắt buộc cho phép.',
        ),
        LegalItem(
          'Bán, cho thuê, cho mượn, phân phối lại, đăng tải lại hoặc khai thác '
          'thương mại Ứng dụng hay bất kỳ phần nào của Ứng dụng.',
        ),
        LegalItem(
          'Dùng Ứng dụng, bot, script hoặc công cụ tự động để gian lận, can '
          'thiệp vào trò chơi, thu thập dữ liệu hàng loạt, spam hàng chờ, hoặc '
          'bất kỳ hành vi nào vi phạm chính sách của Riot Games.',
        ),
        LegalItem(
          'Truy cập hoặc cố truy cập tài khoản, dữ liệu, máy chủ hay hệ thống '
          'mà bạn không được phép; vượt qua giới hạn tần suất, cơ chế bảo mật '
          'hoặc kiểm duyệt của Ứng dụng và máy chủ cộng đồng.',
        ),
        LegalItem(
          'Mạo danh người khác, cung cấp thông tin sai lệch về danh tính hoặc '
          'Riot ID, hoặc sử dụng tài khoản của người khác khi chưa được phép.',
        ),
        LegalItem(
          'Phát tán mã độc, gây quá tải, làm gián đoạn hoặc làm suy giảm hoạt '
          'động của Ứng dụng, máy chủ cộng đồng hay dịch vụ của bên thứ ba.',
        ),
        LegalItem(
          'Sử dụng Ứng dụng cho mục đích trái pháp luật Việt Nam hoặc pháp luật '
          'nơi bạn cư trú.',
        ),
      ]),
    ]),
    LegalSection('Thao tác trên Tài khoản Riot', [
      LegalParagraph(
        'Một số tính năng cho phép thay đổi trạng thái Tài khoản Riot của bạn, '
        'ví dụ: thay đổi trang bị (loadout), chọn hoặc khóa đặc vụ, tham gia '
        'hay rời tổ đội, bắt đầu hoặc hủy tìm trận, rời trận đấu.',
      ),
      LegalList([
        LegalItem(
          'Các thao tác này chỉ được thực hiện khi chính bạn bấm nút tương ứng; '
          'Ứng dụng không tự động thực hiện thay bạn.',
        ),
        LegalItem(
          'Với thao tác có thể dẫn đến hình phạt trong trò chơi (ví dụ rời trận, '
          'né trận), Ứng dụng sẽ hiển thị cảnh báo và yêu cầu bạn xác nhận.',
        ),
        LegalItem(
          'Bạn hoàn toàn chịu trách nhiệm về hậu quả của các thao tác mình thực '
          'hiện, bao gồm hình phạt, mất điểm xếp hạng (RR), hạn chế hàng chờ '
          'hoặc biện pháp khác do Riot Games áp dụng.',
        ),
      ]),
    ]),
    LegalSection('Cộng đồng và nội dung người dùng', [
      LegalSubheading('Xác minh Riot ID'),
      LegalParagraph(
        'Để dùng Cộng đồng, Ứng dụng xác minh Riot ID của bạn với Riot Games '
        'thông qua máy chủ cộng đồng của ValVN như mô tả trong Chính sách '
        'quyền riêng tư. Tên hiển thị của bạn trong Cộng đồng là Riot ID đã '
        'được xác minh, kèm thẻ người chơi, rank và khu vực.',
      ),
      LegalSubheading('Trách nhiệm với nội dung'),
      LegalList([
        LegalItem(
          'Bạn chịu trách nhiệm về mọi Nội dung người dùng bạn đăng và cam kết '
          'có đủ quyền đối với nội dung đó (ví dụ quyền sử dụng ảnh chụp màn '
          'hình, hình ảnh bạn tải lên).',
        ),
        LegalItem(
          'Nội dung của bạn phải tuân thủ Tiêu chuẩn cộng đồng và pháp luật. '
          'Nghiêm cấm nội dung vi phạm pháp luật Việt Nam, xúc phạm, quấy rối, '
          'thù ghét, khiêu dâm, bạo lực, lừa đảo, spam, quảng cáo trái phép, '
          'mua bán tài khoản, dịch vụ cày thuê hoặc phần mềm gian lận, và nội '
          'dung tiết lộ thông tin cá nhân của người khác.',
        ),
        LegalItem(
          'Bài tìm đồng đội có thể chứa mã tổ đội; bất kỳ ai xem bài đều có thể '
          'dùng mã đó để vào tổ đội của bạn cho đến khi bài hết hạn (30 phút) '
          'hoặc bạn tắt mã trong trò chơi.',
        ),
      ]),
      LegalSubheading('Quyền bạn cấp cho chúng tôi'),
      LegalParagraph(
        'Bạn vẫn là chủ sở hữu Nội dung người dùng của mình. Khi đăng, bạn cấp '
        'cho chúng tôi quyền không độc quyền, miễn phí, có hiệu lực trên toàn '
        'thế giới để lưu trữ, sao chép kỹ thuật, định dạng lại (ví dụ nén hoặc '
        'đổi kích thước ảnh) và hiển thị nội dung đó cho người dùng khác trong '
        'Ứng dụng, chỉ nhằm mục đích vận hành Cộng đồng. Quyền này chấm dứt khi '
        'nội dung bị xóa khỏi hệ thống, trừ bản sao lưu còn tồn tại trong thời '
        'gian ngắn hoặc trường hợp pháp luật yêu cầu lưu giữ.',
      ),
      LegalSubheading('Báo cáo và kiểm duyệt'),
      LegalList([
        LegalItem(
          'Bạn có thể báo cáo bài đăng, bình luận hoặc bài tìm đồng đội vi '
          'phạm ngay trong Ứng dụng. Nội dung nhận đủ số báo cáo từ nhiều '
          'người dùng khác nhau có thể bị tự động ẩn trong khi chờ xem xét.',
        ),
        LegalItem(
          'Chúng tôi có quyền, nhưng không có nghĩa vụ, xem xét, ẩn, gỡ bỏ nội '
          'dung, hạn chế hoặc khóa quyền sử dụng Cộng đồng của bất kỳ ai vi phạm '
          'Điều khoản hoặc Tiêu chuẩn cộng đồng, có hoặc không cần báo trước.',
        ),
        LegalItem(
          'Chúng tôi không kiểm tra trước mọi nội dung và không chịu trách '
          'nhiệm về Nội dung người dùng do người khác đăng. Quan điểm trong nội '
          'dung đó thuộc về người đăng.',
        ),
        LegalItem(
          'Chúng tôi có thể cung cấp thông tin cho cơ quan nhà nước có thẩm '
          'quyền khi có yêu cầu hợp pháp.',
        ),
      ]),
    ]),
    LegalSection('Quyền sở hữu trí tuệ', [
      LegalParagraph(
        'Ứng dụng, bao gồm mã nguồn, thiết kế giao diện, biểu tượng, tên và '
        'logo ValVN, văn bản và các tài liệu đi kèm, thuộc quyền sở hữu của '
        '$_publisher và được bảo hộ theo pháp luật về sở hữu trí tuệ.',
      ),
      LegalParagraph(
        'VALORANT, Riot Games cùng tên, hình ảnh, biểu tượng và nội dung trong '
        'trò chơi (skin, đặc vụ, bản đồ, rank…) thuộc quyền sở hữu của Riot '
        'Games, Inc. và được hiển thị trong Ứng dụng chỉ nhằm mục đích tham '
        'chiếu cho người chơi. Việc hiển thị này không chuyển giao cho bạn hay '
        'cho chúng tôi bất kỳ quyền nào đối với các tài sản đó.',
      ),
    ]),
    LegalSection('Dịch vụ của bên thứ ba', [
      LegalParagraph('Ứng dụng hoạt động dựa trên các dịch vụ bên thứ ba sau:'),
      LegalList([
        LegalItem(
          'đăng nhập, dữ liệu tài khoản, cửa hàng, bộ sưu tập, trận đấu, bạn bè '
          'và trò chuyện được lấy trực tiếp từ máy chủ của Riot Games.',
          lead: 'Riot Games:',
        ),
        LegalItem(
          'tên, hình ảnh và dữ liệu công khai của vật phẩm, đặc vụ, bản đồ, '
          'rank do một dự án cộng đồng độc lập cung cấp.',
          lead: 'valorant-api.com:',
        ),
        LegalItem(
          'hạ tầng lưu trữ và vận hành máy chủ cộng đồng của ValVN.',
          lead: 'Cloudflare:',
        ),
        LegalItem(
          'phân phối Ứng dụng và cập nhật.',
          lead: 'App Store và Google Play:',
        ),
      ]),
      LegalParagraph(
        'Các dịch vụ này có điều khoản và chính sách riêng mà bạn cần tuân thủ. '
        'Chúng tôi không kiểm soát và không chịu trách nhiệm về tính sẵn sàng, '
        'độ chính xác hay thay đổi của các dịch vụ đó. Nếu Riot Games thay đổi '
        'hoặc ngừng cung cấp giao diện kỹ thuật mà Ứng dụng sử dụng, một số '
        'tính năng có thể tạm thời hoặc vĩnh viễn không hoạt động.',
      ),
    ]),
    LegalSection('Không phải sản phẩm chính thức của Riot Games', [
      LegalParagraph(
        'ValVN là ứng dụng độc lập, không được Riot Games xác nhận, tài trợ, '
        'giám sát hay liên kết dưới bất kỳ hình thức nào, và không phản ánh '
        'quan điểm của Riot Games hay bất kỳ ai tham gia sản xuất hoặc quản lý '
        'các sản phẩm của Riot Games. Riot Games không chịu trách nhiệm hỗ trợ '
        'cho Ứng dụng; vui lòng liên hệ chúng tôi thay vì Riot Games khi có vấn '
        'đề với ValVN.',
      ),
    ]),
    LegalSection('Miễn trừ bảo đảm', [
      LegalParagraph(
        'Trong phạm vi tối đa pháp luật cho phép, Ứng dụng được cung cấp "nguyên '
        'trạng" và "theo khả năng sẵn có", không kèm bất kỳ bảo đảm nào, dù rõ '
        'ràng hay ngụ ý, bao gồm bảo đảm về khả năng thương mại, sự phù hợp cho '
        'một mục đích cụ thể, tính chính xác hoặc không vi phạm.',
      ),
      LegalParagraph(
        'Chúng tôi không bảo đảm Ứng dụng hoạt động liên tục, không có lỗi, '
        'tương thích với mọi thiết bị, hay dữ liệu hiển thị (giá, cửa hàng, '
        'thống kê, thời gian làm mới, thông báo) luôn đầy đủ, chính xác và kịp '
        'thời. Thông báo cửa hàng và wishlist phụ thuộc vào hệ điều hành và có '
        'thể đến muộn hoặc không đến.',
      ),
    ]),
    LegalSection('Giới hạn trách nhiệm', [
      LegalParagraph(
        'Trong phạm vi tối đa pháp luật cho phép, chúng tôi không chịu trách '
        'nhiệm đối với bất kỳ thiệt hại gián tiếp, ngẫu nhiên, đặc biệt hay hệ '
        'quả nào, bao gồm mất dữ liệu, mất vật phẩm hay tiền ảo trong trò chơi, '
        'mất điểm xếp hạng, hình phạt hoặc việc Tài khoản Riot bị hạn chế hay '
        'khóa, phát sinh từ hoặc liên quan đến việc bạn sử dụng hay không thể '
        'sử dụng Ứng dụng.',
      ),
      LegalParagraph(
        'Vì Ứng dụng được cung cấp miễn phí, tổng trách nhiệm của chúng tôi đối '
        'với mọi khiếu nại liên quan đến Ứng dụng, trong phạm vi pháp luật cho '
        'phép, không vượt quá số tiền bạn đã trả trực tiếp cho chúng tôi để sử '
        'dụng Ứng dụng trong 12 tháng trước sự kiện phát sinh khiếu nại (nếu '
        'có). Điều khoản này không loại trừ trách nhiệm mà pháp luật Việt Nam '
        'không cho phép loại trừ, bao gồm quyền của người tiêu dùng theo Luật '
        'Bảo vệ quyền lợi người tiêu dùng.',
      ),
    ]),
    LegalSection('Trách nhiệm bồi hoàn', [
      LegalParagraph(
        'Bạn đồng ý bồi hoàn và bảo vệ chúng tôi khỏi các khiếu nại, thiệt hại '
        'và chi phí hợp lý (bao gồm phí luật sư) phát sinh từ việc bạn vi phạm '
        'Điều khoản này, vi phạm quyền của bên thứ ba hoặc từ Nội dung người '
        'dùng mà bạn đăng tải.',
      ),
    ]),
    LegalSection('Tạm ngừng và chấm dứt', [
      LegalList([
        LegalItem(
          'Bạn có thể ngừng sử dụng bất cứ lúc nào bằng cách đăng xuất và gỡ '
          'Ứng dụng. Cách xóa dữ liệu Cộng đồng trên máy chủ được hướng dẫn '
          'trong Chính sách quyền riêng tư.',
        ),
        LegalItem(
          'Chúng tôi có thể tạm ngừng hoặc chấm dứt quyền sử dụng Ứng dụng hay '
          'Cộng đồng của bạn nếu bạn vi phạm Điều khoản, theo yêu cầu của cơ '
          'quan có thẩm quyền, hoặc để bảo vệ người dùng khác và hệ thống.',
        ),
        LegalItem(
          'Chúng tôi có thể thay đổi, tạm ngừng hoặc ngừng cung cấp toàn bộ '
          'hay một phần Ứng dụng, và sẽ cố gắng thông báo trước trong Ứng dụng '
          'khi hợp lý.',
        ),
        LegalItem(
          'Khi chấm dứt, quyền sử dụng được cấp cho bạn chấm dứt ngay; các điều '
          'khoản về sở hữu trí tuệ, miễn trừ bảo đảm, giới hạn trách nhiệm, bồi '
          'hoàn và giải quyết tranh chấp vẫn còn hiệu lực.',
        ),
      ]),
    ]),
    LegalSection('Thay đổi Điều khoản', [
      LegalParagraph(
        'Chúng tôi có thể cập nhật Điều khoản theo thời gian. Phiên bản và ngày '
        'hiệu lực luôn được ghi ở đầu văn bản. Với thay đổi quan trọng, chúng '
        'tôi sẽ thông báo trong Ứng dụng trước khi thay đổi có hiệu lực. Việc '
        'bạn tiếp tục sử dụng Ứng dụng sau ngày hiệu lực đồng nghĩa với việc '
        'bạn chấp nhận Điều khoản đã cập nhật.',
      ),
    ]),
    LegalSection('Luật áp dụng và giải quyết tranh chấp', [
      LegalParagraph(
        'Điều khoản này được điều chỉnh và giải thích theo pháp luật nước Cộng '
        'hòa xã hội chủ nghĩa Việt Nam.',
      ),
      LegalParagraph(
        'Mọi tranh chấp phát sinh trước hết được giải quyết thông qua thương '
        'lượng, hòa giải thiện chí. Bạn vui lòng liên hệ chúng tôi qua email '
        'để cùng giải quyết. Nếu không thể giải quyết trong vòng 30 ngày kể từ '
        'ngày một bên thông báo tranh chấp, tranh chấp sẽ được đưa ra Tòa án '
        'nhân dân có thẩm quyền tại Việt Nam, trừ khi pháp luật về bảo vệ quyền '
        'lợi người tiêu dùng cho phép bạn lựa chọn cơ chế khác.',
      ),
    ]),
    LegalSection('Điều khoản chung', [
      LegalList([
        LegalItem(
          'Nếu một điều khoản bị cơ quan có thẩm quyền tuyên vô hiệu, các điều '
          'khoản còn lại vẫn giữ nguyên hiệu lực.',
        ),
        LegalItem(
          'Việc chúng tôi chưa thực thi một quyền không có nghĩa là từ bỏ quyền '
          'đó.',
        ),
        LegalItem(
          'Bạn không được chuyển giao quyền và nghĩa vụ theo Điều khoản này khi '
          'chưa có sự đồng ý bằng văn bản của chúng tôi.',
        ),
        LegalItem(
          'Điều khoản được lập bằng tiếng Việt. Nếu có bản dịch sang ngôn ngữ '
          'khác và có mâu thuẫn, bản tiếng Việt được ưu tiên áp dụng.',
        ),
      ]),
    ]),
    LegalSection('Liên hệ', [
      LegalParagraph(
        'Mọi câu hỏi, góp ý hoặc khiếu nại về Điều khoản này, vui lòng liên hệ:',
      ),
      LegalList([
        LegalItem(_publisher, lead: 'Nhà phát hành:'),
        LegalItem(_email, lead: 'Email:'),
      ]),
    ]),
  ],
);
