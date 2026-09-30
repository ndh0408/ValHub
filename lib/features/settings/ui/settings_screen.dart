import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/riot/platform_status.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../community/ui/data_rights/community_data_section.dart';
import '../providers/settings_providers.dart';
import '../settings_strings.dart';
import 'sections/accounts_section.dart';
import 'sections/app_info_sections.dart';
import 'sections/notifications_section.dart';
import 'sections/preferences_sections.dart';

/// "Cài đặt" (S70), hosted by the Hồ sơ tab and opened by the ⚙ button of
/// the Trang chủ and Hồ sơ headers. Route `/settings`.
///
/// Sections: TÀI KHOẢN (ending with "Đăng xuất tất cả tài khoản"), TÙY CHỌN,
/// THÔNG BÁO, GIAO DIỆN, HỖ TRỢ (server status, feedback), NÂNG CAO ("Gửi
/// báo lỗi cho ValVN" and "Xóa dữ liệu tạm", the only technical actions; no
/// log lines are ever shown), and finally THÔNG TIN with the single "Giới
/// thiệu & pháp lý" row (docs/design/IA.md, docs/design/VOICE.md §6).
/// Pull-to-refresh re-measures the temporary data, re-reads the notification
/// permission and the server status.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabPageScaffold(
      title: SettingsStrings.title,
      onRefresh: () async {
        final region = ref.read(activeAccountProvider)?.region;
        ref
          ..invalidate(notificationsAllowedProvider)
          ..invalidate(cacheSizeBytesProvider);
        if (region != null) ref.invalidate(platformStatusProvider(region));
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
              CommunityDataSection(),
              SettingsOptionsSection(),
              SettingsNotificationsSection(),
              SettingsAppearanceSection(),
              SettingsSupportSection(),
              SettingsAppSection(),
              SettingsAboutSection(),
              SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}
