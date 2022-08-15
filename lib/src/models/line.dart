import 'dart:math';

import '../../geometry_kit.dart';

/// Line
class Line {
  final Point p1;
  final Point p2;
  Line(
    this.p1,
    this.p2,
  ) : assert(p1 != p2);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Line && other.p1 == p1 && other.p2 == p2;
  }

  @override
  int get hashCode => p1.hashCode ^ p2.hashCode;
}

extension LineExtension on Line {
  num get aVal => p2.y - p1.y;
  num get bVal => p1.x - p2.x;
  num get cVal => aVal * p1.x + bVal * p1.y;
  num get x1 => p1.x;
  num get y1 => p1.y;
  num get x2 => p2.x;
  num get y2 => p2.y;
  double get length => LineUtils.lineLength(this);
}
