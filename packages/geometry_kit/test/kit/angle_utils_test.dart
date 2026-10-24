import 'dart:math';

import 'package:geometry_kit/src/kit/angle_utils.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('AngleUtils', () {
    group('degreeToRadian', () {
      test('180 degrees = pi', () {
        expect(AngleUtils.degreeToRadian(180), closeTo(pi, epsilon));
      });

      test('90 degrees = pi/2', () {
        expect(AngleUtils.degreeToRadian(90), closeTo(pi / 2, epsilon));
      });

      test('0 degrees = 0', () {
        expect(AngleUtils.degreeToRadian(0), closeTo(0, epsilon));
      });
    });

    group('radianToDegree', () {
      test('pi = 180 degrees', () {
        expect(AngleUtils.radianToDegree(pi), closeTo(180, epsilon));
      });

      test('pi/2 = 90 degrees', () {
        expect(AngleUtils.radianToDegree(pi / 2), closeTo(90, epsilon));
      });
    });

    group('gradianToRadian', () {
      test('200 gradian = pi', () {
        expect(AngleUtils.gradianToRadian(200), closeTo(pi, epsilon));
      });
    });

    group('gradianToDegree', () {
      test('200 gradian = 180 degrees', () {
        expect(AngleUtils.gradianToDegree(200), closeTo(180, epsilon));
      });

      test('100 gradian = 90 degrees', () {
        expect(AngleUtils.gradianToDegree(100), closeTo(90, epsilon));
      });
    });

    group('secOfArcToRadian', () {
      test('3600 arc seconds = 1 degree in radians', () {
        expect(AngleUtils.secOfArcToRadian(3600),
            closeTo(AngleUtils.degreeToRadian(1), epsilon));
      });
    });

    group('secOfArcToDegree', () {
      test('3600 arc seconds = 1 degree', () {
        expect(AngleUtils.secOfArcToDegree(3600), closeTo(1, epsilon));
      });
    });

    group('minOfArcToRadian', () {
      test('60 arc minutes = 1 degree in radians', () {
        expect(AngleUtils.minOfArcToRadian(60),
            closeTo(AngleUtils.degreeToRadian(1), epsilon));
      });
    });

    group('minOfArcToDegree', () {
      test('60 arc minutes = 1 degree', () {
        expect(AngleUtils.minOfArcToDegree(60), closeTo(1, epsilon));
      });
    });

    group('roundtrip', () {
      test('degree -> radian -> degree', () {
        final deg = 45.0;
        final rad = AngleUtils.degreeToRadian(deg);
        expect(AngleUtils.radianToDegree(rad), closeTo(deg, epsilon));
      });
    });
  });
}
