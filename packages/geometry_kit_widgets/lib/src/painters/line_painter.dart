import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/dash_pattern.dart';
import '../style/shape_style.dart';
import '../util/dashed_path.dart';

class LinePainter extends CustomPainter {
  final Line line;
  final ShapeStyle style;
  final CoordinateMapper mapper;

  const LinePainter({
    required this.line,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Lines have no interior — fall back to fillColor if no strokeColor.
    final color = style.strokeColor ?? style.fillColor;
    final width = style.strokeWidth > 0 ? style.strokeWidth : 1.0;
    if (color == null) return;

    final a = mapper.toCanvas(line.a.x, line.a.y);
    final b = mapper.toCanvas(line.b.x, line.b.y);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy);

    final paint = Paint()
      ..color = color.withValues(alpha: style.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = style.strokeCap
      ..strokeJoin = style.strokeJoin;

    final out = style.dashPattern != null
        ? buildDashedPath(path, style.dashPattern as DashPattern)
        : path;
    canvas.drawPath(out, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter old) =>
      !identical(old.line, line) ||
      old.style != style ||
      old.mapper != mapper;
}
