import 'dart:math';

import 'package:geometry_kit/src/kit/arc.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Arc', () {
    // Quarter circle: 0 to 90 degrees, radius 5, centered at origin
    final arc = Arc(
      center: Point(0, 0),
      radius: 5,
      startAngle: 0,
      endAngle: pi / 2,
    );

    group('constructors', () {
      test('default constructor', () {
        expect(arc.center, Point(0, 0));
        expect(arc.radius, 5);
        expect(arc.startAngle, 0);
        expect(arc.endAngle, closeTo(pi / 2, epsilon));
      });

      test('fromDegrees', () {
        final a = Arc.fromDegrees(
          center: Point(0, 0),
          radius: 5,
          startDeg: 0,
          endDeg: 90,
        );
        expect(a.startAngle, closeTo(0, epsilon));
        expect(a.endAngle, closeTo(pi / 2, epsilon));
      });
    });

    group('sweepAngle', () {
      test('quarter circle sweep', () {
        expect(arc.sweepAngle, closeTo(pi / 2, epsilon));
      });

      test('full circle sweep', () {
        final full = Arc(
          center: Point(0, 0),
          radius: 1,
          startAngle: 0,
          endAngle: 2 * pi,
        );
        expect(full.sweepAngle, closeTo(2 * pi, epsilon));
      });

      test('wrap-around sweep', () {
        final a = Arc(
          center: Point(0, 0),
          radius: 1,
          startAngle: 3 * pi / 2,
          endAngle: pi / 2,
        );
        // From 270° to 90° going CCW = 180°
        expect(a.sweepAngle, closeTo(pi, epsilon));
      });
    });

    group('length', () {
      test('quarter circle length', () {
        // length = radius * sweep = 5 * pi/2
        expect(arc.length, closeTo(5 * pi / 2, epsilon));
      });

      test('full circle length equals circumference', () {
        final full = Arc(
          center: Point(0, 0),
          radius: 3,
          startAngle: 0,
          endAngle: 2 * pi,
        );
        expect(full.length, closeTo(2 * pi * 3, epsilon));
      });
    });

    group('points', () {
      test('startPoint', () {
        expect(arc.startPoint.x, closeTo(5, epsilon));
        expect(arc.startPoint.y, closeTo(0, epsilon));
      });

      test('endPoint', () {
        expect(arc.endPoint.x, closeTo(0, epsilon));
        expect(arc.endPoint.y, closeTo(5, epsilon));
      });

      test('midPoint', () {
        // At 45 degrees
        final mid = arc.midPoint;
        expect(mid.x, closeTo(5 * cos(pi / 4), epsilon));
        expect(mid.y, closeTo(5 * sin(pi / 4), epsilon));
      });
    });

    group('pointAt', () {
      test('t=0 returns startPoint', () {
        final p = arc.pointAt(0);
        expect(p.x, closeTo(arc.startPoint.x, epsilon));
        expect(p.y, closeTo(arc.startPoint.y, epsilon));
      });

      test('t=1 returns endPoint', () {
        final p = arc.pointAt(1);
        expect(p.x, closeTo(arc.endPoint.x, epsilon));
        expect(p.y, closeTo(arc.endPoint.y, epsilon));
      });

      test('t=0.5 returns midPoint', () {
        final p = arc.pointAt(0.5);
        expect(p.x, closeTo(arc.midPoint.x, epsilon));
        expect(p.y, closeTo(arc.midPoint.y, epsilon));
      });
    });

    group('containsAngle', () {
      test('angle at start', () {
        expect(arc.containsAngle(0), isTrue);
      });

      test('angle in middle', () {
        expect(arc.containsAngle(pi / 4), isTrue);
      });

      test('angle outside', () {
        expect(arc.containsAngle(pi), isFalse);
      });
    });

    group('sectorArea', () {
      test('quarter circle sector area', () {
        // 0.5 * r^2 * sweep = 0.5 * 25 * pi/2
        expect(arc.sectorArea, closeTo(0.5 * 25 * pi / 2, epsilon));
      });

      test('full circle sector area equals circle area', () {
        final full = Arc(
          center: Point(0, 0),
          radius: 3,
          startAngle: 0,
          endAngle: 2 * pi,
        );
        expect(full.sectorArea, closeTo(pi * 9, epsilon));
      });
    });

    group('translate', () {
      test('moves center', () {
        final moved = arc.translate(x: 3, y: 4);
        expect(moved.center, Point(3, 4));
        expect(moved.radius, arc.radius);
        expect(moved.startAngle, arc.startAngle);
        expect(moved.endAngle, arc.endAngle);
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final scaled = arc.scale(2);
        expect(scaled.radius, 10);
        expect(scaled.length, closeTo(arc.length * 2, epsilon));
      });
    });

    group('equality', () {
      test('same arcs are equal', () {
        final a1 = Arc(center: Point(0, 0), radius: 5, startAngle: 0, endAngle: pi);
        final a2 = Arc(center: Point(0, 0), radius: 5, startAngle: 0, endAngle: pi);
        expect(a1 == a2, isTrue);
      });

      test('different arcs are not equal', () {
        final a1 = Arc(center: Point(0, 0), radius: 5, startAngle: 0, endAngle: pi);
        final a2 = Arc(center: Point(0, 0), radius: 5, startAngle: 0, endAngle: pi / 2);
        expect(a1 == a2, isFalse);
      });
    });

    test('toString', () {
      final a = Arc(center: Point(0, 0), radius: 1, startAngle: 0, endAngle: 1.0);
      expect(a.toString(),
          'Arc(center: Point(x: 0.0, y: 0.0), radius: 1.0, startAngle: 0.0, endAngle: 1.0)');
    });
  });
}
