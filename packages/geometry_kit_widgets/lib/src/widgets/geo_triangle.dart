import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/triangle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';

/// A widget that paints a [Triangle] from three vertices.
class GeoTriangle extends StatelessWidget {
  /// The geometry triangle to paint.
  final Triangle triangle;

  /// Style override. When `null`, resolves through [ShapeStyleTheme].
  final ShapeStyle? style;

  /// Coordinate mapper. Defaults to [CoordinateMapper.identity].
  final CoordinateMapper mapper;

  /// Logical size of the widget.
  final Size size;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Creates a triangle widget from three vertex offsets.
  GeoTriangle({
    super.key,
    required Offset a,
    required Offset b,
    required Offset c,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.semanticLabel,
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
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final resolved =
        style ?? ShapeStyleTheme.resolve(context, const ShapeStyle());
    return Semantics(
      label: semanticLabel,
      child: RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: TrianglePainter(
            triangle: triangle,
            style: resolved,
            mapper: mapper,
          ),
        ),
      ),
    );
  }
}
