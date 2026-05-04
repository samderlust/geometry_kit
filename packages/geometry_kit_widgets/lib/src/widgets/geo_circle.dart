import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/circle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';

/// A widget that paints a [Circle] using a [CustomPainter].
///
/// Provides two constructors:
///
/// - [GeoCircle] — flat parameters (`radius`, `center`); the widget builds
///   the [Circle] internally. Easiest entry point.
/// - [GeoCircle.fromGeometry] — pass an existing [Circle] computed by
///   business logic.
///
/// Style is resolved from the explicit [style] parameter, falling back to
/// the closest [ShapeStyleTheme] ancestor, then to a default 1px black
/// stroke. Coordinate transforms are applied via [mapper] (defaults to
/// [CoordinateMapper.identity]).
class GeoCircle extends StatelessWidget {
  /// The geometry circle to paint.
  final Circle circle;

  /// Style to apply. When `null`, falls back to [ShapeStyleTheme.of] then
  /// to a default stroked black style.
  final ShapeStyle? style;

  /// Coordinate mapper. Defaults to [CoordinateMapper.identity].
  final CoordinateMapper mapper;

  /// Logical size of the widget.
  final Size size;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Creates a circle widget from a [radius] and [center].
  GeoCircle({
    super.key,
    required double radius,
    Offset center = Offset.zero,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.semanticLabel,
  }) : circle = Circle(
          radius: radius,
          center: Point(center.dx, center.dy),
        );

  /// Creates a circle widget from an existing [Circle] geometry.
  const GeoCircle.fromGeometry({
    super.key,
    required this.circle,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = style ??
        ShapeStyleTheme.resolve(
          context,
          const ShapeStyle(),
        );
    return Semantics(
      label: semanticLabel,
      child: RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: CirclePainter(
            circle: circle,
            style: resolved,
            mapper: mapper,
          ),
        ),
      ),
    );
  }
}
