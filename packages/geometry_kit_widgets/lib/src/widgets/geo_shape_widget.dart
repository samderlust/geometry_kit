import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart' show Geometry;

import '../coord/coordinate_mapper.dart';
import '../debug/geo_debug_overlay.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_hit_test.dart';
import 'geo_shape_container.dart';

/// Shared base for the 2D `Geo*` widgets: holds the common style, layout,
/// pointer and debug parameters and builds the [GeoShapeContainer].
///
/// Subclasses supply [geometry] and [createPainter], and override
/// [hitTest] only when the default test on [geometry] doesn't match what
/// they paint. These hooks are `@protected`: they are inherited by the
/// exported widgets but are not part of the public API.
abstract class GeoShapeWidget extends StatelessWidget {
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

  /// Fires when the pointer is released on the shape — inside the outline
  /// for closed shapes, near the stroke for open curves.
  final VoidCallback? onTap;

  /// Fires with `true` when the pointer moves onto the shape, `false` when
  /// it leaves.
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

  const GeoShapeWidget({
    super.key,
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

  /// The geometry painted, hit-tested and shown by [debugOverlay].
  @protected
  Geometry get geometry;

  /// The painter for [geometry] drawn with the [resolved] style.
  @protected
  CustomPainter createPainter(ShapeStyle resolved);

  /// Custom hit test for when the painted outline is not [geometry]'s plain
  /// path. `null` uses the default test on [geometry].
  @protected
  bool Function(Offset position)? get hitTest => null;

  @override
  Widget build(BuildContext context) {
    final resolved = ShapeStyleTheme.resolve(context, style);
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      geometry: geometry,
      mapper: mapper,
      debugOverlay: debugOverlay,
      hitTest: hitTest,
      // Closed shapes test containment and ignore the tolerance.
      hitTolerance: curveHitTolerance(resolved),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      painter: createPainter(resolved),
    );
  }
}
