import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/circle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [Circle] using a [CustomPainter].
///
/// Provides two constructors:
///
/// - [GeoCircle] — flat parameters (`radius`, `center`); the widget builds
///   the [Circle] internally.
/// - [GeoCircle.fromGeometry] — pass an existing [Circle].
///
/// Style is resolved from the explicit [style] parameter, falling back to
/// the closest [ShapeStyleTheme] ancestor, then to a default 1px black
/// stroke. Coordinate transforms flow through [mapper]
/// ([CoordinateMapper.identity] by default).
///
/// Content is clipped to [size] when [clipBehavior] is anything other than
/// [Clip.none] — set [clipBehavior] to [Clip.none] to let the shape draw
/// outside the widget bounds.
class GeoCircle extends GeoShapeWidget {
  /// The geometry circle to paint.
  final Circle circle;

  /// Creates a circle widget from a [radius] and [center].
  GeoCircle({
    super.key,
    required double radius,
    Offset center = Offset.zero,
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
  }) : circle = Circle(radius: radius, center: Point(center.dx, center.dy));

  /// Creates a circle widget from an existing [Circle] geometry.
  const GeoCircle.fromGeometry({
    super.key,
    required this.circle,
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
  Geometry get geometry => circle;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      CirclePainter(circle: circle, style: resolved, mapper: mapper);
}
