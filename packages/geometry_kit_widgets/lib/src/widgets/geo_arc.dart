import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../debug/geo_debug_overlay.dart';
import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/arc_sector.dart';
import '../util/shape_hit_test.dart';
import 'geo_shape_container.dart';

/// A widget that paints an [Arc] — or, with [sector], the pie slice it
/// bounds.
///
/// Two constructors: [GeoArc] from a center, radius and start / end angles
/// in degrees, or [GeoArc.fromGeometry] from an existing [Arc]. The arc
/// sweeps counter-clockwise from start to end in geometry space (so
/// clockwise on screen under [CoordinateMapper.identity], whose Y axis
/// points down).
///
/// An open arc is stroked only and hit-tests by distance to the curve. A
/// sector ([sector] `true`) is closed by the two radii: it fills, and
/// hit-tests by containment.
class GeoArc extends StatelessWidget {
  /// The geometry arc to paint.
  final Arc arc;

  /// Paint the closed sector instead of the open arc.
  final bool sector;

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

  /// Fires when the pointer is released on the shape.
  final VoidCallback? onTap;

  /// Fires with `true` on hover entry, `false` on exit.
  final ValueChanged<bool>? onHoverChanged;

  /// Fires when a drag that starts on the shape begins.
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

  /// Creates an arc widget from a [radius], [center] and angles in degrees.
  GeoArc({
    super.key,
    required double radius,
    Offset center = Offset.zero,
    required double startDeg,
    required double endDeg,
    this.sector = false,
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
  }) : arc = Arc.fromDegrees(
         center: Point(center.dx, center.dy),
         radius: radius,
         startDeg: startDeg,
         endDeg: endDeg,
       );

  /// Creates an arc widget from an existing [Arc] geometry.
  const GeoArc.fromGeometry({
    super.key,
    required this.arc,
    this.sector = false,
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

  // One sector per arc instance, so rebuilds keep the geometry identity the
  // painter and the path cache key on.
  static final Expando<ArcSector> _sectors = Expando<ArcSector>();

  Object get _geometry => sector ? (_sectors[arc] ??= ArcSector(arc)) : arc;

  @override
  Widget build(BuildContext context) {
    final resolved = ShapeStyleTheme.resolve(context, style);
    final geometry = _geometry;
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      geometry: geometry,
      mapper: mapper,
      debugOverlay: debugOverlay,
      hitTolerance: curveHitTolerance(resolved),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      painter: GeometryPainter(
        shape: geometry,
        style: resolved,
        mapper: mapper,
      ),
    );
  }
}
