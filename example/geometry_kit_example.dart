import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';

void main() {
  //Polygon
  final polygon = [
    Point(1, 0),
    Point(0, 2),
    Point(0, 3),
    Point(2, 5),
    Point(3, 5),
    Point(5, 3),
    Point(5, 1),
    Point(3, 0),
  ];

  final point1 = Point<num>(5, 2);
  var isInside = PolygonUtils.isInsidePolygon(point1, polygon);
  print(isInside); // true

  final point2 = Point<num>(9, 2);
  isInside = PolygonUtils.isInsidePolygon(point2, polygon);
  print(isInside); //false

  // Line
  final line1 = Line(Point(0, 2), Point(2, 0));
  final line2 = Line(Point(0, -1), Point(3, 2));

  final intersect = LineUtils.getSegmentIntersect(line1, line2);

  print(intersect); //Point(1.5, 0.5)
}
