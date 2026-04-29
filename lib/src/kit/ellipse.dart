import 'dart:math';

import '../interface/shape.dart';
import 'point.dart';

/// An ellipse defined by its center and two radii.
///
/// [radiusX] is the semi-major or semi-minor axis along the x-axis,
/// [radiusY] is along the y-axis.
class Ellipse extends Shape {
  /// Center point of the ellipse
  final Point center;

  /// Semi-axis length along the x-axis
  final double radiusX;

  /// Semi-axis length along the y-axis
  final double radiusY;

  const Ellipse({
    required this.center,
    required this.radiusX,
    required this.radiusY,
  });

  /// Create a circle-like ellipse with equal radii
  factory Ellipse.circular({
    required Point center,
    required double radius,
  }) {
    return Ellipse(center: center, radiusX: radius, radiusY: radius);
  }

  /// Whether this ellipse is a circle (equal radii)
  bool get isCircle => radiusX == radiusY;

  /// The semi-major axis (longer radius)
  double get semiMajor => max(radiusX, radiusY);

  /// The semi-minor axis (shorter radius)
  double get semiMinor => min(radiusX, radiusY);

  /// Eccentricity of the ellipse (0 = circle, approaching 1 = very elongated)
  double get eccentricity {
    final a = semiMajor;
    final b = semiMinor;
    return sqrt(1 - (b * b) / (a * a));
  }

  /// Distance from center to each focus
  double get focalDistance {
    final a = semiMajor;
    final b = semiMinor;
    return sqrt(a * a - b * b);
  }

  /// The two foci of the ellipse
  ///
  /// Foci are along the major axis.
  List<Point> get foci {
    final d = focalDistance;
    if (radiusX >= radiusY) {
      return [
        Point(center.x - d, center.y),
        Point(center.x + d, center.y),
      ];
    } else {
      return [
        Point(center.x, center.y - d),
        Point(center.x, center.y + d),
      ];
    }
  }

  /// Get a point on the ellipse boundary at the given [angle] in radians
  Point pointAt(double angle) {
    return Point(
      center.x + radiusX * cos(angle),
      center.y + radiusY * sin(angle),
    );
  }

  /// Check if a point is inside this ellipse
  bool contains(Point point) {
    final dx = point.x - center.x;
    final dy = point.y - center.y;
    return (dx * dx) / (radiusX * radiusX) +
            (dy * dy) / (radiusY * radiusY) <=
        1.0;
  }

  /// Get area of ellipse
  @override
  double get area => pi * radiusX * radiusY;

  /// Get perimeter of ellipse (Ramanujan approximation)
  @override
  double get perimeter {
    final a = radiusX;
    final b = radiusY;
    final h = pow(a - b, 2) / pow(a + b, 2);
    return pi * (a + b) * (1 + 3 * h / (10 + sqrt(4 - 3 * h)));
  }

  @override
  Ellipse rotate(double deg) {
    // Axis-aligned ellipse rotation swaps radii at 90°.
    // For simplicity, rotate center only (ellipse stays axis-aligned).
    return Ellipse(
      center: center.rotate(deg),
      radiusX: radiusX,
      radiusY: radiusY,
    );
  }

  @override
  Ellipse scale(double value) {
    return Ellipse(
      center: center.scale(value),
      radiusX: radiusX * value,
      radiusY: radiusY * value,
    );
  }

  @override
  Ellipse translate({double x = 0, double y = 0}) {
    return Ellipse(
      center: Point(center.x + x, center.y + y),
      radiusX: radiusX,
      radiusY: radiusY,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ellipse &&
        other.center == center &&
        other.radiusX == radiusX &&
        other.radiusY == radiusY;
  }

  @override
  int get hashCode =>
      center.hashCode ^ radiusX.hashCode ^ radiusY.hashCode;

  @override
  String toString() =>
      'Ellipse(center: $center, radiusX: $radiusX, radiusY: $radiusY)';
}
