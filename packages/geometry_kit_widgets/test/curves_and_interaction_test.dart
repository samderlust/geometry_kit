import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';
import 'package:geometry_kit_widgets/src/util/shape_hit_test.dart';

const _blue = Color(0xFF0000FF);

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(alignment: Alignment.topLeft, child: child),
);

void _expectRect(Rect actual, Rect expected, {double eps = 0.5}) {
  expect(actual.left, closeTo(expected.left, eps));
  expect(actual.top, closeTo(expected.top, eps));
  expect(actual.right, closeTo(expected.right, eps));
  expect(actual.bottom, closeTo(expected.bottom, eps));
}

void main() {
  const identity = CoordinateMapper.identity;
  final quarter = Arc.fromDegrees(
    center: const Point(100, 100),
    radius: 50,
    startDeg: 0,
    endDeg: 90,
  );

  group('shapeToPath curves', () {
    test('Arc sweeps clockwise on screen with identity', () {
      _expectRect(
        shapeToPath(quarter, identity).getBounds(),
        const Rect.fromLTRB(100, 100, 150, 150),
      );
    });

    test('Arc sweeps up on screen with a Y-up mapper', () {
      final m = CoordinateMapper(origin: const Offset(0, 200), yUp: true);
      // Geometry center (100, 100) lands at canvas (100, 100); the quarter
      // from +X to +Y now rises.
      _expectRect(
        shapeToPath(quarter, m).getBounds(),
        const Rect.fromLTRB(100, 50, 150, 100),
      );
    });

    test('ArcSector is closed through the center', () {
      final path = shapeToPath(ArcSector(quarter), identity);
      expect(path.contains(const Offset(120, 120)), isTrue);
      expect(path.contains(const Offset(80, 80)), isFalse);
    });

    test('Ring leaves the hole empty', () {
      const ring = Ring(
        center: Point(100, 100),
        innerRadius: 20,
        outerRadius: 50,
      );
      final path = shapeToPath(ring, identity);
      expect(path.contains(const Offset(135, 100)), isTrue);
      expect(path.contains(const Offset(100, 100)), isFalse);
      expect(path.contains(const Offset(155, 100)), isFalse);
    });

    test('Capsule is a stadium in any orientation', () {
      const flat = Capsule(
        medialAxis: Line(Point(50, 100), Point(150, 100)),
        radius: 20,
      );
      final path = shapeToPath(flat, identity);
      _expectRect(path.getBounds(), const Rect.fromLTRB(30, 80, 170, 120));
      expect(path.contains(const Offset(165, 100)), isTrue);
      // Inside the bounds, outside the rounded cap.
      expect(path.contains(const Offset(167, 117)), isFalse);

      const diagonal = Capsule(
        medialAxis: Line(Point(50, 50), Point(150, 150)),
        radius: 10,
      );
      final d = shapeToPath(diagonal, identity);
      expect(d.contains(const Offset(100, 100)), isTrue);
      expect(d.contains(const Offset(150, 50)), isFalse);
    });

    test('zero-length Capsule is a circle', () {
      final c = Capsule.circle(center: const Point(50, 50), radius: 10);
      _expectRect(
        shapeToPath(c, identity).getBounds(),
        const Rect.fromLTRB(40, 40, 60, 60),
      );
    });

    test('Beziers span their endpoints', () {
      const quad = QuadraticBezier(
        start: Point(0, 100),
        control: Point(50, 0),
        end: Point(100, 100),
      );
      final q = cachedShapeBounds(quad, identity);
      expect(q.left, closeTo(0, 0.5));
      expect(q.right, closeTo(100, 0.5));
      // The apex of a quadratic is halfway to its control point.
      expect(q.top, closeTo(50, 0.5));

      const cubic = CubicBezier(
        start: Point(0, 0),
        control1: Point(0, 100),
        control2: Point(100, 100),
        end: Point(100, 0),
      );
      final c = cachedShapeBounds(cubic, identity);
      expect(c.bottom, closeTo(75, 0.5));
    });

    test('Spline passes through its control points', () {
      const pts = [Point(0, 0), Point(50, 80), Point(100, 20), Point(150, 60)];
      final path = shapeToPath(Spline(pts), identity);
      final samples = [
        for (final m in path.computeMetrics())
          for (var d = 0.0; d <= m.length; d += 0.5)
            m.getTangentForOffset(d)!.position,
      ];
      for (final p in pts) {
        final nearest = samples
            .map((s) => (s - Offset(p.x, p.y)).distance)
            .reduce((a, b) => a < b ? a : b);
        expect(nearest, lessThan(1));
      }
    });

    test('Polyline stays open', () {
      final line = Polyline(const [
        Point(0, 0),
        Point(100, 0),
        Point(100, 100),
      ]);
      final metric = shapeToPath(line, identity).computeMetrics().single;
      expect(metric.isClosed, isFalse);
      expect(metric.length, closeTo(200, 0.01));
    });

    test('Ray is cut to leave the canvas', () {
      final ray = Ray.fromAngle(const Point(20, 50), 0);
      final b = shapeToPath(
        ray,
        identity,
        size: const Size(200, 100),
      ).getBounds();
      expect(b.left, closeTo(20, 0.01));
      expect(b.right, greaterThanOrEqualTo(200));
    });

    test('unsupported types throw', () {
      expect(() => shapeToPath('nope', identity), throwsUnsupportedError);
    });
  });

  group('hitTestShape', () {
    test('open curves hit near the stroke, not inside the chord', () {
      expect(hitTestShape(quarter, identity, const Offset(150, 100)), isTrue);
      // On the arc at 45°.
      expect(
        hitTestShape(quarter, identity, const Offset(135.4, 135.4)),
        isTrue,
      );
      // Inside the region a closed path would cover.
      expect(hitTestShape(quarter, identity, const Offset(120, 115)), isFalse);
    });

    test('tolerance widens the reach of a line', () {
      const line = Line(Point(0, 50), Point(100, 50));
      expect(
        hitTestShape(line, identity, const Offset(50, 56), tolerance: 4),
        isFalse,
      );
      expect(
        hitTestShape(line, identity, const Offset(50, 56), tolerance: 8),
        isTrue,
      );
    });

    test('paths are cached per instance and mapper', () {
      final poly = Polygon(const [Point(0, 0), Point(10, 0), Point(5, 8)]);
      final a = cachedShapePath(poly, identity);
      expect(identical(cachedShapePath(poly, identity), a), isTrue);
      final shifted = CoordinateMapper(origin: const Offset(5, 5));
      expect(identical(cachedShapePath(poly, shifted), a), isFalse);
    });
  });

  group('curve widgets', () {
    testWidgets('every curve widget renders', (tester) async {
      await tester.pumpWidget(
        _host(
          Wrap(
            children: [
              GeoArc(
                radius: 40,
                center: const Offset(50, 50),
                startDeg: 0,
                endDeg: 270,
              ),
              GeoArc(
                radius: 40,
                center: const Offset(50, 50),
                startDeg: 0,
                endDeg: 120,
                sector: true,
                style: const ShapeStyle.filled(_blue),
              ),
              GeoRing(
                innerRadius: 20,
                outerRadius: 40,
                center: const Offset(50, 50),
              ),
              GeoCapsule(
                a: const Offset(30, 50),
                b: const Offset(120, 50),
                radius: 15,
              ),
              GeoBezierCurve.quadratic(
                start: Offset.zero,
                control: const Offset(50, 100),
                end: const Offset(100, 0),
              ),
              GeoBezierCurve.cubic(
                start: Offset.zero,
                control1: const Offset(0, 100),
                control2: const Offset(100, 100),
                end: const Offset(100, 0),
              ),
              GeoSpline(
                points: const [Offset(0, 0), Offset(50, 80), Offset(100, 20)],
              ),
              GeoPolyline(
                points: const [Offset(0, 0), Offset(50, 80), Offset(100, 20)],
              ),
              GeoRay(origin: const Offset(10, 10), angleDeg: 30),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(GeoArc), findsNWidgets(2));
    });

    testWidgets('GeoArc taps the curve when open, the slice as a sector', (
      tester,
    ) async {
      var open = 0;
      var sector = 0;
      await tester.pumpWidget(
        _host(
          Row(
            children: [
              GeoArc(
                radius: 40,
                center: const Offset(50, 50),
                startDeg: 0,
                endDeg: 90,
                size: const Size(100, 100),
                onTap: () => open++,
              ),
              GeoArc(
                radius: 40,
                center: const Offset(50, 50),
                startDeg: 0,
                endDeg: 90,
                sector: true,
                size: const Size(100, 100),
                onTap: () => sector++,
              ),
            ],
          ),
        ),
      );
      await tester.tapAt(const Offset(65, 65)); // inside the slice
      expect(open, 0);
      await tester.tapAt(const Offset(90, 50)); // on the curve
      expect(open, 1);
      await tester.tapAt(const Offset(165, 65));
      expect(sector, 1);
      await tester.tapAt(const Offset(135, 35)); // outside the slice
      expect(sector, 1);
    });

    testWidgets('GeoRing ignores taps in the hole', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          GeoRing(
            innerRadius: 20,
            outerRadius: 40,
            center: const Offset(50, 50),
            size: const Size(100, 100),
            onTap: () => taps++,
          ),
        ),
      );
      await tester.tapAt(const Offset(50, 50));
      expect(taps, 0);
      await tester.tapAt(const Offset(80, 50));
      expect(taps, 1);
    });

    testWidgets('GeoLine and GeoPolyline are tappable on the stroke', (
      tester,
    ) async {
      var line = 0;
      var poly = 0;
      await tester.pumpWidget(
        _host(
          Row(
            children: [
              GeoLine(
                a: const Offset(0, 50),
                b: const Offset(100, 50),
                size: const Size(100, 100),
                onTap: () => line++,
              ),
              GeoPolyline(
                points: const [Offset(0, 0), Offset(100, 100)],
                size: const Size(100, 100),
                onTap: () => poly++,
              ),
            ],
          ),
        ),
      );
      await tester.tapAt(const Offset(50, 52));
      expect(line, 1);
      await tester.tapAt(const Offset(50, 80));
      expect(line, 1);
      await tester.tapAt(const Offset(150, 50));
      expect(poly, 1);
      await tester.tapAt(const Offset(180, 20));
      expect(poly, 1);
    });

    test('GeoBezierCurve.fromGeometry rejects other types', () {
      expect(
        () => GeoBezierCurve.fromGeometry(
          curve: const Line(Point(0, 0), Point(1, 1)),
        ),
        throwsAssertionError,
      );
    });
  });

  group('drag', () {
    testWidgets('previews the drag and reports the total on end', (
      tester,
    ) async {
      final updates = <Offset>[];
      Offset? total;
      var started = 0;
      await tester.pumpWidget(
        _host(
          GeoCircle.fromGeometry(
            circle: const Circle(center: Point(50, 50), radius: 20),
            size: const Size(200, 200),
            onDragStart: () => started++,
            onDragUpdate: updates.add,
            onDragEnd: (t) => total = t,
          ),
        ),
      );
      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.moveBy(const Offset(10, 20));
      await tester.pump();
      expect(started, 1);
      final preview = tester.widget<Transform>(
        find.descendant(
          of: find.byType(GeoCircle),
          matching: find.byType(Transform),
        ),
      );
      final moved = updates.fold(Offset.zero, (a, b) => a + b);
      expect(preview.transform.getTranslation().x, closeTo(moved.dx, 0.01));
      expect(preview.transform.getTranslation().y, closeTo(moved.dy, 0.01));
      await gesture.up();
      await tester.pump();
      expect(total, isNotNull);
      expect(total!.dx, closeTo(moved.dx, 0.01));
      expect(total!.dy, closeTo(moved.dy, 0.01));
      final rest = tester.widget<Transform>(
        find.descendant(
          of: find.byType(GeoCircle),
          matching: find.byType(Transform),
        ),
      );
      expect(rest.transform.getTranslation().x, 0);
    });

    testWidgets('drags starting off the shape are ignored', (tester) async {
      var started = 0;
      await tester.pumpWidget(
        _host(
          GeoCircle.fromGeometry(
            circle: const Circle(center: Point(50, 50), radius: 20),
            size: const Size(200, 200),
            onDragStart: () => started++,
            onDragEnd: (_) => started++,
          ),
        ),
      );
      await tester.dragFrom(const Offset(150, 150), const Offset(40, 0));
      expect(started, 0);
    });

    testWidgets('a Y-up mapper reports geometry-space deltas', (tester) async {
      Offset? total;
      final mapper = CoordinateMapper.yUp(const Size(200, 200));
      await tester.pumpWidget(
        _host(
          GeoCircle.fromGeometry(
            // Canvas (50, 150).
            circle: const Circle(center: Point(50, 50), radius: 20),
            mapper: mapper,
            size: const Size(200, 200),
            onDragEnd: (t) => total = t,
          ),
        ),
      );
      final gesture = await tester.startGesture(const Offset(50, 150));
      await gesture.moveBy(const Offset(0, -20));
      await gesture.moveBy(const Offset(0, -20));
      await gesture.up();
      await tester.pump();
      // Up on screen is +Y in geometry space.
      expect(total!.dy, greaterThan(0));
      expect(total!.dx, closeTo(0, 0.01));
    });

    testWidgets('GeometryCanvas drags the top draggable shape', (tester) async {
      Offset? bottomTotal;
      Offset? topTotal;
      await tester.pumpWidget(
        _host(
          GeometryCanvas(
            size: const Size(200, 200),
            shapes: [
              StyledShape(
                const Circle(center: Point(80, 80), radius: 40),
                style: const ShapeStyle.filled(_blue),
                onDragEnd: (t) => bottomTotal = t,
              ),
              StyledShape(
                const Line(Point(0, 100), Point(200, 100)),
                style: const ShapeStyle.stroked(_blue, width: 2),
                onDragEnd: (t) => topTotal = t,
              ),
            ],
          ),
        ),
      );
      // On the line, which is above the circle.
      await tester.dragFrom(const Offset(70, 101), const Offset(0, 40));
      expect(topTotal, isNotNull);
      expect(bottomTotal, isNull);
      await tester.dragFrom(const Offset(70, 70), const Offset(30, 0));
      expect(bottomTotal, isNotNull);
    });

    test('vectorFromCanvas flips only Y', () {
      final m = CoordinateMapper.yUp(const Size(100, 100));
      expect(m.vectorFromCanvas(const Offset(3, 4)), const Offset(3, -4));
      expect(
        CoordinateMapper.identity.vectorFromCanvas(const Offset(3, 4)),
        const Offset(3, 4),
      );
    });
  });

  group('pass-through', () {
    testWidgets(
      'stacked widgets: a miss on the top shape reaches the one below',
      (tester) async {
        final taps = <String>[];
        Offset? dragged;
        await tester.pumpWidget(
          _host(
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  GeoCircle.fromGeometry(
                    circle: const Circle(center: Point(50, 50), radius: 30),
                    size: const Size(200, 200),
                    onTap: () => taps.add('bottom'),
                    onDragEnd: (d) => dragged = d,
                  ),
                  GeoCircle.fromGeometry(
                    circle: const Circle(center: Point(150, 150), radius: 30),
                    size: const Size(200, 200),
                    onTap: () => taps.add('top'),
                    onDragEnd: (_) {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tapAt(const Offset(50, 50));
        await tester.tapAt(const Offset(150, 150));
        expect(taps, ['bottom', 'top']);
        await tester.dragFrom(const Offset(50, 50), const Offset(40, 0));
        expect(dragged, isNotNull);
      },
    );

    testWidgets('drags off the shape scroll an enclosing list', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      var started = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            height: 300,
            child: ListView(
              controller: controller,
              children: [
                GeoCircle.fromGeometry(
                  circle: const Circle(center: Point(100, 100), radius: 30),
                  size: const Size(200, 200),
                  onDragStart: () => started++,
                ),
                const SizedBox(height: 600),
              ],
            ),
          ),
        ),
      );
      await tester.dragFrom(const Offset(20, 180), const Offset(0, -80));
      await tester.pump();
      expect(started, 0);
      expect(controller.offset, greaterThan(0));

      controller.jumpTo(0);
      await tester.pump();
      await tester.dragFrom(const Offset(100, 100), const Offset(0, -80));
      expect(started, 1);
      expect(controller.offset, 0);
    });

    testWidgets('GeometryCanvas lets misses through', (tester) async {
      var behind = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => behind++,
                  child: const SizedBox.expand(),
                ),
                GeometryCanvas(
                  size: const Size(200, 200),
                  shapes: [
                    StyledShape(
                      const Circle(center: Point(50, 50), radius: 20),
                      style: const ShapeStyle.filled(_blue),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tapAt(const Offset(50, 50));
      expect(behind, 0);
      await tester.tapAt(const Offset(150, 150));
      expect(behind, 1);
    });
  });

  group('GeometryCanvas curves', () {
    testWidgets('taps reach curves and ArcSector', (tester) async {
      final taps = <String>[];
      await tester.pumpWidget(
        _host(
          GeometryCanvas(
            size: const Size(200, 200),
            shapes: [
              StyledShape(
                ArcSector(quarter),
                style: const ShapeStyle.filled(_blue),
                onTap: () => taps.add('sector'),
              ),
              StyledShape(
                const QuadraticBezier(
                  start: Point(0, 20),
                  control: Point(100, 20),
                  end: Point(200, 20),
                ),
                style: const ShapeStyle.stroked(_blue),
                onTap: () => taps.add('bezier'),
              ),
            ],
          ),
        ),
      );
      await tester.tapAt(const Offset(120, 120));
      await tester.tapAt(const Offset(100, 21));
      await tester.tapAt(const Offset(100, 60));
      expect(taps, ['sector', 'bezier']);
    });
  });

  group('GeoGrid', () {
    testWidgets('lines at multiples of spacing plus axes', (tester) async {
      await tester.pumpWidget(
        _host(
          const GeometryCanvas(
            size: Size(100, 100),
            shapes: [],
            grid: GeoGrid(spacing: 20),
          ),
        ),
      );
      final paint = tester.renderObject(
        find.descendant(
          of: find.byType(GeometryCanvas),
          matching: find.byType(CustomPaint),
        ),
      );
      // 6 vertical + 6 horizontal (0, 20 … 100) + 2 axes.
      expect(paint, paintsExactlyCountTimes(#drawLine, 14));
    });

    testWidgets('grid follows a centered mapper', (tester) async {
      await tester.pumpWidget(
        _host(
          GeometryCanvas(
            size: const Size(100, 100),
            mapper: CoordinateMapper.centered(const Size(100, 100)),
            shapes: const [],
            grid: const GeoGrid(spacing: 25, showAxes: false),
          ),
        ),
      );
      final paint = tester.renderObject(
        find.descendant(
          of: find.byType(GeometryCanvas),
          matching: find.byType(CustomPaint),
        ),
      );
      // x = 0, 25, 50, 75, 100 → 5 each way.
      expect(
        paint,
        paints..line(p1: const Offset(0, 0), p2: const Offset(0, 100)),
      );
      expect(paint, paintsExactlyCountTimes(#drawLine, 10));
    });
  });

  group('GeoDebugOverlay', () {
    testWidgets('vertices draw one dot per corner', (tester) async {
      await tester.pumpWidget(
        _host(
          GeoPolygon(
            vertices: const [Offset(10, 10), Offset(90, 10), Offset(50, 80)],
            size: const Size(100, 100),
            debugOverlay: const GeoDebugOverlay(
              showBoundingBox: false,
              showCenter: false,
            ),
          ),
        ),
      );
      final paint = tester.renderObject(
        find.descendant(
          of: find.byType(GeoPolygon),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint, paintsExactlyCountTimes(#drawCircle, 3));
    });

    testWidgets('all layers render for every shape type on a canvas', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          GeometryCanvas(
            size: const Size(300, 300),
            debugOverlay: GeoDebugOverlay.all,
            shapes: [
              for (final shape in <Object>[
                const Circle(center: Point(50, 50), radius: 20),
                const Ellipse(center: Point(50, 50), radiusX: 30, radiusY: 10),
                const Rectangle(x: 10, y: 10, width: 40, height: 20),
                Triangle(
                  const Point(0, 0),
                  const Point(40, 0),
                  const Point(20, 30),
                ),
                Polygon(const [Point(0, 0), Point(40, 0), Point(20, 30)]),
                const Line(Point(0, 0), Point(50, 50)),
                quarter,
                ArcSector(quarter),
                const Ring(
                  center: Point(150, 150),
                  innerRadius: 10,
                  outerRadius: 30,
                ),
                const Capsule(
                  medialAxis: Line(Point(10, 200), Point(90, 200)),
                  radius: 10,
                ),
                const QuadraticBezier(
                  start: Point(0, 0),
                  control: Point(50, 90),
                  end: Point(100, 0),
                ),
                Spline(const [Point(0, 0), Point(40, 40), Point(80, 0)]),
                Polyline(const [Point(0, 0), Point(40, 40), Point(80, 0)]),
                Ray.fromAngle(const Point(150, 20), 45),
              ])
                StyledShape(shape, style: const ShapeStyle()),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final paint = tester.renderObject(
        find.descendant(
          of: find.byType(GeometryCanvas),
          matching: find.byType(CustomPaint),
        ),
      );
      // One dimension label per shape.
      expect(paint, paintsExactlyCountTimes(#drawParagraph, 14));
    });
  });
}
