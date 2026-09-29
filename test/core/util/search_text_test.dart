import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/util/search_text.dart';

void main() {
  group('foldSearchText', () {
    test('strips every Vietnamese mark and đ', () {
      expect(foldSearchText('Thượng Giới'), 'thuong gioi');
      expect(foldSearchText('ĐỘC QUYỀN'), 'doc quyen');
      expect(foldSearchText('Đức'), 'duc');
      expect(
        foldSearchText('àáạảãâầấậẩẫăằắặẳẵ èéẹẻẽêềếệểễ ìíịỉĩ'),
        'aaaaaaaaaaaaaaaaa eeeeeeeeeee iiiii',
      );
      expect(
        foldSearchText('òóọỏõôồốộổỗơờớợởỡ ùúụủũưừứựửữ ỳýỵỷỹ'),
        'ooooooooooooooooo uuuuuuuuuuu yyyyy',
      );
      expect(foldSearchText('ÀÁẠẢÃ ƯỪỨỰỬỮ ỲÝỴỶỸ Đ'), 'aaaaa uuuuuu yyyyy d');
    });

    test('handles combining (NFD) marks', () {
      // "Vô" typed as V + o + U+0302.
      expect(foldSearchText('Vô Cực'), 'vo cuc');
    });

    test('collapses whitespace and trims', () {
      expect(foldSearchText('  Vandal \t  Reaver\n'), 'vandal reaver');
      expect(foldSearchText('a b'), 'a b');
      expect(foldSearchText(''), '');
      expect(foldSearchText('   '), '');
    });

    test('folds common Latin accents', () {
      expect(foldSearchText('Pokémon Señor'), 'pokemon senor');
    });
  });

  group('matchesSearch', () {
    const name = 'Phantom Thượng Giới';

    test('accent and case insensitive', () {
      expect(matchesSearch('thuong gioi', [name]), isTrue);
      expect(matchesSearch('thượng giới', [name]), isTrue);
      expect(matchesSearch('THUONG GIOI', [name]), isTrue);
      expect(matchesSearch('THƯỢNG GIỚI', [name]), isTrue);
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
    final key = foldSearchText('Bulldog Vô Cực');
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
