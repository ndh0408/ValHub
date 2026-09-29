import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/util/search_text.dart';

void main() {
  group('foldForSearch', () {
    test('Vietnamese: every tone / vowel mark and đ', () {
      expect(foldForSearch('Thượng Giới'), 'thuong gioi');
      expect(foldForSearch('ĐỘC QUYỀN'), 'doc quyen');
      expect(foldForSearch('Đức'), 'duc');
      expect(
        foldForSearch('àáạảãâầấậẩẫăằắặẳẵ èéẹẻẽêềếệểễ ìíịỉĩ'),
        'aaaaaaaaaaaaaaaaa eeeeeeeeeee iiiii',
      );
      expect(
        foldForSearch('òóọỏõôồốộổỗơờớợởỡ ùúụủũưừứựửữ ỳýỵỷỹ'),
        'ooooooooooooooooo uuuuuuuuuuu yyyyy',
      );
      expect(foldForSearch('ÀÁẠẢÃ ƯỪỨỰỬỮ ỲÝỴỶỸ Đ'), 'aaaaa uuuuuu yyyyy d');
    });

    test('Western European letters', () {
      expect(foldForSearch('Café Crème'), 'cafe creme');
      expect(foldForSearch('Straße'), 'strasse');
      expect(foldForSearch('STRAẞE'), 'strasse');
      expect(foldForSearch('Ærø Œuvre'), 'aero oeuvre');
      expect(foldForSearch('Señor Pokémon Über'), 'senor pokemon uber');
      expect(foldForSearch('Ação Coração'), 'acao coracao');
      expect(foldForSearch('Perché Città'), 'perche citta');
    });

    test('Polish and Turkish', () {
      expect(foldForSearch('Łódź Źdźbło'), 'lodz zdzblo');
      expect(foldForSearch('Şehir Ğ ıİ'), 'sehir g ii');
      expect(foldForSearch('İSTANBUL'), 'istanbul');
      expect(foldForSearch('DİYARBAKIR'), 'diyarbakir');
    });

    test('Greek and Cyrillic', () {
      expect(foldForSearch('Άλφα ΈΝΑ'), 'αλφα ενα');
      expect(foldForSearch('λόγος'), 'λογοσ');
      expect(foldForSearch('Ёлка Йод'), 'елка иод');
      expect(foldForSearch('Москва'), 'москва');
    });

    test('Arabic: harakat, tatweel and hamza forms', () {
      expect(foldForSearch('مَرْحَبًا'), 'مرحبا');
      expect(foldForSearch('عـــربي'), 'عربي');
      expect(foldForSearch('أحمد إبراهيم آمن'), 'احمد ابراهيم امن');
    });

    test('full-width ASCII and ideographic space', () {
      expect(foldForSearch('ＲＥＡＶＥＲ　ｖａｎｄａｌ'), 'reaver vandal');
      expect(foldForSearch('１２３'), '123');
    });

    test('CJK, kana and Hangul are kept as is', () {
      expect(foldForSearch('ガイコツ ぎんが'), 'ガイコツ ぎんが');
      expect(foldForSearch('프라임 뱅가드'), '프라임 뱅가드');
      expect(foldForSearch('幻象 冠军'), '幻象 冠军');
      expect(foldForSearch('นักรบ'), 'นักรบ');
    });

    test('handles combining (NFD) input', () {
      // "Vô Cực" typed as base letters + combining marks.
      expect(foldForSearch('Vô Cực'), 'vo cuc');
      expect(foldForSearch('Café'), 'cafe');
    });

    test('collapses whitespace and trims', () {
      expect(foldForSearch('  Vandal \t  Reaver\n'), 'vandal reaver');
      expect(foldForSearch('a b'), 'a b');
      expect(foldForSearch(''), '');
      expect(foldForSearch('   '), '');
    });
  });

  group('matchesSearch', () {
    const name = 'Phantom Thượng Giới';

    test('accent and case insensitive', () {
      expect(matchesSearch('thuong gioi', [name]), isTrue);
      expect(matchesSearch('thượng giới', [name]), isTrue);
      expect(matchesSearch('THUONG GIOI', [name]), isTrue);
      expect(matchesSearch('THƯỢNG GIỚI', [name]), isTrue);
      expect(matchesSearch('strasse', ['Die Straße']), isTrue);
      expect(matchesSearch('sehir', ['Şehir Efsanesi']), isTrue);
    });

    test('every word must match, in any order and across candidates', () {
      expect(matchesSearch('gioi phantom', [name]), isTrue);
      expect(matchesSearch('gioi vandal', [name]), isFalse);
      expect(
        matchesSearch('vandal reaver', ['Reaver', null, 'Vandal']),
        isTrue,
      );
    });

    test('blank query matches everything', () {
      expect(matchesSearch('', [name]), isTrue);
      expect(matchesSearch('   ', const []), isTrue);
    });

    test('words never match across candidate boundaries', () {
      expect(matchesSearch('ab', ['a', 'b']), isFalse);
    });
  });

  test('searchTokens / matchesTokens', () {
    final key = foldForSearch('Bulldog Vô Cực');
    expect(searchTokens('  VÔ   cuc '), ['vo', 'cuc']);
    expect(matchesTokens(key, searchTokens('vô cực')), isTrue);
    expect(matchesTokens(key, searchTokens('vo phantom')), isFalse);
    expect(searchTokens(''), isEmpty);
  });

  test('compareNames sorts accent-insensitively', () {
    final names = ['Bạc', 'Ánh', 'Đồng', 'An'];
    names.sort(compareNames);
    expect(names, ['An', 'Ánh', 'Bạc', 'Đồng']);
  });

  test('SearchIndex keeps order and filters by every word', () {
    final index = SearchIndex<String>([
      'Vandal Thượng Giới',
      'Phantom Thượng Giới',
      'Vandal Reaver',
    ], (s) => [s]);
    expect(index.filter('thuong'), [
      'Vandal Thượng Giới',
      'Phantom Thượng Giới',
    ]);
    expect(index.filter('VANDAL gioi'), ['Vandal Thượng Giới']);
    expect(index.filter(''), hasLength(3));
  });
}
