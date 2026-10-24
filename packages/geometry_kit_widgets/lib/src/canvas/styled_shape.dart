import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:geometry_kit/geometry_kit.dart' show Geometry;

import '../debug/geo_debug_overlay.dart';
import '../style/shape_style.dart';

/// A pairing of a piece of geometry with the [ShapeStyle] used to draw it.
///
/// Used by [GeometryCanvas] to render a list of mixed shapes in one pass.
/// An optional [id] lets callers identify shapes returned from hit-test
/// callbacks. [onTap] / [onHoverChanged] / drag callbacks receive
/// shape-precise pointer dispatch from `GeometryCanvas` (top-down: the
/// topmost shape under the pointer wins).
@immutable
class StyledShape {
  /// The geometry: any `geometry_kit` [Geometry] — the closed `Shape`s
  /// (`Circle`, `Ellipse`, `Rectangle`, `Triangle`, `Quadrilateral`,
  /// `Polygon`, `Capsule`), `Ring`, and the open curves (`Line`,
  /// `Polyline`, `Arc`, `QuadraticBezier`, `CubicBezier`, `Spline`, `Ray`)
  /// — or this package's `ArcSector`.
  ///
  /// Typed [Geometry] rather than `Shape` because the curves are not
  /// shapes (no area, possibly unbounded). A `Geometry` from another package
  /// that `shapeToPath` does not know is skipped, with a debug warning.
  final Geometry shape;

  /// Style applied when painting [shape]. Open curves are stroked only.
  final ShapeStyle style;

  /// Optional identifier — surfaces in `onShapeTap` and friends.
  final String? id;

  /// Fires when the pointer taps this shape. Higher (later) shapes in the
  /// canvas list block taps for shapes underneath.
  final VoidCallback? onTap;

  /// Fires with `true` when the pointer enters this shape's outline, and
  /// with `false` when it leaves (or the topmost-shape under the pointer
  /// changes to a different shape, or the pointer exits the canvas).
  final ValueChanged<bool>? onHoverChanged;

  /// Fires when a drag that starts on this shape begins.
  ///
  /// Setting any drag callback makes the shape draggable. While the drag is
  /// in flight the canvas draws the shape displaced by the pointer.
  final VoidCallback? onDragStart;

  /// Fires per drag frame with the pointer delta in geometry space.
  /// Informational — the canvas already draws the drag; do not also move
  /// the geometry here.
  final ValueChanged<Offset>? onDragUpdate;

  /// Fires when the drag ends with the total displacement in geometry
  /// space. The drawn offset then resets, so commit the move here by
  /// replacing [shape] with `shape.translate(x: d.dx, y: d.dy)` — every
  /// [Geometry] has `translate`.
  final ValueChanged<Offset>? onDragEnd;

  /// Authoring aids for this shape. Overrides
  /// `GeometryCanvas.debugOverlay`.
  final GeoDebugOverlay? debugOverlay;

  /// Creates a styled shape.
  const StyledShape(
    this.shape, {
    required this.style,
    this.id,
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
  });

  /// Whether any pointer callback is set.
  bool get isInteractive =>
      onTap != null || onHoverChanged != null || isDraggable;

  /// Whether any drag callback is set.
  bool get isDraggable =>
      onDragStart != null || onDragUpdate != null || onDragEnd != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StyledShape &&
          identical(other.shape, shape) &&
          other.style == style &&
          other.id == id &&
          other.onTap == onTap &&
          other.onHoverChanged == onHoverChanged &&
          other.onDragStart == onDragStart &&
          other.onDragUpdate == onDragUpdate &&
          other.onDragEnd == onDragEnd &&
          other.debugOverlay == debugOverlay);

  @override
  int get hashCode => Object.hash(
    identityHashCode(shape),
    style,
    id,
    onTap,
    onHoverChanged,
    onDragStart,
    onDragUpdate,
    onDragEnd,
    debugOverlay,
  );
}
