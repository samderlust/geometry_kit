import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../debug/geo_debug_overlay.dart';
import '../painters/quadrilateral_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import 'geo_shape_container.dart';

/// A widget that paints a [Quadrilateral] from four ordered vertices.
///
/// Two constructors: [GeoQuadrilateral] from four `Offset`s, or
/// [GeoQuadrilateral.fromGeometry] from an existing [Quadrilateral]. Style
/// flows from [style], the closest [ShapeStyleTheme], or a default 1px
/// black stroke. [onTap] / [onHoverChanged] hit-test against the
/// quadrilateral path — taps in the widget rect but outside the four
/// edges are ignored.
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
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
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
      geometry: quad,
      mapper: mapper,
      debugOverlay: debugOverlay,
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      painter: QuadrilateralPainter(
        quad: quad,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
