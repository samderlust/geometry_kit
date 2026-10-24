import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../debug/geo_debug_overlay.dart';
import '../painters/triangle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
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

  /// Fires when a drag that starts inside the shape begins.
  ///
  /// Setting any drag callback makes the shape draggable. While the drag is
  /// in flight the widget draws the shape displaced by the pointer; no
  /// geometry is rebuilt per frame.
  final VoidCallback? onDragStart;

  /// Fires per drag frame with the pointer delta in geometry space (the
  /// [mapper]'s Y flip applied). Informational — the widget already draws
  /// the drag; do not also move the geometry here.
  final ValueChanged<Offset>? onDragUpdate;

  /// Fires when the drag ends with the total displacement in geometry
  /// space. The drawn offset then resets, so commit the move here by
  /// translating the geometry.
  final ValueChanged<Offset>? onDragEnd;

  /// Optional authoring aids (bounding box, center, vertices, dimensions)
  /// drawn above the shape.
  final GeoDebugOverlay? debugOverlay;

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
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
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
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ShapeStyleTheme.resolve(context, style);
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      geometry: triangle,
      mapper: mapper,
      debugOverlay: debugOverlay,
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      painter: TrianglePainter(
        triangle: triangle,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
