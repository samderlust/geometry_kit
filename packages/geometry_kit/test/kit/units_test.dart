import 'dart:math';

import 'package:geometry_kit/src/kit/units.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Units', () {
    group('Rad to Deg', () {
      test('pi radians = 180 degrees', () {
        Rad r = pi;
        expect(r.toDeg, closeTo(180, epsilon));
      });

      test('pi/2 radians = 90 degrees', () {
        Rad r = pi / 2;
        expect(r.toDeg, closeTo(90, epsilon));
      });

      test('0 radians = 0 degrees', () {
        Rad r = 0;
        expect(r.toDeg, closeTo(0, epsilon));
      });
    });

    group('Deg to Rad', () {
      test('180 degrees = pi radians', () {
        Deg d = 180;
        expect(d.toRad, closeTo(pi, epsilon));
      });

      test('90 degrees = pi/2 radians', () {
        Deg d = 90;
        expect(d.toRad, closeTo(pi / 2, epsilon));
      });

      test('0 degrees = 0 radians', () {
        Deg d = 0;
        expect(d.toRad, closeTo(0, epsilon));
      });

      test('360 degrees = 2*pi radians', () {
        Deg d = 360;
        expect(d.toRad, closeTo(2 * pi, epsilon));
      });
    });

    group('roundtrip', () {
      test('deg -> rad -> deg', () {
        Deg d = 45;
        expect(d.toRad.toDeg, closeTo(45, epsilon));
      });

      test('rad -> deg -> rad', () {
        Rad r = 1.5;
        expect(r.toDeg.toRad, closeTo(1.5, epsilon));
      });
    });
  });
}
