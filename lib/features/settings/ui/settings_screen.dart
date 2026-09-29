import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/ui/tab_page_scaffold.dart';
import '../providers/settings_providers.dart';
import '../settings_strings.dart';
import 'sections/accounts_section.dart';
import 'sections/app_info_sections.dart';
import 'sections/notifications_section.dart';
import 'sections/preferences_sections.dart';

/// TAB 5 "Cài đặt" (S70). Route `/settings`.
///
/// Sections: TÀI KHOẢN, TÙY CHỌN, THÔNG BÁO, GIAO DIỆN, ỨNG DỤNG, THÔNG TIN,
/// then "Đăng xuất tất cả tài khoản". Everything is local except the
/// maintenance banner, so pull-to-refresh only re-measures the cache and
/// re-reads the notification permission.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabPageScaffold(
      title: SettingsStrings.title,
      onRefresh: () async {
        ref
          ..invalidate(notificationsAllowedProvider)
          ..invalidate(cacheSizeBytesProvider);
        try {
          await ref.read(cacheSizeBytesProvider.future);
        } on Object {
          // The row shows "–" on failure; nothing else to report.
        }
      },
      slivers: const [
        SliverSafeArea(
          top: false,
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              SettingsAccountsSection(),
              SettingsOptionsSection(),
              SettingsNotificationsSection(),
              SettingsAppearanceSection(),
              SettingsAppSection(),
              SettingsAboutSection(),
              SizedBox(height: 28),
              SettingsSignOutAllButton(),
              SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}
