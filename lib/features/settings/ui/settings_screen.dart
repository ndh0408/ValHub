import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/riot/platform_status.dart';
import '../../../core/ui/sub_page.dart';
import '../../community/ui/data_rights/community_data_section.dart';
import '../providers/settings_providers.dart';
import 'sections/accounts_section.dart';
import 'sections/country_section.dart';
import 'sections/app_info_sections.dart';
import 'sections/notifications_section.dart';
import 'sections/preferences_sections.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// "Cài đặt" (S70), hosted by the Hồ sơ tab and opened by the ⚙ button of
/// the Trang chủ and Hồ sơ headers. Route `/settings`.
///
/// Sections: TÀI KHOẢN (ending with "Đăng xuất tất cả tài khoản"), TÙY CHỌN
/// (Riot connection, platform, live-match switches), QUỐC GIA & GIÁ,
/// THÔNG BÁO, GIAO DIỆN, CỘNG ĐỒNG (hidden people and, once joined, the
/// account's Community data), HỖ TRỢ (server status, feedback, "Gửi báo lỗi
/// cho ValHub", "Giới thiệu & pháp lý") and DỮ LIỆU TRÊN MÁY (every
/// clean-up). No log lines are ever shown (docs/design/IA.md,
/// docs/design/VOICE.md §6).
/// Pull-to-refresh re-measures the temporary data, re-reads the notification
/// permission and the server status.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A pushed page (from the ⚙ of Trang chủ and Hồ sơ): back button and
    // the sub-page header like every other one; the accounts are the first
    // group, so no account chip here.
    return SubPageScaffold(
      title: context.l10n.settingsTitle,
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
              SettingsOptionsSection(),
              SettingsCountrySection(),
              SettingsNotificationsSection(),
              SettingsAppearanceSection(),
              CommunityDataSection(),
              SettingsSupportSection(),
              SettingsAppSection(),
              SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}
