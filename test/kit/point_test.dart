import 'package:geometry_kit/src/kit/point.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const epsilon = 0.01;
void main() {
  final p1 = Point(1, 1);
  final p2 = Point(3, 4);
  group("Test Point", () {
    test('distance', () {
      expect(p1.distanceTo(p2), closeTo(3.60, epsilon));
    });

    test('point from distance', () {
      expect(p1.pointAtDistance(3.06), Point(3, 4));
    });
  });
}
