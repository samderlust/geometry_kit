import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Text intersect', () {
    test('getSegmentIntersect 1', () {
      final line1 = Line(Point(0, 2), Point(2, 0));
      final line2 = Line(Point(0, -1), Point(3, 2));

      final intersect = LineUtils.getSegmentIntersect(line1, line2);
      expect(intersect, Point<num>(1.5, 0.5));
    });

    test('getSegmentIntersect 2', () {
      final line1 = Line(Point(126, -11), Point(129, -21));
      final line2 = Line(Point(123, -18), Point(131, -14));

      final intersect = LineUtils.getSegmentIntersect(line1, line2);
      expect(intersect, Point<num>(127.43478260869566, -15.782608695652174));
    });

    test('point belong to line segment', () {
      final line = Line(Point(0, 2), Point(2, 0));
      final point = Point<num>(1, 1);

      expect(LineUtils.isPointBelongToLineSegment(point, line), true);
    });

    test('point does not belong to line segment', () {
      final line = Line(Point(0, 2), Point(2, 0));
      final point = Point<num>(1, 2);

      expect(LineUtils.isPointBelongToLineSegment(point, line), false);
    });

    test('get mid point 1', () {
      final line = Line(Point(0, 2), Point(2, 0));
      final point = Point<num>(1, 1);

      expect(LineUtils.midPoint(line), point);
    });

    test('get mid point 1', () {
      final line = Line(Point(-1, 5), Point(2, 0));
      final midPoint = LineUtils.midPoint(line);

      expect(midPoint.distanceTo(line.p1), midPoint.distanceTo(line.p2));
    });

    test('get point to Line Distance', () {
      var line = Line(Point(1, 1), Point(-1, 1));
      var point = Point<num>(0, 0);

      expect(LineUtils.pointToLineDistance(point, line), 1);

      line = Line(Point(-1, 4), Point(-3, 1));
      point = Point<num>(0, 2);

      expect(
        LineUtils.pointToLineDistance(point, line),
        closeTo(1.941450686788302, .0001),
      );
    });
  });

  group('Test angle of 2 lines', () {
    test('angle of 2 lines 45 deg', () {
      final line1 = Line(Point(0, 0), Point(2, 2));
      final line2 = Line(Point(0, 0), Point(0, 2));

      expect(LineUtils.angleOf2Lines(line1, line2),
          closeTo(45 * pi / 180, .00001));
    });
    test('angle of 2 lines 45 deg with negative values', () {
      final line1 = Line(Point(-1, -1), Point(2, 2));
      final line2 = Line(Point(0, 0), Point(0, 2));

      expect(LineUtils.angleOf2Lines(line1, line2),
          closeTo(45 * pi / 180, .00001));
    });

    test('angle of 2 lines 90 deg', () {
      final line1 = Line(Point(0, 0), Point(2, 0));
      final line2 = Line(Point(0, 0), Point(0, 2));

      expect(LineUtils.angleOf2Lines(line1, line2),
          closeTo(90 * pi / 180, .00001));
    });

    test('angle of 2 lines 135 deg', () {
      final line1 = Line(Point(0, -2), Point(-2, 0));
      final line2 = Line(Point(0, 0), Point(0, 2));

      expect(LineUtils.angleOf2Lines(line1, line2),
          closeTo(135 * pi / 180, .00001));
    });

    test('angle of 2 lines 135 deg 2', () {
      final line1 = Line(Point(-2, 0), Point(0, -2));
      final line2 = Line(Point(0, 0), Point(0, 2));

      expect(LineUtils.angleOf2Lines(line1, line2),
          closeTo(135 * pi / 180, .00001));
    });

    test('angle of 2 lines 180 deg', () {
      final line1 = Line(Point(0, 0), Point(0, -2));
      final line2 = Line(Point(0, 0), Point(0, 2));

      expect(LineUtils.angleOf2Lines(line1, line2),
          closeTo(180 * pi / 180, .00001));
    });
  });
}
