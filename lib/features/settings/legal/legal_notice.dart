import '../../../core/l10n/common_strings.dart';
import 'legal_document.dart';
import 'legal_info.dart';

const _email = LegalInfo.contactEmail;

/// Thông báo pháp lý: Riot "Legal Jibber Jabber" disclaimer, trademarks,
/// data-source credits, copyright.
const legalNotice = LegalDocument(
  id: 'notice',
  title: 'Thông báo pháp lý',
  summary: 'Tuyên bố miễn trừ Riot Games, nhãn hiệu và ghi công',
  version: '1.0',
  preamble: [LegalCallout(CommonStrings.riotDisclaimer)],
  sections: [
    LegalSection('Tuyên bố miễn trừ Riot Games', [
      LegalParagraph(
        'ValVN được tạo ra theo chính sách "Legal Jibber Jabber" của Riot Games, '
        'có sử dụng tài sản thuộc sở hữu của Riot Games. Riot Games không xác '
        'nhận hay tài trợ cho dự án này.',
      ),
      LegalParagraph(
        'ValVN là ứng dụng độc lập, không phải sản phẩm chính thức của Riot '
        'Games và không liên kết với Riot Games dưới bất kỳ hình thức nào. Mọi '
        'hỗ trợ về ValVN do chúng tôi cung cấp, không phải Riot Games.',
      ),
    ]),
    LegalSection('Nhãn hiệu', [
      LegalParagraph(
        'Riot Games, VALORANT và mọi tài sản liên quan là thương hiệu hoặc '
        'thương hiệu đã đăng ký của Riot Games, Inc. Các tên, logo và nhãn hiệu '
        'khác được nhắc đến trong Ứng dụng thuộc về chủ sở hữu tương ứng và chỉ '
        'được dùng để nhận diện.',
      ),
    ]),
    LegalSection('Nội dung trò chơi', [
      LegalParagraph(
        'Tên, hình ảnh, video và dữ liệu của skin, đặc vụ, bản đồ, rank, thẻ '
        'người chơi và các nội dung khác của VALORANT thuộc quyền sở hữu của '
        'Riot Games, Inc. Dữ liệu tài khoản của bạn (cửa hàng, ví, bộ sưu tập, '
        'trận đấu, xếp hạng) được lấy trực tiếp từ máy chủ của Riot Games.',
      ),
    ]),
    LegalSection('Nguồn dữ liệu và ghi công', [
      LegalList([
        LegalItem(
          'dữ liệu và hình ảnh công khai về vật phẩm, đặc vụ, bản đồ và rank '
          '(bản tiếng Việt). valorant-api.com là dự án cộng đồng độc lập, không '
          'liên kết với ValVN hay Riot Games.',
          lead: 'valorant-api.com:',
        ),
        LegalItem(
          'tài liệu kỹ thuật do cộng đồng nhà phát triển VALORANT biên soạn.',
          lead: 'techchrism/valorant-api-docs:',
        ),
        LegalItem(
          'ValVN được xây dựng bằng Flutter cùng nhiều thư viện mã nguồn mở. '
          'Danh sách và giấy phép của từng thư viện có tại mục "Giấy phép thư '
          'viện bên thứ ba".',
          lead: 'Thư viện mã nguồn mở:',
        ),
      ]),
    ]),
    LegalSection('Bản quyền ValVN', [
      LegalParagraph(
        '${LegalInfo.copyrightNotice} ValVN là phần mềm độc quyền; việc sử dụng '
        'tuân theo Giấy phép phần mềm và Điều khoản sử dụng.',
      ),
    ]),
    LegalSection('Báo cáo vi phạm quyền sở hữu trí tuệ', [
      LegalParagraph(
        'Nếu bạn cho rằng nội dung trong ValVN, kể cả nội dung do người dùng '
        'đăng trong Cộng đồng, vi phạm quyền sở hữu trí tuệ của bạn, vui lòng '
        'gửi email tới $_email kèm: thông tin liên hệ của bạn, mô tả tác phẩm '
        'được bảo hộ, vị trí nội dung vi phạm trong Ứng dụng và cam kết thông '
        'tin bạn cung cấp là chính xác. Chúng tôi sẽ xem xét và xử lý kịp thời.',
      ),
    ]),
  ],
);
