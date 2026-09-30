import 'legal_document.dart';
import 'legal_info.dart';

const _email = LegalInfo.contactEmail;

/// Tiêu chuẩn cộng đồng ValVN (posts, comments, images, LFG, votes).
const communityGuidelines = LegalDocument(
  id: 'community',
  title: 'Tiêu chuẩn cộng đồng',
  summary: 'Quy tắc khi đăng bài, bình luận và tìm đồng đội',
  version: '1.0',
  preamble: [
    LegalParagraph(
      'Cộng đồng ValVN là nơi người chơi VALORANT khoe cửa hàng, bàn chuyện '
      'skin, tìm đồng đội và giúp nhau leo rank. Để nơi này luôn vui và an '
      'toàn, hãy cùng nhau giữ những quy tắc dưới đây. Tiêu chuẩn này là một '
      'phần của Điều khoản sử dụng.',
    ),
  ],
  sections: [
    LegalSection('Tôn trọng mọi người', [
      LegalList([
        LegalItem(
          'Tranh luận về lối chơi, meta hay skin thoải mái, nhưng hãy nhắm vào '
          'ý kiến chứ không nhắm vào con người.',
        ),
        LegalItem(
          'Không xúc phạm, chửi bới, quấy rối, đe dọa, bắt nạt hay kích động '
          'người khác quấy rối một ai đó.',
        ),
        LegalItem(
          'Không phân biệt đối xử hay thù ghét dựa trên dân tộc, vùng miền, '
          'giới tính, tôn giáo, khuyết tật, xu hướng tính dục hay bất kỳ đặc '
          'điểm cá nhân nào.',
        ),
        LegalItem(
          'Không mạo danh người khác, streamer, tuyển thủ hay Riot Games.',
        ),
      ]),
    ]),
    LegalSection('Nội dung không được phép', [
      LegalList([
        LegalItem(
          'Nội dung vi phạm pháp luật áp dụng (pháp luật Việt Nam và pháp luật '
          'nơi bạn sống), kích động bạo lực hay thù ghét, gây phương hại đến '
          'an toàn của người khác hoặc trật tự an toàn xã hội.',
        ),
        LegalItem(
          'Nội dung khiêu dâm, gợi dục, đặc biệt là liên quan đến trẻ em.',
        ),
        LegalItem(
          'Hình ảnh bạo lực, máu me gây sốc, tự hại hoặc cổ vũ hành vi nguy hiểm.',
        ),
        LegalItem(
          'Thông tin sai sự thật có chủ đích, tin giả, lừa đảo, mạo danh sự '
          'kiện tặng quà hay "hack VP miễn phí".',
        ),
        LegalItem(
          'Nội dung vi phạm bản quyền hoặc quyền sở hữu trí tuệ của người khác.',
        ),
      ]),
    ]),
    LegalSection('Gian lận, mua bán và quảng cáo', [
      LegalList([
        LegalItem(
          'Không quảng bá, chia sẻ hay hỏi mua phần mềm gian lận, hack, macro, '
          'công cụ can thiệp trò chơi.',
        ),
        LegalItem(
          'Không mua bán, cho thuê, trao đổi tài khoản; không quảng cáo dịch vụ '
          'cày thuê (boosting), bán VP hay vật phẩm trái phép.',
        ),
        LegalItem(
          'Không spam, đăng lặp lại, quảng cáo hay dẫn liên kết tới trang web, '
          'nhóm hoặc dịch vụ thương mại khi chưa được phép.',
        ),
      ]),
    ]),
    LegalSection('Bảo vệ thông tin cá nhân', [
      LegalList([
        LegalItem(
          'Không đăng thông tin cá nhân của người khác (tên thật, số điện '
          'thoại, địa chỉ, ảnh riêng tư…) khi chưa có sự đồng ý của họ.',
        ),
        LegalItem(
          'Không bao giờ chia sẻ mật khẩu, mã xác thực hay email đăng nhập Riot '
          'của bạn. ValVN và đội ngũ kiểm duyệt không bao giờ hỏi những thông '
          'tin này.',
        ),
        LegalItem(
          'Cẩn thận khi chụp màn hình: hãy che thông tin bạn không muốn công khai.',
        ),
      ]),
    ]),
    LegalSection('Tìm đồng đội', [
      LegalList([
        LegalItem(
          'Chỉ đăng khi bạn thực sự đang tìm người, với đúng khu vực, chế độ '
          'chơi và số chỗ trống.',
        ),
        LegalItem(
          'Mã tổ đội trong bài hiển thị với mọi người xem bài. Bài tự hết hạn '
          'sau 30 phút; hãy xóa bài hoặc tắt mã trong trò chơi khi đã đủ người.',
        ),
        LegalItem(
          'Không dùng bài tìm đồng đội để spam, quảng cáo hay dẫn dụ người khác '
          'vào tổ đội nhằm quấy rối, phá game.',
        ),
        LegalItem(
          'Khi vào trận, hãy cư xử như một đồng đội tốt: không cố tình phá '
          'trận, không bỏ mặc đồng đội (AFK), không chửi bới hay công kích ai.',
        ),
      ]),
    ]),
    LegalSection('Hình ảnh và bình chọn', [
      LegalList([
        LegalItem(
          'Chỉ đăng hình ảnh bạn có quyền sử dụng và phù hợp với tiêu chuẩn này; '
          'ảnh chụp cửa hàng, bộ sưu tập, khoảnh khắc trong trận đều được chào '
          'đón.',
        ),
        LegalItem(
          'Mỗi tài khoản chỉ có một phiếu cho mỗi skin. Không dùng nhiều tài '
          'khoản hay công cụ tự động để thao túng bảng xếp hạng.',
        ),
      ]),
    ]),
    LegalSection('Báo cáo vi phạm', [
      LegalParagraph(
        'Thấy nội dung vi phạm? Hãy dùng nút Báo cáo trên bài đăng, bình luận '
        'hoặc bài tìm đồng đội và chọn lý do phù hợp. Báo cáo được giữ kín, '
        'người bị báo cáo không biết ai đã báo cáo.',
      ),
      LegalList([
        LegalItem(
          'Nội dung nhận đủ báo cáo từ nhiều người dùng khác nhau sẽ được tự '
          'động ẩn trong khi chờ xem xét.',
        ),
        LegalItem(
          'Với trường hợp khẩn cấp hoặc nghiêm trọng (đe dọa, nội dung liên '
          'quan đến trẻ em, lộ thông tin cá nhân), hãy báo cáo và gửi thêm '
          'email tới $_email.',
        ),
        LegalItem(
          'Không lạm dụng tính năng báo cáo để tấn công người khác; báo cáo sai '
          'sự thật lặp lại cũng là vi phạm.',
        ),
      ]),
    ]),
    LegalSection('Hậu quả khi vi phạm', [
      LegalParagraph(
        'Tùy mức độ và tần suất, chúng tôi có thể áp dụng một hoặc nhiều biện '
        'pháp sau, có hoặc không cần báo trước:',
      ),
      LegalList([
        LegalItem('Ẩn hoặc gỡ bỏ nội dung vi phạm.'),
        LegalItem(
          'Tạm thời hạn chế quyền đăng bài, bình luận, tìm đồng đội hoặc bình chọn.',
        ),
        LegalItem('Khóa vĩnh viễn quyền sử dụng Cộng đồng.'),
        LegalItem(
          'Cung cấp thông tin cho cơ quan có thẩm quyền đối với hành vi vi phạm '
          'pháp luật.',
        ),
      ]),
      LegalParagraph(
        'Các biện pháp này chỉ áp dụng trong ValVN và không ảnh hưởng tới Tài '
        'khoản Riot của bạn. Tuy nhiên, hành vi vi phạm trong trò chơi vẫn có '
        'thể bị Riot Games xử lý theo chính sách của họ.',
      ),
    ]),
    LegalSection('Khiếu nại quyết định kiểm duyệt', [
      LegalParagraph(
        'Nếu bạn cho rằng nội dung của mình bị gỡ nhầm hoặc biện pháp áp dụng '
        'chưa hợp lý, hãy gửi email tới $_email kèm Riot ID và mô tả ngắn. '
        'Chúng tôi sẽ xem xét lại và phản hồi sớm nhất có thể.',
      ),
    ]),
  ],
);
