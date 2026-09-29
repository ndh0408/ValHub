import '../../../core/domain/competitive/names.dart';

final RegExp _tag = RegExp(r'^[\p{L}\p{N}]{3,5}$', unicode: true);

/// Parses a typed Riot ID ("Tên Người Chơi#VN2") for an invite: the name is
/// 3–16 characters (letters, digits, spaces; Vietnamese allowed), the tag
/// 3–5 letters or digits after the last `#`. Surrounding spaces are
/// ignored. `null` when the input is not a valid Riot ID.
RiotName? parseRiotIdInput(String input) {
  final s = input.trim();
  final hash = s.lastIndexOf('#');
  if (hash <= 0 || hash == s.length - 1) return null;
  final name = s.substring(0, hash).trim().replaceAll(RegExp(r'\s+'), ' ');
  final tag = s.substring(hash + 1).trim();
  final length = name.runes.length;
  if (length < 3 || length > 16 || name.contains('#')) return null;
  if (!_tag.hasMatch(tag)) return null;
  return RiotName(gameName: name, tagLine: tag);
}
