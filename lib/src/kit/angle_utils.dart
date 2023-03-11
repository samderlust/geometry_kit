import 'dart:math';

/// Angle Utils
///
/// angle units convert
class AngleUtils {
  /// Degree to Radian
  static degreeToRadian(double deg) => deg * (pi / 180);

  /// Gradian to Radian
  static gradianToRadian(double grad) => grad * (pi / 200);

  /// Minute of Arc to Radian
  static minOfArcToRadian(double min) => min * (pi * 60 * 180);

  /// Second of Arc to Radian
  static secOfArcToRadian(double sec) => sec * pi / (180 * 3600);

  /// radian to Degree
  static radianToDegree(double rad) => rad * (180 / pi);

  /// gradian to Degree
  static gradianToDegree(double grad) => grad * (180 / 200);

  /// Minute of Arc to Degree
  static minOfArcToDegree(double min) => min / 60;

  /// Second of Arc to Degree
  static secOfArcToDegree(double sec) => sec / 3600;
}
