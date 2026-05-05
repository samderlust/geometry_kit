import 'package:flutter/foundation.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../style/shape_style.dart';

/// A pairing of a geometry [Shape] with the [ShapeStyle] used to draw it.
///
/// Used by [GeometryCanvas] to render a list of mixed shapes in one pass.
/// An optional [id] lets callers identify shapes returned from hit-test
/// callbacks.
@immutable
class StyledShape {
  /// The geometry shape (any [Shape] subtype).
  final Shape shape;

  /// Style applied when painting [shape].
  final ShapeStyle style;

  /// Optional identifier — surfaces in `onShapeTap` and friends.
  final String? id;

  /// Creates a styled shape.
  const StyledShape(this.shape, {required this.style, this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StyledShape &&
          identical(other.shape, shape) &&
          other.style == style &&
          other.id == id);

  @override
  int get hashCode => Object.hash(identityHashCode(shape), style, id);
}
