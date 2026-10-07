import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/util/clock.dart';
import '../data/server_status.dart';

/// X-1 status of [region] with every update and its time ("Trạng thái máy
/// chủ"). Unlike the core `platformStatusProvider` (banner, errors hidden),
/// a failed download is an error here so the screen offers "Thử lại"
/// instead of claiming that everything is fine.
final serverStatusProvider = FutureProvider.autoDispose
    .family<ServerStatusReport, String>((ref, region) async {
      final id = region.toLowerCase();
      final locale = ref.watch(appLocaleProvider).riotStatusCode;
      final json = await ref.watch(pvpApiProvider).platformStatus(id);
      return ServerStatusReport.fromJson(
        json,
        region: id,
        fetchedAt: ref.read(clockProvider).now(),
        locale: locale,
      );
    });
