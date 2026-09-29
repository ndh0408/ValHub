import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show Rect;
import 'package:share_plus/share_plus.dart';

import '../../../core/util/clock.dart';
import '../community_strings.dart';
import 'community_providers.dart';
import 'consent_providers.dart';
import 'lfg_providers.dart';
import 'skin_vote_providers.dart';

/// The file of "Tải dữ liệu của tôi": a name and its UTF-8 bytes.
class CommunityExportFile {
  const CommunityExportFile({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;

  /// The JSON text (for tests and previews).
  String get text => utf8.decode(bytes);
}

/// `valvn-community-2026-09-30.json` for an export made on [day] (local).
String communityExportFileName(DateTime day) {
  String two(int n) => n.toString().padLeft(2, '0');
  final d = day.toLocal();
  return 'valvn-community-${d.year}-${two(d.month)}-${two(d.day)}.json';
}

/// The export document as a readable (indented) UTF-8 JSON file.
CommunityExportFile encodeCommunityExport(
  Map<String, Object?> document, {
  required DateTime now,
}) => CommunityExportFile(
  fileName: communityExportFileName(now),
  bytes: Uint8List.fromList(
    utf8.encode(const JsonEncoder.withIndent('  ').convert(document)),
  ),
);

/// Hands the export file to the platform's native share sheet ("Lưu vào
/// Tệp", AirDrop, Drive, email…). [origin] anchors the iPad popover.
typedef CommunityExportSharer = Future<void> Function(
  CommunityExportFile file, {
  Rect? origin,
});

/// Overridden in tests. The file goes through the share sheet only: the app
/// never keeps a copy of the export on disk.
final communityExportSharerProvider = Provider<CommunityExportSharer>(
  (ref) => (file, {origin}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(file.bytes, mimeType: 'application/json')],
        fileNameOverrides: [file.fileName],
        subject: CommunityStrings.exportSubject,
        title: CommunityStrings.exportSubject,
        sharePositionOrigin: origin,
      ),
    );
  },
);

/// The user's rights over what the Community server holds about an account
/// (privacy policy "Xóa dữ liệu"): export, delete, withdraw consent.
final communityDataRightsProvider = Provider<CommunityDataRights>(
  CommunityDataRights.new,
);

class CommunityDataRights {
  CommunityDataRights(this._ref);

  final Ref _ref;

  /// `GET /v1/me/export`, encoded as a `.json` file (not shared yet).
  Future<CommunityExportFile> export(String puuid) async {
    final document = await _ref
        .read(communityApiProvider)
        .exportMyData(puuid.toLowerCase());
    return encodeCommunityExport(document, now: _ref.read(clockProvider).now());
  }

  /// Downloads the export and opens the native share sheet with it.
  Future<CommunityExportFile> exportAndShare(
    String puuid, {
    Rect? origin,
  }) async {
    final file = await export(puuid);
    await _ref.read(communityExportSharerProvider)(file, origin: origin);
    return file;
  }

  /// `DELETE /v1/me`: the server erases everything of the account (posts,
  /// comments, reviews, likes, votes, LFG posts, images). Only after it
  /// answered does the device forget the community session and the consent,
  /// so a failed request leaves everything as it was.
  Future<void> deleteAll(String puuid) async {
    await _ref.read(communityApiProvider).deleteMyAccount(puuid.toLowerCase());
    await _forgetLocally(puuid);
  }

  /// "Rút lại đồng ý": no request; the server keeps what was posted. The
  /// device forgets the community session and the consent, so the Community
  /// tab is anonymous again.
  Future<void> withdrawConsent(String puuid) => _forgetLocally(puuid);

  Future<void> _forgetLocally(String puuid) async {
    final id = puuid.toLowerCase();
    // Consent first: nothing can sign in again while the session is dropped.
    await _ref.read(communityConsentProvider(id).notifier).revoke();
    await _ref.read(communityAuthProvider).forget(id);
    // State that outlives the consent-aware providers (they reload by
    // themselves): the poster's own LFG post, this device's vote overrides
    // and every cached LFG list.
    _ref
      ..invalidate(myLfgProvider(id))
      ..invalidate(skinVoteOverridesProvider(id))
      ..invalidate(lfgProvider);
  }
}
