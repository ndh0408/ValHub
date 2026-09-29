import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder;
import 'package:material_ui/material_ui.dart';

/// Valorant-style palette (FS §17), aligned with the Figma tokens
/// (`docs/design/DESIGN.md`, collection "ValVN Tokens").
abstract final class ValColors {
  /// Valorant red (primary accent) — token `red`.
  static const red = Color(0xFFFF4655);

  /// Screen background — token `bg`.
  static const navy = Color(0xFF0F1923);

  /// Darker than [navy] (image backdrops, overlays).
  static const nearBlack = Color(0xFF0A1016);

  /// Cards, list rows — token `s1`.
  static const surface = Color(0xFF1A2733);

  /// Nested cards, account chip, "BẠN" row — token `s2`.
  static const surfaceHigh = Color(0xFF243442);

  /// Progress track, switch off track.
  static const track = Color(0xFF2E3F4E);

  /// Bottom navigation bar.
  static const navBar = Color(0xFF131E29);
  static const outline = Color(0xFF34495A);

  /// Bone-white text — token `text`.
  static const bone = Color(0xFFECE8E1);

  /// Win / +RR / "Đang diễn ra" — token `green`.
  static const green = Color(0xFF3DDC97);

  /// Alias of [green] (older name).
  static const teal = green;

  /// Secondary text — token `muted`.
  static const muted = Color(0xFF8B9BA8);

  /// Warnings (agent select pill, estimates, "Đăng nhập lại").
  static const amber = Color(0xFFF5B942);
  static const error = Color(0xFFFF5A5F);

  /// Collection value / PREMIUM badge.
  static const gold = Color(0xFFF5C451);

  /// Live-game hero gradient start.
  static const liveTeal = Color(0xFF1D4A4C);

  // Light variant
  static const lightBackground = Color(0xFFF4F2EE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceHigh = Color(0xFFECE9E3);
  static const lightTrack = Color(0xFFDDD9D2);
  static const ink = Color(0xFF111820);
}

/// Content-tier (rarity) colors from the Figma tokens.
abstract final class TierColors {
  static const select = Color(0xFF5A9FE2);
  static const deluxe = Color(0xFF009587);
  static const premium = Color(0xFFD1548D);
  static const exclusive = Color(0xFFF5955B);
  static const ultra = Color(0xFFFAD663);
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
    this.track = ValColors.track,
    this.hairline = const Color(0x0FFFFFFF),
    this.surface2 = ValColors.surfaceHigh,
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
    gold: ValColors.gold,
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
    track: ValColors.lightTrack,
    hairline: Color(0x14000000),
    surface2: ValColors.lightSurfaceHigh,
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

  /// Match MVP label, collection value, PREMIUM badge.
  final Color gold;

  /// Progress-bar track, switch off track, inactive pips.
  final Color track;

  /// 6% dividers between grouped rows and the nav bar top border.
  final Color hairline;

  /// Nested card surface (token `s2`).
  final Color surface2;

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
    Color? track,
    Color? hairline,
    Color? surface2,
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
    track: track ?? this.track,
    hairline: hairline ?? this.hairline,
    surface2: surface2 ?? this.surface2,
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
      track: Color.lerp(track, other.track, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
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

/// Text styles of the Figma design that are not part of [TextTheme].
abstract final class ValText {
  /// Tab screen title: Anton 34.
  static const screenTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  /// Anton display number / map name ("Cấp 46 / 55", "8 - 4", "LOTUS").
  static TextStyle display(double size, {Color? color}) => TextStyle(
    fontFamily: AppFonts.display,
    fontSize: size,
    height: 1.1,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    color: color,
  );

  /// Small uppercase letter-spaced label ("TRANG BỊ", "HIỆN TẠI").
  static const label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );
}

/// Corner radii of the design system.
abstract final class ValRadius {
  static const card = 16.0;
  static const small = 12.0;
  static const pill = 999.0;
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
    letterSpacing: 0.4,
    fontWeight: FontWeight.w400,
  );
  final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(ValRadius.card),
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(ValRadius.small),
  );
  const buttonText = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    fontWeight: FontWeight.w700,
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
      titleLarge: text.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: text.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: text.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      labelSmall: text.labelSmall?.copyWith(fontWeight: FontWeight.w500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffold,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      scrolledUnderElevation: 0,
      elevation: 0,
      titleTextStyle: text.titleLarge?.copyWith(
        fontFamily: AppFonts.body,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: navBar,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: ValColors.red.withValues(alpha: 0.16),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12,
          color: s.contains(WidgetState.selected)
              ? ValColors.red
              : scheme.onSurfaceVariant,
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
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: cardShape,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ValColors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? scheme.onSurface.withValues(alpha: 0.38)
              : ValColors.red,
        ),
        side: WidgetStateProperty.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.12)
                : ValColors.red,
          ),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20),
        ),
        shape: WidgetStatePropertyAll(buttonShape),
        textStyle: const WidgetStatePropertyAll(buttonText),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ValColors.red,
        shape: buttonShape,
        textStyle: buttonText.copyWith(fontSize: 14),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: card,
      side: BorderSide(color: extras.hairline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? scheme.onSurface.withValues(alpha: 0.38)
            : Colors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? (s.contains(WidgetState.disabled)
                  ? ValColors.red.withValues(alpha: 0.38)
                  : ValColors.red)
            : extras.track,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbIcon: const WidgetStatePropertyAll(null),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: ValColors.red,
      labelColor: scheme.onSurface,
      unselectedLabelColor: scheme.onSurfaceVariant,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      titleTextStyle: text.bodyLarge?.copyWith(
        fontFamily: AppFonts.body,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: cardShape,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
        borderSide: const BorderSide(color: ValColors.red),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scaffold,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      clipBehavior: Clip.antiAlias,
      dragHandleColor: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dividerTheme: DividerThemeData(color: extras.hairline, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: ValColors.red,
      linearTrackColor: extras.track,
      circularTrackColor: Colors.transparent,
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
        secondary: ValColors.green,
        onSecondary: ValColors.navy,
        surface: ValColors.navy,
        onSurface: ValColors.bone,
        onSurfaceVariant: ValColors.muted,
        surfaceContainerLowest: ValColors.nearBlack,
        surfaceContainerLow: ValColors.navBar,
        surfaceContainer: ValColors.surface,
        surfaceContainerHigh: ValColors.surfaceHigh,
        surfaceContainerHighest: ValColors.track,
        surfaceTint: Colors.transparent,
        outline: ValColors.outline,
        outlineVariant: const Color(0xFF24323F),
        error: ValColors.error,
      );
  return _build(
    brightness: Brightness.dark,
    scheme: scheme,
    scaffold: ValColors.navy,
    card: ValColors.surface,
    navBar: ValColors.navBar,
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
        primary: const Color(0xFFE8303F),
        onPrimary: Colors.white,
        secondary: const Color(0xFF0B9E7A),
        surface: ValColors.lightBackground,
        onSurface: ValColors.ink,
        onSurfaceVariant: const Color(0xFF55606A),
        surfaceContainerLow: const Color(0xFFF9F8F5),
        surfaceContainer: ValColors.lightSurface,
        surfaceContainerHigh: ValColors.lightSurfaceHigh,
        surfaceContainerHighest: ValColors.lightTrack,
        surfaceTint: Colors.transparent,
        outlineVariant: const Color(0xFFDCD8D1),
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
