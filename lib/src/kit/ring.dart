import 'dart:math';

import 'point.dart';

/// A ring (annulus) defined by two concentric circles.
///
/// The ring is the region between [innerRadius] and [outerRadius]
/// centered at [center].
class Ring {
  /// Center point of the ring
  final Point center;

  /// Inner radius (hole)
  final double innerRadius;

  /// Outer radius (boundary)
  final double outerRadius;

  /// Creates a ring with given [center], [innerRadius], and [outerRadius].
  ///
  /// [outerRadius] must be greater than [innerRadius], and [innerRadius]
  /// must be non-negative.
  const Ring({
    required this.center,
    required this.innerRadius,
    required this.outerRadius,
  }) : assert(outerRadius > innerRadius && innerRadius >= 0);

  /// Width of the ring (outer - inner)
  double get width => outerRadius - innerRadius;

  /// Area of the ring
  double get area => pi * (outerRadius * outerRadius - innerRadius * innerRadius);

  /// Outer circumference
  double get outerCircumference => 2 * pi * outerRadius;

  /// Inner circumference
  double get innerCircumference => 2 * pi * innerRadius;

  /// Average radius (midpoint between inner and outer)
  double get averageRadius => (innerRadius + outerRadius) / 2;

  /// Check if a point is inside the ring
  ///
  /// Returns `true` if point is between inner and outer boundary.
  bool contains(Point point) {
    final dist = center.distanceTo(point);
    return dist >= innerRadius && dist <= outerRadius;
  }

  /// Translate the ring
  Ring translate({double x = 0, double y = 0}) {
    return Ring(
      center: Point(center.x + x, center.y + y),
      innerRadius: innerRadius,
      outerRadius: outerRadius,
    );
  }

  /// Scale the ring by [factor]
  Ring scale(double factor) {
    return Ring(
      center: center.scale(factor),
      innerRadius: innerRadius * factor,
      outerRadius: outerRadius * factor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ring &&
        other.center == center &&
        other.innerRadius == innerRadius &&
        other.outerRadius == outerRadius;
  }

  @override
  int get hashCode =>
      center.hashCode ^ innerRadius.hashCode ^ outerRadius.hashCode;

  @override
  String toString() =>
      'Ring(center: $center, innerRadius: $innerRadius, outerRadius: $outerRadius)';
}
