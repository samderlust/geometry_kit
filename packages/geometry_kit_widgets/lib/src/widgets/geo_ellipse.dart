import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/ellipse_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_path.dart';
import 'geo_shape_container.dart';

/// A widget that paints an axis-aligned [Ellipse].
///
/// Two constructors: [GeoEllipse] from radii + center, or
/// [GeoEllipse.fromGeometry] from an existing [Ellipse]. Style flows from
/// the explicit [style], the closest [ShapeStyleTheme] ancestor, or a
/// default 1px black stroke. Optional [onTap] / [onHoverChanged]
/// callbacks fire only when the pointer is inside the ellipse outline
/// (shape-precise hit-test, not the host widget rect).
class GeoEllipse extends StatelessWidget {
  /// The geometry ellipse to paint.
  final Ellipse ellipse;

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

  /// Creates an ellipse widget from radii and center.
  GeoEllipse({
    super.key,
    required double radiusX,
    required double radiusY,
    Offset center = Offset.zero,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
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
      interactionPathBuilder: () => shapeToPath(ellipse, mapper),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      painter: EllipsePainter(
        ellipse: ellipse,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
