import 'dart:math';

import 'package:geometry_kit/src/models/geometry_shape.dart';

/// Circle
///
///
class Circle extends GeometryShape {
  final double radius;
  Circle({
    required this.radius,
    required Point center,
  }) : super(center);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Circle && other.radius == radius && super == other;
  }

  @override
  int get hashCode => radius.hashCode;
}
