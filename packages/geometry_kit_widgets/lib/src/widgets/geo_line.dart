import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/line_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import 'geo_shape_container.dart';

/// A widget that paints a [Line] segment between two points.
///
/// Lines have no interior, so the painter only strokes. If the supplied
/// [style] has no `strokeColor` it falls back to `fillColor`, then to
/// black.
class GeoLine extends StatelessWidget {
  /// The geometry line to paint.
  final Line line;

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

  /// Creates a line widget from two endpoint offsets.
  GeoLine({
    super.key,
    required Offset a,
    required Offset b,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
  }) : line = Line(Point(a.dx, a.dy), Point(b.dx, b.dy));

  /// Creates a line widget from an existing [Line] geometry.
  const GeoLine.fromGeometry({
    super.key,
    required this.line,
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
      painter: LinePainter(
        line: line,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
