import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';

/// The ValHub launcher icon drawn in code (navy tile, red "V", bone star,
/// red underline — `assets/icon/icon.png`), so the About hub shows the real
/// app icon without bundling the PNG.
class AppIconMark extends StatelessWidget {
  const AppIconMark({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.235),
          boxShadow: [
            BoxShadow(
              color: ValColors.red.withValues(alpha: 0.28),
              blurRadius: size * 0.3,
              offset: Offset(0, size * 0.09),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.235),
          child: CustomPaint(
            size: Size.square(size),
            painter: const _IconPainter(),
          ),
        ),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  const _IconPainter();

  static const _navy = Color(0xFF0F1720);
  static const _sheen = Color(0xFF1D2A37);
  static const _bone = Color(0xFFECE8E1);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 1024;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          // A painter has no reading direction: the logo's light is fixed.
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 0.35, 1],
          colors: [_navy, _sheen, _navy],
        ).createShader(rect),
    );
    final red = Paint()..color = ValColors.red;
    final v = Path()
      ..moveTo(220 * s, 237 * s)
      ..lineTo(385 * s, 237 * s)
      ..lineTo(512 * s, 585 * s)
      ..lineTo(638 * s, 237 * s)
      ..lineTo(804 * s, 237 * s)
      ..lineTo(585 * s, 787 * s)
      ..lineTo(440 * s, 787 * s)
      ..close();
    canvas.drawPath(v, red);
    canvas.drawPath(
      _star(Offset(512 * s, 358 * s), 64 * s, 26 * s),
      Paint()..color = _bone,
    );
    canvas.drawRect(Rect.fromLTRB(410 * s, 926 * s, 614 * s, 938 * s), red);
  }

  static Path _star(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) => false;
}
