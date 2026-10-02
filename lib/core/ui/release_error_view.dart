import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';

/// A build failure can happen above Localizations, Theme or Directionality.
/// The boot resources keep this fallback usable even when the app root fails.
class ReleaseErrorView extends StatelessWidget {
  const ReleaseErrorView({super.key, required this.fallbackResources});
  final AppLocalizations fallbackResources;

  @override
  Widget build(BuildContext context) {
    final l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        fallbackResources;
    final direction =
        Directionality.maybeOf(context) ??
        (l10n.localeName.startsWith('ar')
            ? TextDirection.rtl
            : TextDirection.ltr);
    return Directionality(
      textDirection: direction,
      child: ColoredBox(
        color: const Color(0xFF141416),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.commonErrorGeneric,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFF2F1EE), fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
