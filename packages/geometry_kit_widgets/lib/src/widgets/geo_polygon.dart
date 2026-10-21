import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/polygon_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_path.dart';
import 'geo_shape_container.dart';

/// A widget that paints a [Polygon] from an ordered vertex list.
///
/// Two constructors: [GeoPolygon] from a `List<Offset>` (≥ 3 points), or
/// [GeoPolygon.fromGeometry] from an existing [Polygon]. Style flows
/// from [style], the closest [ShapeStyleTheme], or a default 1px black
/// stroke. [onTap] / [onHoverChanged] use shape-precise hit-test — taps
/// inside the widget rect but outside the polygon outline are ignored.
class GeoPolygon extends StatelessWidget {
  /// The geometry polygon to paint.
  final Polygon polygon;

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

  /// Creates a polygon widget from a list of vertex offsets.
  GeoPolygon({
    super.key,
    required List<Offset> vertices,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
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
      interactionPathBuilder: () => shapeToPath(polygon, mapper),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      painter: PolygonPainter(
        polygon: polygon,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
