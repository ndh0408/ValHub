import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder;
import 'package:material_ui/material_ui.dart';

/// Valorant-style palette (FS §17), aligned with the Figma tokens
/// (`docs/design/DESIGN.md`, collection "VanHub Tokens").
abstract final class ValColors {
  /// Valorant red (primary accent) — token `red`.
  static const red = Color(0xFFFF4655);
  static const actionRed = Color(0xFFD42A38);

  /// Screen background — token `bg`. True black (OLED, ValBuddy-style);
  /// the historical name is kept for compatibility.
  static const navy = Color(0xFF000000);

  /// Image backdrops, overlays.
  static const nearBlack = Color(0xFF0A0A0B);

  /// Cards, list rows — token `s1` (near-black).
  static const surface = Color(0xFF141416);

  /// Nested cards, inactive pills, account chip, "BẠN" row — token `s2`.
  static const surfaceHigh = Color(0xFF1F1F23);

  /// Progress track, switch off track.
  static const track = Color(0xFF2C2C31);

  /// Floating tab bar (drawn translucent).
  static const navBar = Color(0xFF1C1C1F);
  static const outline = Color(0xFF3A3A40);

  /// Deep navy accent surface (hero gradients).
  static const deepNavy = Color(0xFF0F1923);

  /// Primary text — token `text`.
  static const bone = Color(0xFFF2F1EE);

  /// Win / +RR / "Đang diễn ra" — token `green`.
  static const green = Color(0xFF3DDC97);

  /// Alias of [green] (older name).
  static const teal = green;

  /// Secondary text — token `muted` (iOS system grey).
  static const muted = Color(0xFFADB1BA);

  /// Warnings (agent select pill, estimates, "Đăng nhập lại").
  static const amber = Color(0xFFF5B942);
  static const error = Color(0xFFFF5A5F);

  /// Collection value / PREMIUM badge.
  static const gold = Color(0xFFF5C451);

  /// Live-game hero gradient start.
  static const liveTeal = Color(0xFF1D4A4C);

  // Light variant (iOS system grouped background / white cards)
  static const lightBackground = Color(0xFFF2F2F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceHigh = Color(0xFFE9E9EE);
  static const lightTrack = Color(0xFFD9D9DE);
  static const ink = Color(0xFF111114);
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
    this.hairline = const Color(0x17FFFFFF),
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

  // Every text color here reaches WCAG AA (≥ 4.5:1) on the light background
  // #F4F2EE and on white cards (see test/core/theme/contrast_test.dart).
  static const light = ValThemeColors(
    win: Color(0xFF06785F),
    loss: Color(0xFFC8202F),
    draw: Color(0xFF636366),
    warning: Color(0xFF9A6208),
    muted: Color(0xFF636366),
    skeletonBase: Color(0xFFE3E3E8),
    skeletonHighlight: Color(0xFFF2F2F6),
    // Darker than the dark-theme yellows: readable on #F4F2EE.
    away: Color(0xFF8A6700),
    gold: Color(0xFF8A6700),
    track: ValColors.lightTrack,
    hairline: Color(0x1A000000),
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

/// [color] adjusted (darker on light backgrounds, lighter on dark ones)
/// until it reaches [minContrast] against [background]. Use it for text in
/// a content color (rarity, rank, tier), which is often too pale on the
/// light theme (Siêu Cấp yellow on white is 1.4:1).
Color legibleOn(Color color, Color background, {double minContrast = 4.5}) {
  final c = color.withValues(alpha: 1);
  if (_contrast(c, background) >= minContrast) return c;
  final darken = background.computeLuminance() > 0.4;
  final hsl = HSLColor.fromColor(c);
  var l = hsl.lightness;
  for (var i = 0; i < 20; i++) {
    l = (darken ? l - 0.04 : l + 0.04).clamp(0.0, 1.0);
    final next = hsl.withLightness(l).toColor();
    if (_contrast(next, background) >= minContrast || l == 0 || l == 1) {
      return next;
    }
  }
  return hsl.withLightness(l).toColor();
}

/// [legibleOn] against the current theme's card surface.
Color legibleAccent(BuildContext context, Color color, {double min = 4.5}) =>
    legibleOn(
      color,
      Theme.of(context).colorScheme.surfaceContainer,
      minContrast: min,
    );

/// WCAG contrast ratio of two opaque colors.
double contrastRatio(Color a, Color b) => _contrast(a, b);

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

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
  /// Tab screen title: large bold plain sans (iOS large-title feel).
  static const screenTitle = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
  );

  /// Section title inside a screen ("Trang bị", "Nhiệm vụ tuần").
  static const sectionTitle = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 19,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
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
  static const card = 20.0;
  static const small = 12.0;
  static const pill = 999.0;
}

/// Spacing scale (4-pt grid) used for paddings and gaps.
abstract final class ValSpace {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  /// Horizontal page gutter of lists and cards.
  static const gutter = 16.0;
}

/// Motion durations / curves for implicit animations.
abstract final class ValMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const curve = Curves.easeOutCubic;
}

const _transitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
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
  // Brand red on dark; a deeper red on light so red text and outlines keep
  // ≥ 4.5:1 contrast on the pale background.
  final accent = scheme.primary;
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
      headlineLarge: text.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      headlineSmall: text.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: text.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: text.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
      ),
      bodyMedium: text.bodyMedium?.copyWith(letterSpacing: 0, height: 1.4),
      bodySmall: text.bodySmall?.copyWith(
        fontSize: 13,
        letterSpacing: 0,
        height: 1.4,
      ),
      labelLarge: text.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      labelMedium: text.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      labelSmall: text.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
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
      indicatorColor: accent.withValues(alpha: 0.16),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12,
          color: s.contains(WidgetState.selected)
              ? accent
              : scheme.onSurfaceVariant,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? accent
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
        backgroundColor: ValColors.actionRed,
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
              : accent,
        ),
        side: WidgetStateProperty.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.12)
                : accent,
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
        foregroundColor: accent,
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
                  ? accent.withValues(alpha: 0.38)
                  : accent)
            : extras.track,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbIcon: const WidgetStatePropertyAll(null),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: accent,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
        borderSide: BorderSide(color: extras.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
        borderSide: BorderSide(color: extras.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
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
      color: accent,
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
        outlineVariant: const Color(0xFF26262B),
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
        primary: ValColors.actionRed,
        onPrimary: Colors.white,
        secondary: const Color(0xFF06785F),
        surface: ValColors.lightBackground,
        onSurface: ValColors.ink,
        onSurfaceVariant: const Color(0xFF636366),
        outline: const Color(0xFFC7C7CC),
        error: const Color(0xFFC8202F),
        surfaceContainerLow: const Color(0xFFF7F7FA),
        surfaceContainer: ValColors.lightSurface,
        surfaceContainerHigh: ValColors.lightSurfaceHigh,
        surfaceContainerHighest: ValColors.lightTrack,
        surfaceTint: Colors.transparent,
        outlineVariant: const Color(0xFFDADADF),
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
