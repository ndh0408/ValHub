import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';

/// Parses valorant-api `RRGGBBAA` (or `RRGGBB`) colors into Flutter ARGB
/// (CA §10.4). Invalid input yields [fallback].
Color parseRgba(String? hex, {Color fallback = ValColors.muted}) {
  if (hex == null) return fallback;
  var h = hex.trim();
  if (h.startsWith('#')) h = h.substring(1);
  if (h.length != 6 && h.length != 8) return fallback;
  final rgb = int.tryParse(h.substring(0, 6), radix: 16);
  if (rgb == null) return fallback;
  final a = h.length == 8 ? int.tryParse(h.substring(6, 8), radix: 16) : 0xFF;
  if (a == null) return fallback;
  return Color((a << 24) | rgb);
}

/// The same color forced opaque (content-tier `highlightColor` has alpha
/// 0x33 for card tints; use this for solid accents).
Color opaqueRgba(String? hex, {Color fallback = ValColors.muted}) =>
    parseRgba(hex, fallback: fallback).withValues(alpha: 1);
