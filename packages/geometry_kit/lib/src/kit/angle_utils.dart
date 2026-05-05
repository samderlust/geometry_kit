import 'dart:math';

/// Angle Utils
///
/// Deprecated: Use the extension methods in `units.dart` instead
/// (e.g., `90.0.toRad`, `pi.toDeg`).
@Deprecated('Use Rad/Deg extensions from units.dart instead')
class AngleUtils {
  /// Degree to Radian
  @Deprecated('Use deg.toRad instead')
  static double degreeToRadian(double deg) => deg * (pi / 180);

  /// Gradian to Radian
  @Deprecated('Use gradianToRadian from units.dart instead')
  static double gradianToRadian(double grad) => grad * (pi / 200);

  /// Minute of Arc to Radian
  @Deprecated('Use units.dart extensions instead')
  static double minOfArcToRadian(double min) => min * pi / (180 * 60);

  /// Second of Arc to Radian
  @Deprecated('Use units.dart extensions instead')
  static double secOfArcToRadian(double sec) => sec * pi / (180 * 3600);

  /// Radian to Degree
  @Deprecated('Use rad.toDeg instead')
  static double radianToDegree(double rad) => rad * (180 / pi);

  /// Gradian to Degree
  @Deprecated('Use units.dart extensions instead')
  static double gradianToDegree(double grad) => grad * (180 / 200);

  /// Minute of Arc to Degree
  @Deprecated('Use units.dart extensions instead')
  static double minOfArcToDegree(double min) => min / 60;

  /// Second of Arc to Degree
  @Deprecated('Use units.dart extensions instead')
  static double secOfArcToDegree(double sec) => sec / 3600;
}
