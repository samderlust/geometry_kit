import 'package:geometry_kit/src/kit/line.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const epsilon = 0.01;
void main() {
  final l1 = Line(Point(1, 1), Point(2, 2));
  final l2 = Line(Point(0, 0), Point(4, 2));

  group("Test Line", () {
    test('test Line slope', () {
      expect(l1.slope, 1);
      expect(l2.slope, .5);
    });
    test('test length', () {
      expect(l2.length, closeTo(4.47, epsilon));
    });
  });
}
