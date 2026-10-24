import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/line_painter.dart';
import '../style/shape_style.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [Line] segment between two points.
///
/// Lines have no interior, so the painter only strokes. If the supplied
/// [style] has no `strokeColor` it falls back to `fillColor`, then to
/// black. `strokeGradient` is not supported (zero-area bounds make
/// shader resolution degenerate); `strokePaintBuilder` still works for
/// blur / mask effects.
///
/// Two constructors: [GeoLine] from two `Offset`s, or
/// [GeoLine.fromGeometry] from an existing [Line]. Lines have no interior,
/// so [onTap] / [onHoverChanged] / drag hit when the pointer is within half
/// the stroke width plus a few pixels of the segment.
class GeoLine extends GeoShapeWidget {
  /// The geometry line to paint.
  final Line line;

  /// Creates a line widget from two endpoint offsets.
  GeoLine({
    super.key,
    required Offset a,
    required Offset b,
    super.style,
    super.mapper,
    super.size,
    super.clipBehavior,
    super.semanticLabel,
    super.onTap,
    super.onHoverChanged,
    super.onDragStart,
    super.onDragUpdate,
    super.onDragEnd,
    super.debugOverlay,
  }) : line = Line(Point(a.dx, a.dy), Point(b.dx, b.dy));

  /// Creates a line widget from an existing [Line] geometry.
  const GeoLine.fromGeometry({
    super.key,
    required this.line,
    super.style,
    super.mapper,
    super.size,
    super.clipBehavior,
    super.semanticLabel,
    super.onTap,
    super.onHoverChanged,
    super.onDragStart,
    super.onDragUpdate,
    super.onDragEnd,
    super.debugOverlay,
  });

  @override
  Geometry get geometry => line;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      LinePainter(line: line, style: resolved, mapper: mapper);
}
