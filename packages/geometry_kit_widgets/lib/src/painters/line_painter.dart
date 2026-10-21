import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/dash_pattern.dart';
import '../style/shape_style.dart';
import '../util/dashed_path.dart';

/// [CustomPainter] that draws a [Line] segment.
///
/// Lines have no interior — only stroking applies. If [style] has no
/// `strokeColor` the painter falls back to `fillColor`. `strokeGradient`
/// is not supported (zero-area bounds make shader resolution
/// degenerate); asserted off in debug, ignored in release.
class LinePainter extends CustomPainter {
  /// The geometry line to paint.
  final Line line;

  /// Resolved style applied to the line.
  final ShapeStyle style;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Creates a line painter.
  const LinePainter({
    required this.line,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gradient strokes are not supported on lines: zero-area bounds make
    // shader resolution degenerate. Documented in plan/decorative_styling.md.
    assert(
      style.strokeGradient == null,
      'ShapeStyle.strokeGradient is not supported on GeoLine — use strokeColor instead.',
    );

    // Lines have no interior — fall back to fillColor if no strokeColor.
    final color = style.strokeColor ?? style.fillColor;
    final rawWidth = style.strokeWidth ?? 1.0;
    final width = rawWidth > 0 ? rawWidth : 1.0;
    final opacity = style.opacity ?? 1.0;
    if (color == null) return;

    final a = mapper.toCanvas(line.a.x, line.a.y);
    final b = mapper.toCanvas(line.b.x, line.b.y);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy);

    final paint = Paint()
      ..color = color.withValues(alpha: color.a * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = style.strokeCap ?? StrokeCap.butt
      ..strokeJoin = style.strokeJoin ?? StrokeJoin.miter;

    final resolved =
        style.strokePaintBuilder?.call(paint, path.getBounds()) ?? paint;

    final out = style.dashPattern != null
        ? buildDashedPath(path, style.dashPattern as DashPattern)
        : path;
    canvas.drawPath(out, resolved);
  }

  @override
  bool shouldRepaint(covariant LinePainter old) =>
      !identical(old.line, line) || old.style != style || old.mapper != mapper;
}
