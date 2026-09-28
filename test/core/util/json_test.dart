import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/util/json.dart';

void main() {
  group('asMap', () {
    test('returns string-keyed maps and converts loose maps', () {
      expect(asMap({'a': 1}), {'a': 1});
      expect(asMap({1: 'x', 'b': 2}), {'b': 2});
      expect(asMap(null), isNull);
      expect(asMap('x'), isNull);
      expect(asMap([1]), isNull);
    });
  });

  group('lists', () {
    test('asList tolerates null and wrong types', () {
      expect(asList(null), isEmpty);
      expect(asList('x'), isEmpty);
      expect(asList([1, null]), [1, null]);
    });

    test('asMapList keeps only objects', () {
      expect(asMapList([{'a': 1}, 2, null, 'x', {'b': 2}]), [{'a': 1}, {'b': 2}]);
      expect(asMapList(null), isEmpty);
    });

    test('asStringList drops empty and non-strings', () {
      expect(asStringList(['a', '', 1, null, 'b']), ['a', 'b']);
    });
  });

  group('scalars', () {
    test('asString converts numbers and booleans', () {
      expect(asString('x'), 'x');
      expect(asString(3), '3');
      expect(asString(true), 'true');
      expect(asString({}), isNull);
      expect(asNonEmptyString('  '), isNull);
      expect(asNonEmptyString(' a '), 'a');
    });

    test('asInt reads num and numeric strings', () {
      expect(asInt(3), 3);
      expect(asInt(3.9), 3);
      expect(asInt('42'), 42);
      expect(asInt(' 7.5 '), 7);
      expect(asInt('x'), isNull);
      expect(asInt(double.nan), isNull);
      expect(asInt(null), isNull);
    });

    test('asDouble and asNum', () {
      expect(asDouble(1), 1.0);
      expect(asDouble('2.5'), 2.5);
      expect(asDouble('inf'), isNull);
      expect(asNum('10'), 10);
      expect(asNum(true), isNull);
    });

    test('asBool accepts bools, 0/1 and strings', () {
      expect(asBool(true), isTrue);
      expect(asBool(0), isFalse);
      expect(asBool('TRUE'), isTrue);
      expect(asBool('0'), isFalse);
      expect(asBool('maybe'), isNull);
    });

    test('lowerUuid lowercases and trims', () {
      expect(lowerUuid(' 9C82E19D-4575-0200-1A81-3EACF00CF872 '), '9c82e19d-4575-0200-1a81-3eacf00cf872');
      expect(lowerUuid(''), isNull);
      expect(lowerUuid(null), isNull);
    });

    test('asDateTime handles ISO strings, epoch ms and the zero date', () {
      expect(asDateTime('2026-08-19T00:00:00Z'), DateTime.utc(2026, 8, 19));
      expect(asDateTime(1660075851445), DateTime.fromMillisecondsSinceEpoch(1660075851445, isUtc: true));
      expect(asDateTime('1660075851445'), isNotNull);
      expect(asDateTime('0001-01-01T00:00:00Z'), isNull);
      expect(asDateTime('garbage'), isNull);
      expect(asDateTime(''), isNull);
    });
  });

  test('pick walks maps and lists', () {
    final json = {
      'a': [
        {'b': 'x'},
      ],
    };
    expect(pick(json, ['a', 0, 'b']), 'x');
    expect(pick(json, ['a', 5, 'b']), isNull);
    expect(pick(json, ['z', 'y']), isNull);
    expect(pick('str', ['a']), isNull);
  });

  test('tryDecodeJson rejects HTML error pages and bad JSON', () {
    expect(tryDecodeJson('{"a":1}'), {'a': 1});
    expect(tryDecodeJson('[1]'), [1]);
    expect(tryDecodeJson('<!DOCTYPE html><title>Just a moment...</title>'), isNull);
    expect(tryDecodeJson('{broken'), isNull);
    expect(tryDecodeJson(''), isNull);
    expect(tryDecodeJson(null), isNull);
  });

  test('vapiData unwraps the envelope', () {
    expect(vapiData({'status': 200, 'data': [1]}), [1]);
    expect(vapiData('x'), isNull);
  });

  test('JsonMapX accessors', () {
    final m = <String, dynamic>{
      'n': '5',
      'u': 'ABC',
      'l': null,
      'm': {'k': 1},
      'b': 1,
    };
    expect(m.integer('n'), 5);
    expect(m.uuid('u'), 'abc');
    expect(m.list('l'), isEmpty);
    expect(m.map('m'), {'k': 1});
    expect(m.boolean('b'), isTrue);
    expect(m.str('missing'), isNull);
  });
}
