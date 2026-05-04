import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/polygon_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';

/// A widget that paints a [Polygon] from an ordered vertex list.
class GeoPolygon extends StatelessWidget {
  /// The geometry polygon to paint.
  final Polygon polygon;

  /// Style override. When `null`, resolves through [ShapeStyleTheme].
  final ShapeStyle? style;

  /// Coordinate mapper. Defaults to [CoordinateMapper.identity].
  final CoordinateMapper mapper;

  /// Logical size of the widget.
  final Size size;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Creates a polygon widget from a list of vertex offsets.
  GeoPolygon({
    super.key,
    required List<Offset> vertices,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.semanticLabel,
  })  : assert(vertices.length >= 3),
        polygon = Polygon(
          vertices.map((o) => Point(o.dx, o.dy)).toList(growable: false),
        );

  /// Creates a polygon widget from an existing [Polygon] geometry.
  const GeoPolygon.fromGeometry({
    super.key,
    required this.polygon,
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
          painter: PolygonPainter(
            polygon: polygon,
            style: resolved,
            mapper: mapper,
          ),
        ),
      ),
    );
  }
}
