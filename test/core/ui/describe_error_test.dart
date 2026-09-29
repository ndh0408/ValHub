import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/ui/error_view.dart';

void main() {
  test('maintenance always shows the Vietnamese copy, not Riot English', () {
    final d = describeError(
      const MaintenanceException(
        message: 'Server is currently down for scheduled maintenance',
      ),
    );
    expect(d.title, CommonStrings.maintenanceTitle);
    expect(d.message, CommonStrings.errorMaintenance);
  });
}
