import 'package:material_ui/material_ui.dart';

import '../l10n/common_strings.dart';

class ReleaseErrorView extends StatelessWidget {
  const ReleaseErrorView({super.key});
  @override
  Widget build(BuildContext context) => const Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: Color(0xFF141416),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            CommonStrings.errorGeneric,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFF2F1EE), fontSize: 16),
          ),
        ),
      ),
    ),
  );
}
