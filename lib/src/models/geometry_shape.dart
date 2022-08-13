import 'dart:math';

/// GeometryShape
///
///
abstract class GeometryShape {
  final Point center;

  GeometryShape(this.center);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeometryShape && other.center == center;
  }

  @override
  int get hashCode => center.hashCode;
}
