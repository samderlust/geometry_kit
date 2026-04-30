import 'dart:math';

/// A value in radians.
///
/// Type alias for [double] that clarifies intent at API boundaries.
typedef Rad = double;

/// A value in degrees.
///
/// Type alias for [double] that clarifies intent at API boundaries.
typedef Deg = double;

/// Extension on [Rad] for converting radians to degrees.
extension RadX on Rad {
  /// Converts this radian value to degrees.
  double get toDeg => this * 180 / pi;
}

/// Extension on [Deg] for converting degrees to radians.
extension DegX on Deg {
  /// Converts this degree value to radians.
  double get toRad => this * pi / 180;
}
