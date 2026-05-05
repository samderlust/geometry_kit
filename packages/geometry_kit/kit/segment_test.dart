import 'package:geometry_kit/src/kit/line.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:geometry_kit/src/kit/segment.dart';
import 'package:test/test.dart';

void main() {
  group('Segment', () {
    test('Segment is alias for Line', () {
      final seg = Segment(Point(0, 0), Point(3, 4));
      expect(seg, isA<Line>());
    });

    test('has all Line properties', () {
      final seg = Segment(Point(0, 0), Point(3, 4));
      expect(seg.length, 5.0);
      expect(seg.midPoint, Point(1.5, 2.0));
      expect(seg.slope, isNotNull);
    });

    test('interchangeable with Line', () {
      final Line line = Segment(Point(1, 2), Point(3, 4));
      final Segment seg = Line(Point(1, 2), Point(3, 4));
      expect(line == seg, isTrue);
    });
  });
}
