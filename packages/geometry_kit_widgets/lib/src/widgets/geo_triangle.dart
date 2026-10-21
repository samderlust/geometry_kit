import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/triangle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_path.dart';
import 'geo_shape_container.dart';

/// A widget that paints a [Triangle] from three vertices.
///
/// Two constructors: [GeoTriangle] from three `Offset`s, or
/// [GeoTriangle.fromGeometry] from an existing [Triangle]. Style flows
/// from [style], the closest [ShapeStyleTheme], or a default 1px black
/// stroke. [onTap] / [onHoverChanged] hit-test against the triangle
/// outline — taps in the widget rect but outside the three edges are
/// ignored.
class GeoTriangle extends StatelessWidget {
  /// The geometry triangle to paint.
  final Triangle triangle;

  /// Style override. When `null`, resolves through [ShapeStyleTheme].
  final ShapeStyle? style;

  /// Coordinate mapper. Defaults to [CoordinateMapper.identity].
  final CoordinateMapper mapper;

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

  /// Creates a triangle widget from three vertex offsets.
  GeoTriangle({
    super.key,
    required Offset a,
    required Offset b,
    required Offset c,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
  }) : triangle = Triangle(
          Point(a.dx, a.dy),
          Point(b.dx, b.dy),
          Point(c.dx, c.dy),
        );

  /// Creates a triangle widget from an existing [Triangle] geometry.
  const GeoTriangle.fromGeometry({
    super.key,
    required this.triangle,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    final resolved =
        ShapeStyleTheme.resolve(context, style);
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      interactionPathBuilder: () => shapeToPath(triangle, mapper),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      painter: TrianglePainter(
        triangle: triangle,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
