import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show Rect;
import 'package:share_plus/share_plus.dart';

/// Shares only a public post link/text, never a Riot account selector or token.
String communityPostLink(String id) =>
    'valvn://post/${Uri.encodeComponent(id)}';

typedef CommunityPostSharer = Future<void> Function({
  required String text,
  required String subject,
  Rect? origin,
});

final communityPostSharerProvider = Provider<CommunityPostSharer>(
  (ref) => ({required text, required subject, origin}) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        title: subject,
        sharePositionOrigin: origin,
      ),
    );
  },
);
