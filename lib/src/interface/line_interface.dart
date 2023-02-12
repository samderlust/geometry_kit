import '../../geometry_kit.dart';
import '../kit/point.dart';

mixin LineInterface {
  double get length;
  Point get midPoint;
  bool intersect(Line line);
  Point? getIntersectPoint(Line line);
  double distanceToAPoint(Point point);

  ///isPointBelongToLineSegment
  bool hasPoint(Point point);

  ///angleOf2Lines
  double angleWith();
}
