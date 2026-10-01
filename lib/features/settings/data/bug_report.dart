import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/common_strings.dart';
import '../../../core/logging/session_log.dart';
import '../settings_strings.dart';

/// The file of "Gửi báo lỗi cho VanHub": a name and its UTF-8 text. The text is
/// the scrubbed session log (`SessionLog`): request templates, results and
/// times, never passwords, login data, account IDs or Riot IDs. It is only
/// ever handed to the share sheet; the app shows no log lines on screen.
class BugReportFile {
  const BugReportFile({required this.fileName, required this.text});

  final String fileName;
  final String text;

  Uint8List get bytes => Uint8List.fromList(utf8.encode(text));
}

/// `valvn-bug-report-2026-09-30.txt` for a report made on [day] (local time).
String bugReportFileName(DateTime day) {
  String two(int n) => n.toString().padLeft(2, '0');
  final d = day.toLocal();
  return 'valvn-bug-report-${d.year}-${two(d.month)}-${two(d.day)}.txt';
}

/// Builds the report from [log]; [version] is the app version (or `null`).
BugReportFile buildBugReport(
  SessionLog log, {
  required DateTime now,
  String? version,
}) => BugReportFile(
  fileName: bugReportFileName(now),
  text: _scrubReport(
    log.exportText(
      header: SettingsStrings.logFileHeader(
        CommonStrings.appName,
        version ?? CommonStrings.dash,
      ),
    ),
  ),
);

// Scrub again at the sharing boundary, including older on-disk entries.
// Unicode Riot tags are not covered by the legacy SessionLog scrubber.
String _scrubReport(String text) {
  final riotId = RegExp(r'[^\s#/]+#[\p{L}\p{N}\p{M}]+', unicode: true);
  final password = RegExp(
    r'(password|passwd|pwd)(\s*[=:]\s*)[^;&\s,]+',
    caseSensitive: false,
  );
  return text
      .split('\n')
      .map(
        (line) => SessionLog.scrubText(
          line
              .replaceAll(riotId, '{riotId}')
              .replaceAllMapped(password, (m) => '${m[1]}${m[2]}{redacted}'),
        ),
      )
      .join('\n');
}

/// Hands the report to the platform's native share sheet (mail, messages,
/// "Lưu vào Tệp"…). [origin] anchors the iPad popover.
typedef BugReportSharer = Future<void> Function(
  BugReportFile file, {
  Rect? origin,
});

/// Overridden in tests. The file goes through the share sheet only.
final bugReportSharerProvider = Provider<BugReportSharer>(
  (ref) => (file, {origin}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(file.bytes, mimeType: 'text/plain')],
        fileNameOverrides: [file.fileName],
        subject: SettingsStrings.sessionLogTitle,
        title: SettingsStrings.sessionLogTitle,
        sharePositionOrigin: origin,
      ),
    );
  },
);
