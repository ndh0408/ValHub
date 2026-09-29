import 'legal_document.dart';
import 'legal_info.dart';

const _publisher = LegalInfo.publisherName;
const _email = LegalInfo.contactEmail;

/// Giấy phép phần mềm (proprietary end-user licence). ValVN is NOT open
/// source; third-party open-source components keep their own licences
/// (Flutter's `showLicensePage`).
const softwareLicense = LegalDocument(
  id: 'license',
  title: 'Giấy phép phần mềm',
  summary: 'Phần mềm độc quyền, bảo lưu mọi quyền',
  version: '1.0',
  preamble: [
    LegalCallout(LegalInfo.copyrightNotice),
    LegalParagraph(
      'Giấy phép sử dụng phần mềm dành cho người dùng cuối ("Giấy phép") này '
      'là thỏa thuận giữa bạn và $_publisher về việc sử dụng ứng dụng ValVN '
      '("Phần mềm"). ValVN là phần mềm độc quyền, không phải phần mềm mã nguồn '
      'mở.',
    ),
  ],
  sections: [
    LegalSection('Quyền sở hữu', [
      LegalParagraph(
        'Phần mềm, bao gồm mã nguồn, mã máy, cấu trúc, thiết kế giao diện, '
        'biểu tượng, tên và logo ValVN, văn bản và tài liệu đi kèm, thuộc quyền '
        'sở hữu của $_publisher và được bảo hộ bởi pháp luật Việt Nam về sở '
        'hữu trí tuệ và các điều ước quốc tế có liên quan. Phần mềm được cấp '
        'phép cho bạn sử dụng, không phải được bán.',
      ),
    ]),
    LegalSection('Phạm vi cấp phép', [
      LegalParagraph(
        'Với điều kiện bạn tuân thủ Giấy phép này và Điều khoản sử dụng, chúng '
        'tôi cấp cho bạn quyền có giới hạn, không độc quyền, không thể chuyển '
        'nhượng, không thể cấp phép lại và có thể thu hồi để tải về, cài đặt và '
        'sử dụng Phần mềm dưới dạng mã máy trên thiết bị bạn sở hữu hoặc kiểm '
        'soát, cho mục đích cá nhân, phi thương mại.',
      ),
    ]),
    LegalSection('Hạn chế', [
      LegalParagraph(
        'Trừ khi được pháp luật bắt buộc cho phép hoặc được chúng tôi đồng ý '
        'trước bằng văn bản, bạn không được:',
      ),
      LegalList([
        LegalItem(
          'sao chép, sửa đổi, dịch, chuyển thể hoặc tạo tác phẩm phái sinh từ '
          'Phần mềm;',
        ),
        LegalItem(
          'dịch ngược, giải mã, tháo rời hoặc cố gắng tái tạo mã nguồn, thuật '
          'toán hay cấu trúc của Phần mềm;',
        ),
        LegalItem(
          'phân phối, đăng tải lại, bán, cho thuê, cho mượn, cấp phép lại hoặc '
          'cung cấp Phần mềm cho bên thứ ba dưới bất kỳ hình thức nào;',
        ),
        LegalItem(
          'gỡ bỏ, che giấu hoặc thay đổi thông báo bản quyền, nhãn hiệu hay '
          'thông báo pháp lý trong Phần mềm;',
        ),
        LegalItem(
          'sử dụng Phần mềm để xây dựng sản phẩm hay dịch vụ cạnh tranh, hoặc '
          'vượt qua biện pháp kỹ thuật bảo vệ Phần mềm.',
        ),
      ]),
    ]),
    LegalSection('Thành phần mã nguồn mở của bên thứ ba', [
      LegalParagraph(
        'Phần mềm có sử dụng một số thư viện mã nguồn mở của bên thứ ba (ví dụ '
        'Flutter và các gói Dart). Mỗi thư viện được cấp phép theo giấy phép '
        'riêng của tác giả, và danh sách đầy đủ kèm nội dung giấy phép có tại '
        'mục "Giấy phép thư viện bên thứ ba" trong Ứng dụng. Giấy phép của các '
        'thư viện đó chỉ áp dụng cho chính các thư viện, không biến ValVN thành '
        'phần mềm mã nguồn mở.',
      ),
    ]),
    LegalSection('Nhãn hiệu của bên thứ ba', [
      LegalParagraph(
        'VALORANT, Riot Games và mọi tài sản liên quan là thương hiệu hoặc '
        'thương hiệu đã đăng ký của Riot Games, Inc. Giấy phép này không cấp '
        'cho bạn bất kỳ quyền nào đối với nhãn hiệu của Riot Games hay của '
        'ValVN.',
      ),
    ]),
    LegalSection('Cập nhật', [
      LegalParagraph(
        'Chúng tôi có thể phát hành bản cập nhật để sửa lỗi, cải thiện hoặc '
        'thay đổi tính năng. Một số bản cập nhật có thể là bắt buộc để tiếp tục '
        'sử dụng Phần mềm, ví dụ khi Riot Games thay đổi hệ thống. Giấy phép '
        'này áp dụng cho mọi bản cập nhật, trừ khi bản cập nhật đi kèm giấy '
        'phép khác.',
      ),
    ]),
    LegalSection('Phân phối qua App Store và Google Play', [
      LegalList([
        LegalItem(
          'Giấy phép này được ký kết giữa bạn và $_publisher, không phải với '
          'Apple Inc. hay Google LLC. Apple và Google không chịu trách nhiệm về '
          'Phần mềm, việc bảo trì, hỗ trợ hay giải quyết khiếu nại liên quan '
          'đến Phần mềm.',
        ),
        LegalItem(
          'Bạn phải tuân thủ quy định sử dụng của cửa hàng ứng dụng nơi bạn tải '
          'Phần mềm. Với bản tải từ App Store, Apple và các công ty con của '
          'Apple là bên thụ hưởng thứ ba của Giấy phép này và có quyền thực thi '
          'Giấy phép đối với bạn.',
        ),
      ]),
    ]),
    LegalSection('Chấm dứt', [
      LegalParagraph(
        'Giấy phép có hiệu lực cho đến khi bị chấm dứt. Giấy phép tự động chấm '
        'dứt nếu bạn vi phạm bất kỳ điều khoản nào. Khi chấm dứt, bạn phải '
        'ngừng sử dụng và gỡ Phần mềm khỏi mọi thiết bị.',
      ),
    ]),
    LegalSection('Miễn trừ bảo đảm và giới hạn trách nhiệm', [
      LegalParagraph(
        'Phần mềm được cung cấp "nguyên trạng". Các quy định về miễn trừ bảo '
        'đảm, giới hạn trách nhiệm, luật áp dụng và giải quyết tranh chấp trong '
        'Điều khoản sử dụng được áp dụng cho Giấy phép này.',
      ),
    ]),
    LegalSection('Liên hệ cấp phép', [
      LegalParagraph(
        'Mọi yêu cầu cấp phép, hợp tác hoặc sử dụng Phần mềm ngoài phạm vi Giấy '
        'phép này, vui lòng liên hệ $_email.',
      ),
    ]),
  ],
);
