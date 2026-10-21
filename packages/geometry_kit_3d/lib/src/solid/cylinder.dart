import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';

import '../math/point3.dart';
import 'revolved_solid.dart';

/// A right circular cylinder standing on [baseCenter] along [axis].
///
/// ```dart
/// final can = Cylinder(baseCenter: Point3.zero, radius: 0.5, height: 1.2);
/// print(can.volume);       // ~0.94
/// print(can.topCenter);    // Point3(0, 1.2, 0)
/// ```
class Cylinder extends RevolvedSolid {
  /// Centre of the bottom disk.
  final Point3 baseCenter;

  /// Unit direction from the bottom disk to the top disk.
  @override
  final Point3 axis;

  /// Radius of both disks.
  final double radius;

  /// Distance between the disks.
  final double height;

  /// Creates a cylinder. [axis] is normalized; defaults to straight up.
  Cylinder({
    required this.baseCenter,
    required this.radius,
    required this.height,
    Point3 axis = Point3.unitY,
  })  : assert(radius >= 0 && height >= 0),
        axis = axis.normalized;

  /// Centre of the top disk.
  Point3 get topCenter => baseCenter + axis * height;

  /// Area of the curved side.
  double get lateralArea => 2 * pi * radius * height;

  @override
  Point3 get origin => baseCenter;

  @override
  List<Point> get meridian => [
        const Point(0, 0),
        Point(radius, 0),
        Point(radius, height),
        Point(0, height),
      ];

  @override
  double get volume => pi * radius * radius * height;

  @override
  double get surfaceArea => 2 * pi * radius * (radius + height);

  @override
  Cylinder translate({double x = 0, double y = 0, double z = 0}) => Cylinder(
        baseCenter: baseCenter.translate(x: x, y: y, z: z),
        radius: radius,
        height: height,
        axis: axis,
      );

  @override
  Cylinder scale(double factor) => Cylinder(
        baseCenter: baseCenter * factor,
        radius: radius * factor.abs(),
        height: height * factor.abs(),
        axis: axis,
      );

  @override
  Cylinder rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) =>
      Cylinder(
        baseCenter: baseCenter.rotate(axis, deg, pivot: pivot),
        radius: radius,
        height: height,
        axis: this.axis.rotate(axis, deg),
      );

  @override
  bool operator ==(Object other) =>
      other is Cylinder &&
      other.baseCenter == baseCenter &&
      other.axis == axis &&
      other.radius == radius &&
      other.height == height;

  @override
  int get hashCode => Object.hash(baseCenter, axis, radius, height);

  @override
  String toString() =>
      'Cylinder(baseCenter: $baseCenter, radius: $radius, height: $height, axis: $axis)';
}
