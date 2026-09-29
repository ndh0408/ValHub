import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/wishlist/data/vi_search.dart';

void main() {
  group('foldForSearch', () {
    test('strips Vietnamese diacritics and lowercases', () {
      expect(foldForSearch('Bulldog Vô Cực'), 'bulldog vo cuc');
      expect(
        foldForSearch('Dao Đầu Bếp Cafe Xanh Mát'),
        'dao dau bep cafe xanh mat',
      );
      expect(foldForSearch('Phantom Tốc Chiến'), 'phantom toc chien');
      expect(foldForSearch('Ghost Thinh Lặng'), 'ghost thinh lang');
      expect(foldForSearch('ỲÝỶỸỴ ưƯ'), 'yyyyy uu');
    });

    test('removes combining marks (decomposed input)', () {
      // "Vô" written as o + U+0302 (circumflex).
      expect(foldForSearch('Vô Cực'), 'vo cuc');
    });

    test('collapses whitespace', () {
      expect(foldForSearch('  Vandal \t  Reaver\n'), 'vandal reaver');
      expect(foldForSearch(''), '');
      expect(foldForSearch('   '), '');
    });
  });

  group('searchTokens / matchesTokens', () {
    test('every token must match, in any order', () {
      final key = foldForSearch('Vandal Reaver');
      expect(matchesTokens(key, searchTokens('reaver VANDAL')), isTrue);
      expect(matchesTokens(key, searchTokens('rea')), isTrue);
      expect(matchesTokens(key, searchTokens('reaver phantom')), isFalse);
      expect(searchTokens('  '), isEmpty);
      expect(matchesTokens(key, const []), isTrue);
    });

    test('accent-insensitive both ways', () {
      final key = foldForSearch('Bulldog Vô Cực');
      expect(matchesTokens(key, searchTokens('vô cực')), isTrue);
      expect(matchesTokens(key, searchTokens('vo cuc')), isTrue);
      expect(matchesTokens(key, searchTokens('VÔ')), isTrue);
    });
  });
}
