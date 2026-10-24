import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../painters/rectangle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_path.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [geo.Rectangle], optionally rounded.
///
/// Two constructors: [GeoRectangle] from `x, y, width, height`, or
/// [GeoRectangle.fromGeometry] from an existing [geo.Rectangle].
/// [cornerRadius] (default [Radius.zero]) renders an `RRect` over the
/// AABB of the mapped corners — useful for rotated mappers where the
/// rounded variant tracks the visual bounding box. Style flows from
/// [style], the closest [ShapeStyleTheme], or a default 1px black
/// stroke. [onTap] / [onHoverChanged] respect [cornerRadius]: taps in
/// the cut-off corners are correctly rejected.
class GeoRectangle extends GeoShapeWidget {
  /// The geometry rectangle to paint.
  final geo.Rectangle rectangle;

  /// Corner radius for rounded rectangles. Defaults to [Radius.zero].
  final Radius cornerRadius;

  /// Creates a rectangle widget with explicit position and size.
  GeoRectangle({
    super.key,
    required double x,
    required double y,
    required double width,
    required double height,
    super.style,
    super.mapper,
    this.cornerRadius = Radius.zero,
    super.size,
    super.clipBehavior,
    super.semanticLabel,
    super.onTap,
    super.onHoverChanged,
    super.onDragStart,
    super.onDragUpdate,
    super.onDragEnd,
    super.debugOverlay,
  }) : rectangle = geo.Rectangle(x: x, y: y, width: width, height: height);

  /// Creates a rectangle widget from an existing [geo.Rectangle] geometry.
  const GeoRectangle.fromGeometry({
    super.key,
    required this.rectangle,
    super.style,
    super.mapper,
    this.cornerRadius = Radius.zero,
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
  geo.Geometry get geometry => rectangle;

  @override
  CustomPainter createPainter(ShapeStyle resolved) => RectanglePainter(
    rectangle: rectangle,
    style: resolved,
    mapper: mapper,
    cornerRadius: cornerRadius,
  );

  @override
  bool Function(Offset position)? get hitTest =>
      cornerRadius == Radius.zero ? null : (p) => _hitPath().contains(p);

  /// Hit-test path: matches the painted shape, including [cornerRadius].
  ///
  /// Sharp rectangles fall back to [shapeToPath]; rounded ones build an
  /// `RRect` over the AABB of the mapped corners (same construction as
  /// [RectanglePainter]).
  Path _hitPath() {
    if (cornerRadius == Radius.zero) {
      return shapeToPath(rectangle, mapper);
    }
    final corners = <Offset>[
      mapper.toCanvas(rectangle.x, rectangle.y),
      mapper.toCanvas(rectangle.x + rectangle.width, rectangle.y),
      mapper.toCanvas(
        rectangle.x + rectangle.width,
        rectangle.y + rectangle.height,
      ),
      mapper.toCanvas(rectangle.x, rectangle.y + rectangle.height),
    ];
    double minX = corners[0].dx, maxX = corners[0].dx;
    double minY = corners[0].dy, maxY = corners[0].dy;
    for (final c in corners) {
      if (c.dx < minX) minX = c.dx;
      if (c.dx > maxX) maxX = c.dx;
      if (c.dy < minY) minY = c.dy;
      if (c.dy > maxY) maxY = c.dy;
    }
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(minX, minY, maxX, maxY),
        cornerRadius,
      ),
    );
  }
}
