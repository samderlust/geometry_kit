import 'package:flutter/rendering.dart';

import '../style/shape_style.dart';
import 'dashed_path.dart';

/// Renders [path] onto [canvas] using fill + stroke from [style].
///
/// Order: fill first, stroke second (stroke sits visually on top).
/// Honours [ShapeStyle.dashPattern] via [buildDashedPath].
void paintShapePath(Canvas canvas, Path path, ShapeStyle style) {
  if (style.fillColor != null) {
    final fill = Paint()
      ..color = style.fillColor!.withValues(alpha: style.opacity)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);
  }
  if (style.strokeColor != null && style.strokeWidth > 0) {
    final stroke = Paint()
      ..color = style.strokeColor!.withValues(alpha: style.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.strokeWidth
      ..strokeCap = style.strokeCap
      ..strokeJoin = style.strokeJoin;
    final out = style.dashPattern != null
        ? buildDashedPath(path, style.dashPattern!)
        : path;
    canvas.drawPath(out, stroke);
  }
}
