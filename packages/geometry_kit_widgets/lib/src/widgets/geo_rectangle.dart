import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../painters/rectangle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_path.dart';
import 'geo_shape_container.dart';

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
class GeoRectangle extends StatelessWidget {
  /// The geometry rectangle to paint.
  final geo.Rectangle rectangle;

  /// Style override. When `null`, resolves through [ShapeStyleTheme].
  final ShapeStyle? style;

  /// Coordinate mapper. Defaults to [CoordinateMapper.identity].
  final CoordinateMapper mapper;

  /// Corner radius for rounded rectangles. Defaults to [Radius.zero].
  final Radius cornerRadius;

  /// Logical size of the widget.
  final Size size;

  /// How content extending past [size] is clipped.
  final Clip clipBehavior;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Fires when the pointer is released inside the shape outline.
  final VoidCallback? onTap;

  /// Fires with `true` on hover entry, `false` on exit.
  final ValueChanged<bool>? onHoverChanged;

  /// Creates a rectangle widget with explicit position and size.
  GeoRectangle({
    super.key,
    required double x,
    required double y,
    required double width,
    required double height,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.cornerRadius = Radius.zero,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
  }) : rectangle = geo.Rectangle(x: x, y: y, width: width, height: height);

  /// Creates a rectangle widget from an existing [geo.Rectangle] geometry.
  const GeoRectangle.fromGeometry({
    super.key,
    required this.rectangle,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.cornerRadius = Radius.zero,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ShapeStyleTheme.resolve(context, style);
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      interactionPathBuilder: () => _hitPath(),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      painter: RectanglePainter(
        rectangle: rectangle,
        style: resolved,
        mapper: mapper,
        cornerRadius: cornerRadius,
      ),
    );
  }

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
