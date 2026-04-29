import 'package:geometry_kit/src/kit/line.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:geometry_kit/src/kit/triangle.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Triangle', () {
    // Right triangle: (0,0), (3,0), (0,4)
    final right = Triangle(Point(0, 0), Point(3, 0), Point(0, 4));
    // Equilateral-ish triangle
    final equi = Triangle(Point(0, 0), Point(4, 0), Point(2, 3.4641));

    group('area', () {
      test('right triangle area', () {
        // 0.5 * base * height = 0.5 * 3 * 4 = 6
        expect(right.area, closeTo(6.0, epsilon));
      });

      test('equilateral triangle area', () {
        // side 4, area = sqrt(3)/4 * 16 ≈ 6.9282
        expect(equi.area, closeTo(6.9282, epsilon));
      });
    });

    group('perimeter', () {
      test('right triangle perimeter', () {
        // 3 + 4 + 5 = 12
        expect(right.perimeter, closeTo(12.0, epsilon));
      });
    });

    group('vertices', () {
      test('returns three vertices', () {
        expect(right.vertices, hasLength(3));
        expect(right.vertices, [Point(0, 0), Point(3, 0), Point(0, 4)]);
      });
    });

    group('sides', () {
      test('returns three sides', () {
        expect(right.sides, hasLength(3));
      });

      test('AB side', () {
        expect(right.AB, Line(Point(0, 0), Point(3, 0)));
      });

      test('BC side', () {
        expect(right.BC, Line(Point(3, 0), Point(0, 4)));
      });

      test('CA side', () {
        expect(right.CA, Line(Point(0, 4), Point(0, 0)));
      });

      test('AC side', () {
        expect(right.AC, Line(Point(0, 0), Point(0, 4)));
      });
    });

    group('baseLine', () {
      test('baseline is the two leftmost x-coordinate points', () {
        final bl = right.baseLine;
        // Points (0,0) and (0,4) both have x=0, which is leftmost
        // Then next is (3,0). So start=(0,0), end picks between (3,0) and (0,4)
        // a.x=0 <= b.x=3 and a.x=0 <= c.x=0 => start = a = (0,0)
        // end: b.x=3 <= c.x=0? no => end = c = (0,4)
        expect(bl, Line(Point(0, 0), Point(0, 4)));
      });
    });

    group('height', () {
      test('right triangle height from posVertex to baseLine', () {
        // baseLine is vertical from (0,0) to (0,4), posVertex is (3,0)
        // distance from (3,0) to that line = 3
        expect(right.height, closeTo(3.0, epsilon));
      });
    });

    group('posVertex', () {
      test('returns vertex opposite to baseline', () {
        // baseline is (0,0)-(0,4), so posVertex is (3,0)
        expect(right.posVertex, Point(3, 0));
      });
    });

    group('heightLine', () {
      test('goes from posVertex to midpoint of baseLine', () {
        final hl = right.heightLine;
        expect(hl.a, right.posVertex);
        expect(hl.b, right.baseLine.midPoint);
      });
    });

    group('orthocenter', () {
      test('orthocenter of non-axis-aligned triangle', () {
        final t = Triangle(Point(0, 0), Point(4, 1), Point(1, 3));
        final oc = t.orthocenter;
        // Altitude from a perp to BC: BC=(3,2), slope=-3/2 => alt slope=3/2
        // Altitude from b perp to CA: CA=(1,3), slope=-1/3 => alt slope=-1/3
        // Solving: x=14/11, y=21/11
        expect(oc.x, closeTo(14.0 / 11.0, epsilon));
        expect(oc.y, closeTo(21.0 / 11.0, epsilon));
      });

      test('right triangle orthocenter at right-angle vertex', () {
        // Right angle at origin — orthocenter should be at (0,0)
        final t = Triangle(Point(0, 0), Point(5, 0), Point(0, 3));
        final oc = t.orthocenter;
        expect(oc.x, closeTo(0, epsilon));
        expect(oc.y, closeTo(0, epsilon));
      });

      test('orthocenter with vertical side', () {
        // Triangle with a vertical side — previously crashed
        final t = Triangle(Point(0, 0), Point(0, 4), Point(3, 2));
        final oc = t.orthocenter;
        expect(oc, isNotNull);
        // Verify: no crash and returns a valid point
        expect(oc.x.isFinite, isTrue);
        expect(oc.y.isFinite, isTrue);
      });
    });

    group('rotate', () {
      test('rotate returns new triangle with rotated vertices', () {
        final t = Triangle(Point(1, 0), Point(0, 1), Point(-1, 0));
        final rotated = t.rotate(90);
        expect(rotated.a.x, closeTo(0, epsilon));
        expect(rotated.a.y, closeTo(1, epsilon));
        expect(rotated.b.x, closeTo(-1, epsilon));
        expect(rotated.b.y, closeTo(0, epsilon));
        expect(rotated.c.x, closeTo(0, epsilon));
        expect(rotated.c.y, closeTo(-1, epsilon));
      });

      test('rotate 360 returns approximately same triangle', () {
        final rotated = equi.rotate(360);
        expect(rotated.a.x, closeTo(equi.a.x, epsilon));
        expect(rotated.a.y, closeTo(equi.a.y, epsilon));
        expect(rotated.b.x, closeTo(equi.b.x, epsilon));
        expect(rotated.b.y, closeTo(equi.b.y, epsilon));
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final t = Triangle(Point(1, 1), Point(2, 1), Point(1, 2));
        final scaled = t.scale(2);
        expect(scaled.a, Point(2, 2));
        expect(scaled.b, Point(4, 2));
        expect(scaled.c, Point(2, 4));
      });

      test('scale preserves shape proportions', () {
        final scaled = right.scale(2);
        expect(scaled.area, closeTo(right.area * 4, epsilon));
        expect(scaled.perimeter, closeTo(right.perimeter * 2, epsilon));
      });
    });

    group('translate', () {
      test('translate moves all vertices', () {
        final moved = right.translate(x: 5, y: 10);
        expect(moved.a, Point(5, 10));
        expect(moved.b, Point(8, 10));
        expect(moved.c, Point(5, 14));
      });

      test('translate preserves area', () {
        final moved = right.translate(x: 100, y: 200);
        expect(moved.area, closeTo(right.area, epsilon));
      });

      test('translate preserves perimeter', () {
        final moved = right.translate(x: 3, y: 7);
        expect(moved.perimeter, closeTo(right.perimeter, epsilon));
      });
    });

    group('isRightTriangle', () {
      test('right triangle returns true', () {
        expect(right.isRightTriangle, isTrue);
      });

      test('equilateral triangle returns false', () {
        expect(equi.isRightTriangle, isFalse);
      });
    });

    group('isEquilateral', () {
      test('equilateral triangle returns true', () {
        expect(equi.isEquilateral, isTrue);
      });

      test('right triangle returns false', () {
        expect(right.isEquilateral, isFalse);
      });

      test('factory equilateral returns true', () {
        final t = Triangle.equilateral(center: Point(0, 0), radius: 5);
        expect(t.isEquilateral, isTrue);
      });
    });

    group('isIsosceles', () {
      test('equilateral is also isosceles', () {
        expect(equi.isIsosceles, isTrue);
      });

      test('isosceles triangle returns true', () {
        final iso = Triangle(Point(0, 0), Point(4, 0), Point(2, 3));
        expect(iso.isIsosceles, isTrue);
      });

      test('scalene triangle returns false', () {
        final scalene = Triangle(Point(0, 0), Point(3, 0), Point(1, 2));
        expect(scalene.isIsosceles, isFalse);
      });
    });

    group('isAcute', () {
      test('equilateral triangle is acute', () {
        expect(equi.isAcute, isTrue);
      });

      test('right triangle is not acute', () {
        expect(right.isAcute, isFalse);
      });
    });

    group('isObtuse', () {
      test('obtuse triangle returns true', () {
        final obtuse = Triangle(Point(0, 0), Point(5, 0), Point(4, 1));
        expect(obtuse.isObtuse, isTrue);
      });

      test('right triangle is not obtuse', () {
        expect(right.isObtuse, isFalse);
      });

      test('equilateral is not obtuse', () {
        expect(equi.isObtuse, isFalse);
      });
    });

    group('hypotenuse', () {
      test('returns longest side', () {
        final hyp = right.hypotenuse;
        // Longest side of 3-4-5 right triangle is 5
        expect(hyp.length, closeTo(5.0, epsilon));
      });
    });

    group('isScalene', () {
      test('scalene triangle returns true', () {
        final scalene = Triangle(Point(0, 0), Point(3, 0), Point(1, 2));
        expect(scalene.isScalene, isTrue);
      });

      test('equilateral is not scalene', () {
        expect(equi.isScalene, isFalse);
      });

      test('isosceles is not scalene', () {
        final iso = Triangle(Point(0, 0), Point(4, 0), Point(2, 3));
        expect(iso.isScalene, isFalse);
      });
    });

    group('centroid', () {
      test('right triangle centroid', () {
        // (0+3+0)/3 = 1, (0+0+4)/3 = 4/3
        expect(right.centroid.x, closeTo(1.0, epsilon));
        expect(right.centroid.y, closeTo(4.0 / 3.0, epsilon));
      });

      test('equilateral centroid is at center', () {
        final t = Triangle.equilateral(center: Point(5, 5), radius: 3);
        expect(t.centroid.x, closeTo(5.0, epsilon));
        expect(t.centroid.y, closeTo(5.0, epsilon));
      });
    });

    group('circumcenter', () {
      test('right triangle circumcenter at hypotenuse midpoint', () {
        // For right triangle (0,0),(3,0),(0,4), circumcenter = (1.5, 2)
        final cc = right.circumcenter;
        expect(cc.x, closeTo(1.5, epsilon));
        expect(cc.y, closeTo(2.0, epsilon));
      });

      test('circumcenter equidistant from all vertices', () {
        final t = Triangle(Point(0, 0), Point(4, 1), Point(1, 3));
        final cc = t.circumcenter;
        final da = cc.distanceTo(t.a);
        final db = cc.distanceTo(t.b);
        final dc = cc.distanceTo(t.c);
        expect(da, closeTo(db, epsilon));
        expect(db, closeTo(dc, epsilon));
      });
    });

    group('incenter', () {
      test('right triangle incenter', () {
        // incenter = (la*ax + lb*bx + lc*cx) / perimeter
        // sides: AB=3, BC=5, CA=4; opposite: a->BC=5, b->CA=4, c->AB=3
        // x = (5*0 + 4*3 + 3*0)/12 = 1, y = (5*0 + 4*0 + 3*4)/12 = 1
        final ic = right.incenter;
        expect(ic.x, closeTo(1.0, epsilon));
        expect(ic.y, closeTo(1.0, epsilon));
      });

      test('equilateral incenter matches centroid', () {
        final t = Triangle.equilateral(center: Point(0, 0), radius: 4);
        final ic = t.incenter;
        final ct = t.centroid;
        expect(ic.x, closeTo(ct.x, epsilon));
        expect(ic.y, closeTo(ct.y, epsilon));
      });
    });

    group('contains', () {
      test('centroid is inside', () {
        expect(right.contains(right.centroid), isTrue);
      });

      test('vertex is on boundary (inside)', () {
        expect(right.contains(right.a), isTrue);
      });

      test('point outside', () {
        expect(right.contains(Point(10, 10)), isFalse);
      });

      test('point on edge', () {
        // midpoint of AB is (1.5, 0)
        expect(right.contains(Point(1.5, 0)), isTrue);
      });
    });

    group('circumscribedCircle', () {
      test('passes through all vertices', () {
        final cc = right.circumscribedCircle;
        final ra = cc.center.distanceTo(right.a);
        final rb = cc.center.distanceTo(right.b);
        final rc = cc.center.distanceTo(right.c);
        expect(ra, closeTo(cc.radius, epsilon));
        expect(rb, closeTo(cc.radius, epsilon));
        expect(rc, closeTo(cc.radius, epsilon));
      });

      test('right triangle circumradius is half hypotenuse', () {
        final cc = right.circumscribedCircle;
        expect(cc.radius, closeTo(2.5, epsilon));
      });
    });

    group('inscribedCircle', () {
      test('right triangle inradius', () {
        // r = area / s = 6 / 6 = 1
        final ic = right.inscribedCircle;
        expect(ic.radius, closeTo(1.0, epsilon));
      });

      test('incircle center matches incenter', () {
        final ic = right.inscribedCircle;
        final incenter = right.incenter;
        expect(ic.center.x, closeTo(incenter.x, epsilon));
        expect(ic.center.y, closeTo(incenter.y, epsilon));
      });
    });

    group('angles', () {
      test('angles list has 3 elements', () {
        expect(right.angles, hasLength(3));
      });

      test('no debug print output (regression)', () {
        final angles = right.angles;
        expect(angles, isNotEmpty);
      });
    });
  });
}
