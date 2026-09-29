import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder;
import 'package:material_ui/material_ui.dart';

/// Valorant-style palette (FS §17).
abstract final class ValColors {
  /// Valorant red (primary accent).
  static const red = Color(0xFFFF4655);

  /// Deep navy background.
  static const navy = Color(0xFF0F1923);
  static const nearBlack = Color(0xFF0A1016);
  static const surface = Color(0xFF1B2733);
  static const surfaceHigh = Color(0xFF243140);
  static const outline = Color(0xFF34424F);

  /// Bone-white text.
  static const bone = Color(0xFFECE8E1);

  /// Win / +RR.
  static const teal = Color(0xFF17E5B3);

  /// Secondary text.
  static const muted = Color(0xFF8B978F);

  /// Warnings (agent select pill, estimates).
  static const amber = Color(0xFFF5A623);
  static const error = Color(0xFFFF5A5F);

  // Light variant
  static const lightBackground = Color(0xFFF4F2EE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceHigh = Color(0xFFE9E6E0);
  static const ink = Color(0xFF111820);
}

/// Semantic colors not covered by [ColorScheme]; read them with
/// `Theme.of(context).extension<ValThemeColors>()!` or [valColorsOf].
@immutable
class ValThemeColors extends ThemeExtension<ValThemeColors> {
  const ValThemeColors({
    required this.win,
    required this.loss,
    required this.draw,
    required this.warning,
    required this.muted,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.away,
    required this.gold,
  });

  static const dark = ValThemeColors(
    win: ValColors.teal,
    loss: ValColors.red,
    draw: ValColors.muted,
    warning: ValColors.amber,
    muted: ValColors.muted,
    skeletonBase: ValColors.surface,
    skeletonHighlight: ValColors.surfaceHigh,
    away: Color(0xFFE3C567),
    gold: Color(0xFFF5C451),
  );

  static const light = ValThemeColors(
    win: Color(0xFF0B9E7A),
    loss: Color(0xFFD9303F),
    draw: Color(0xFF6B7570),
    warning: Color(0xFFB9780F),
    muted: Color(0xFF6B7570),
    skeletonBase: Color(0xFFE3E0DA),
    skeletonHighlight: Color(0xFFF1EFEA),
    // Darker than the dark-theme yellows: readable on #F4F2EE.
    away: Color(0xFF9A7A12),
    gold: Color(0xFFA07800),
  );

  final Color win;
  final Color loss;
  final Color draw;
  final Color warning;
  final Color muted;
  final Color skeletonBase;
  final Color skeletonHighlight;

  /// Friend status "Vắng mặt".
  final Color away;

  /// Match MVP label.
  final Color gold;

  @override
  ValThemeColors copyWith({
    Color? win,
    Color? loss,
    Color? draw,
    Color? warning,
    Color? muted,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? away,
    Color? gold,
  }) => ValThemeColors(
    win: win ?? this.win,
    loss: loss ?? this.loss,
    draw: draw ?? this.draw,
    warning: warning ?? this.warning,
    muted: muted ?? this.muted,
    skeletonBase: skeletonBase ?? this.skeletonBase,
    skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    away: away ?? this.away,
    gold: gold ?? this.gold,
  );

  @override
  ValThemeColors lerp(ValThemeColors? other, double t) {
    if (other == null) return this;
    return ValThemeColors(
      win: Color.lerp(win, other.win, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      draw: Color.lerp(draw, other.draw, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      away: Color.lerp(away, other.away, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
    );
  }
}

/// Text / icon color readable on a solid [background] (e.g. a filled badge):
/// dark ink on bright colors (teal, amber), white on dark ones.
Color readableOn(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.light
    ? ValColors.ink
    : Colors.white;

/// Semantic colors of the current theme.
ValThemeColors valColorsOf(BuildContext context) =>
    Theme.of(context).extension<ValThemeColors>() ?? ValThemeColors.dark;

/// Font families bundled in `assets/fonts/`.
abstract final class AppFonts {
  /// Body text (Vietnamese-complete).
  static const body = 'BeVietnamPro';

  /// Display headings (Vietnamese-complete; Bebas Neue / Teko are not).
  static const display = 'Anton';
}

const _transitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

ThemeData _build({
  required Brightness brightness,
  required ColorScheme scheme,
  required Color scaffold,
  required Color card,
  required Color navBar,
  required ValThemeColors extras,
}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: AppFonts.body,
  );
  final text = base.textTheme;
  TextStyle? display(TextStyle? s) => s?.copyWith(
    fontFamily: AppFonts.display,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w400,
  );
  return base.copyWith(
    scaffoldBackgroundColor: scaffold,
    textTheme: text.copyWith(
      displayLarge: display(text.displayLarge),
      displayMedium: display(text.displayMedium),
      displaySmall: display(text.displaySmall),
      headlineLarge: display(text.headlineLarge),
      headlineMedium: display(text.headlineMedium),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffold,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      scrolledUnderElevation: 0,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: navBar,
      indicatorColor: ValColors.red.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? ValColors.red
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ValColors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        textStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ValColors.red,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    pageTransitionsTheme: _transitions,
    extensions: [extras],
  );
}

/// Dark Valorant-style Material 3 theme (default).
ThemeData buildDarkTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: ValColors.red,
        brightness: Brightness.dark,
      ).copyWith(
        primary: ValColors.red,
        onPrimary: Colors.white,
        secondary: ValColors.teal,
        onSecondary: ValColors.navy,
        surface: ValColors.navy,
        onSurface: ValColors.bone,
        onSurfaceVariant: ValColors.muted,
        surfaceContainerLowest: ValColors.nearBlack,
        surfaceContainerLow: const Color(0xFF15202B),
        surfaceContainer: ValColors.surface,
        surfaceContainerHigh: ValColors.surfaceHigh,
        surfaceContainerHighest: const Color(0xFF2D3B4A),
        outline: ValColors.outline,
        outlineVariant: const Color(0xFF26323E),
        error: ValColors.error,
      );
  return _build(
    brightness: Brightness.dark,
    scheme: scheme,
    scaffold: ValColors.navy,
    card: ValColors.surface,
    navBar: ValColors.nearBlack,
    extras: ValThemeColors.dark,
  );
}

/// Light variant ("Chủ đề: Sáng").
ThemeData buildLightTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: ValColors.red,
        brightness: Brightness.light,
      ).copyWith(
        primary: ValColors.red,
        onPrimary: Colors.white,
        secondary: const Color(0xFF0B9E7A),
        surface: ValColors.lightBackground,
        onSurface: ValColors.ink,
        surfaceContainer: ValColors.lightSurface,
        surfaceContainerHigh: ValColors.lightSurfaceHigh,
      );
  return _build(
    brightness: Brightness.light,
    scheme: scheme,
    scaffold: ValColors.lightBackground,
    card: ValColors.lightSurface,
    navBar: ValColors.lightSurface,
    extras: ValThemeColors.light,
  );
}
