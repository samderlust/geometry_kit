import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/quadrilateral_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import 'geo_shape_container.dart';

/// A widget that paints a [Quadrilateral] from four ordered vertices.
class GeoQuadrilateral extends StatelessWidget {
  /// The geometry quadrilateral to paint.
  final Quadrilateral quad;

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

  /// Creates a quadrilateral widget from four vertex offsets.
  GeoQuadrilateral({
    super.key,
    required Offset a,
    required Offset b,
    required Offset c,
    required Offset d,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
  }) : quad = Quadrilateral(
          Point(a.dx, a.dy),
          Point(b.dx, b.dy),
          Point(c.dx, c.dy),
          Point(d.dx, d.dy),
        );

  /// Creates a quadrilateral widget from an existing [Quadrilateral].
  const GeoQuadrilateral.fromGeometry({
    super.key,
    required this.quad,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final resolved =
        style ?? ShapeStyleTheme.resolve(context, const ShapeStyle());
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      painter: QuadrilateralPainter(
        quad: quad,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
