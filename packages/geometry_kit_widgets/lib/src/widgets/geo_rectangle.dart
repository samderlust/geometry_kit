import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../painters/rectangle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';

/// A widget that paints a [geo.Rectangle], optionally rounded.
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

  /// Optional accessibility label.
  final String? semanticLabel;

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
    this.semanticLabel,
  }) : rectangle = geo.Rectangle(
          x: x,
          y: y,
          width: width,
          height: height,
        );

  /// Creates a rectangle widget from an existing [geo.Rectangle] geometry.
  const GeoRectangle.fromGeometry({
    super.key,
    required this.rectangle,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.cornerRadius = Radius.zero,
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
          painter: RectanglePainter(
            rectangle: rectangle,
            style: resolved,
            mapper: mapper,
            cornerRadius: cornerRadius,
          ),
        ),
      ),
    );
  }
}
