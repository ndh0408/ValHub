import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/profile/data/hit_distribution.dart';

void main() {
  test(
    'counts hits rather than kills; empty or malformed counts are unknown',
    () {
      expect(hitDistribution(3, 6, 1), (head: .3, body: .6, legs: .1));
      expect(hitDistribution(0, 0, 0), (head: null, body: null, legs: null));
      expect(hitDistribution(-1, 10, 0).head, isNull);
    },
  );
}
