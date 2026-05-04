import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/ellipse_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';

/// A widget that paints an [Ellipse] using a [CustomPainter].
class GeoEllipse extends StatelessWidget {
  /// The geometry ellipse to paint.
  final Ellipse ellipse;

  /// Style override. When `null`, resolves through [ShapeStyleTheme].
  final ShapeStyle? style;

  /// Coordinate mapper. Defaults to [CoordinateMapper.identity].
  final CoordinateMapper mapper;

  /// Logical size of the widget.
  final Size size;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Creates an ellipse widget from radii and center.
  GeoEllipse({
    super.key,
    required double radiusX,
    required double radiusY,
    Offset center = Offset.zero,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.semanticLabel,
  }) : ellipse = Ellipse(
          center: Point(center.dx, center.dy),
          radiusX: radiusX,
          radiusY: radiusY,
        );

  /// Creates an ellipse widget from an existing [Ellipse] geometry.
  const GeoEllipse.fromGeometry({
    super.key,
    required this.ellipse,
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
          painter: EllipsePainter(
            ellipse: ellipse,
            style: resolved,
            mapper: mapper,
          ),
        ),
      ),
    );
  }
}
