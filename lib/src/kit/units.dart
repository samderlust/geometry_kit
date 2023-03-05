import 'dart:math';

/// Radian unit
typedef Rad = double;

/// Degree unit
typedef Deg = double;

extension RadX on Rad {
  double get toDeg => this * 180 / pi;
}

extension DegX on Deg {
  double get toRad => this * pi / 180;
}
