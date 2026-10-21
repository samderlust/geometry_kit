import 'package:flutter/foundation.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../style/shape_style.dart';

/// A pairing of a geometry [Shape] with the [ShapeStyle] used to draw it.
///
/// Used by [GeometryCanvas] to render a list of mixed shapes in one pass.
/// An optional [id] lets callers identify shapes returned from hit-test
/// callbacks. [onTap] / [onHoverChanged] receive shape-precise pointer
/// dispatch from `GeometryCanvas` (top-down: the topmost shape covering the
/// pointer wins).
@immutable
class StyledShape {
  /// The geometry shape (any [Shape] subtype).
  final Shape shape;

  /// Style applied when painting [shape].
  final ShapeStyle style;

  /// Optional identifier — surfaces in `onShapeTap` and friends.
  final String? id;

  /// Fires when the pointer taps inside this shape's outline. Higher (later)
  /// shapes in the canvas list block taps for shapes underneath.
  final VoidCallback? onTap;

  /// Fires with `true` when the pointer enters this shape's outline, and
  /// with `false` when it leaves (or the topmost-shape under the pointer
  /// changes to a different shape, or the pointer exits the canvas).
  final ValueChanged<bool>? onHoverChanged;

  /// Creates a styled shape.
  const StyledShape(
    this.shape, {
    required this.style,
    this.id,
    this.onTap,
    this.onHoverChanged,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StyledShape &&
          identical(other.shape, shape) &&
          other.style == style &&
          other.id == id &&
          other.onTap == onTap &&
          other.onHoverChanged == onHoverChanged);

  @override
  int get hashCode =>
      Object.hash(identityHashCode(shape), style, id, onTap, onHoverChanged);
}
