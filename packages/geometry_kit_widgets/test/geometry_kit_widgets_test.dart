import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

Paint _testBlurBuilder(Paint base, Rect bounds) =>
    base..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

void main() {
  group('ShapeStyle', () {
    test('value equality', () {
      const a = ShapeStyle.stroked(Color(0xFFFF0000), width: 2);
      const b = ShapeStyle.stroked(Color(0xFFFF0000), width: 2);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('isVisible', () {
      const empty = ShapeStyle(strokeColor: null);
      expect(empty.isVisible, isFalse);
      expect(const ShapeStyle.filled(Color(0xFF000000)).isVisible, isTrue);
    });

    test('gradient fill visible without fillColor', () {
      const style = ShapeStyle(
        fillGradient: RadialGradient(
          colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
        ),
        strokeColor: null,
      );
      expect(style.isVisible, isTrue);
      expect(style.fillColor, isNull);
    });

    test('gradient stroke visible without strokeColor', () {
      const style = ShapeStyle(
        strokeColor: null,
        strokeGradient: LinearGradient(
          colors: [Color(0xFF00FF00), Color(0xFF0000FF)],
        ),
        strokeWidth: 2,
      );
      expect(style.isVisible, isTrue);
    });

    test('value equality with gradients', () {
      const a = ShapeStyle(
        fillGradient: LinearGradient(
          colors: [Color(0xFFFF0000), Color(0xFF00FF00)],
        ),
      );
      const b = ShapeStyle(
        fillGradient: LinearGradient(
          colors: [Color(0xFFFF0000), Color(0xFF00FF00)],
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith preserves gradients when not overridden', () {
      const original = ShapeStyle(
        fillGradient: RadialGradient(
          colors: [Color(0xFFFFFF00), Color(0x00FFFF00)],
        ),
      );
      final updated = original.copyWith(strokeWidth: 4);
      expect(updated.fillGradient, equals(original.fillGradient));
      expect(updated.strokeWidth, 4);
    });

    test('PaintBuilder equality by identity', () {
      final a = ShapeStyle(
        fillColor: const Color(0xFFFF0000),
        fillPaintBuilder: _testBlurBuilder,
      );
      final b = ShapeStyle(
        fillColor: const Color(0xFFFF0000),
        fillPaintBuilder: _testBlurBuilder,
      );
      final c = ShapeStyle(
        fillColor: const Color(0xFFFF0000),
        fillPaintBuilder: (p, r) => p,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith preserves PaintBuilder when not overridden', () {
      final original = ShapeStyle(
        fillColor: const Color(0xFFFF0000),
        strokePaintBuilder: _testBlurBuilder,
      );
      final updated = original.copyWith(strokeWidth: 5);
      expect(updated.strokePaintBuilder, same(_testBlurBuilder));
    });

    test('merge: null fields fall back to base', () {
      const base = ShapeStyle(
        fillColor: Color(0xFFAA0000),
        strokeColor: Color(0xFF0000AA),
        strokeWidth: 3,
        opacity: 0.5,
      );
      const override = ShapeStyle(
        fillColor: Color(0xFF00FF00),
        strokeColor: null,
        strokeWidth: null,
        opacity: null,
      );
      final merged = override.merge(base);
      expect(merged.fillColor, const Color(0xFF00FF00));
      expect(merged.strokeColor, const Color(0xFF0000AA));
      expect(merged.strokeWidth, 3);
      expect(merged.opacity, 0.5);
    });

    test('merge: non-null fields win over base', () {
      const base = ShapeStyle(strokeWidth: 1, opacity: 1);
      const override = ShapeStyle(strokeWidth: 7, opacity: 0.25);
      final merged = override.merge(base);
      expect(merged.strokeWidth, 7);
      expect(merged.opacity, 0.25);
    });

    test('merge with null base returns this', () {
      const a = ShapeStyle.filled(Color(0xFFFF00FF));
      expect(identical(a.merge(null), a), isTrue);
    });
  });

  group('ShapeStyle.lerp', () {
    test('returns null when both inputs null', () {
      expect(ShapeStyle.lerp(null, null, 0.5), isNull);
    });

    test('returns the non-null side when other is null', () {
      const a = ShapeStyle.filled(Color(0xFFFF0000));
      expect(ShapeStyle.lerp(a, null, 0.3), same(a));
      expect(ShapeStyle.lerp(null, a, 0.3), same(a));
    });

    test('lerps colors and doubles', () {
      const a = ShapeStyle(
        fillColor: Color(0xFF000000),
        strokeWidth: 2,
        opacity: 0,
      );
      const b = ShapeStyle(
        fillColor: Color(0xFFFFFFFF),
        strokeWidth: 4,
        opacity: 1,
      );
      final mid = ShapeStyle.lerp(a, b, 0.5)!;
      expect(mid.strokeWidth, 3);
      expect(mid.opacity, 0.5);
      expect(mid.fillColor, isNotNull);
    });

    test('snaps gradients/enums at midpoint', () {
      const a = ShapeStyle(
        strokeCap: StrokeCap.butt,
        fillGradient: LinearGradient(
          colors: [Color(0xFFFF0000), Color(0xFF00FF00)],
        ),
      );
      const b = ShapeStyle(
        strokeCap: StrokeCap.round,
        fillGradient: LinearGradient(
          colors: [Color(0xFF0000FF), Color(0xFFFFFF00)],
        ),
      );
      final before = ShapeStyle.lerp(a, b, 0.49)!;
      final after = ShapeStyle.lerp(a, b, 0.51)!;
      expect(before.strokeCap, StrokeCap.butt);
      expect(before.fillGradient, a.fillGradient);
      expect(after.strokeCap, StrokeCap.round);
      expect(after.fillGradient, b.fillGradient);
    });
  });

  group('ShapeStyleTween', () {
    test('drives ShapeStyle.lerp', () {
      final tween = ShapeStyleTween(
        begin: const ShapeStyle(strokeWidth: 1),
        end: const ShapeStyle(strokeWidth: 5),
      );
      expect(tween.lerp(0)!.strokeWidth, 1);
      expect(tween.lerp(0.5)!.strokeWidth, 3);
      expect(tween.lerp(1)!.strokeWidth, 5);
    });
  });

  group('ShapeStyleTheme.resolve', () {
    testWidgets('explicit merges nulls from ambient', (tester) async {
      late ShapeStyle resolved;
      await tester.pumpWidget(
        ShapeStyleTheme(
          data: const ShapeStyle(fillColor: Color(0xFFAAAAAA), strokeWidth: 8),
          child: Builder(
            builder: (context) {
              resolved = ShapeStyleTheme.resolve(
                context,
                const ShapeStyle(strokeWidth: 2),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // explicit strokeWidth wins; null fillColor in override falls back
      // through merge to ambient.
      expect(resolved.strokeWidth, 2);
      expect(resolved.fillColor, const Color(0xFFAAAAAA));
    });

    testWidgets('null override returns ambient', (tester) async {
      late ShapeStyle resolved;
      const themeStyle = ShapeStyle(
        fillColor: Color(0xFF112233),
        strokeWidth: 9,
      );
      await tester.pumpWidget(
        ShapeStyleTheme(
          data: themeStyle,
          child: Builder(
            builder: (context) {
              resolved = ShapeStyleTheme.resolve(context, null);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, themeStyle);
    });
  });

  group('AnimatedShapeStyle', () {
    testWidgets('animates style change to subtree theme', (tester) async {
      late ShapeStyle observed;
      Widget build(ShapeStyle style) => Directionality(
        textDirection: TextDirection.ltr,
        child: AnimatedShapeStyle(
          style: style,
          duration: const Duration(milliseconds: 200),
          child: Builder(
            builder: (context) {
              observed = ShapeStyleTheme.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpWidget(
        build(const ShapeStyle(strokeWidth: 1, opacity: 0)),
      );
      expect(observed.strokeWidth, 1);
      expect(observed.opacity, 0);

      await tester.pumpWidget(
        build(const ShapeStyle(strokeWidth: 5, opacity: 1)),
      );
      expect(observed.strokeWidth, 1);

      await tester.pump(const Duration(milliseconds: 100));
      expect(observed.strokeWidth, closeTo(3, 0.5));

      await tester.pump(const Duration(milliseconds: 200));
      expect(observed.strokeWidth, 5);
      expect(observed.opacity, 1);
    });
  });

  group('CoordinateMapper', () {
    test('identity', () {
      const m = CoordinateMapper.identity;
      expect(m.toCanvas(10, 20), const Offset(10, 20));
      expect(m.fromCanvas(10, 20), const Offset(10, 20));
    });

    test('yUp flips around height', () {
      final m = CoordinateMapper.yUp(const Size(100, 200));
      expect(m.toCanvas(0, 0), const Offset(0, 200));
      expect(m.toCanvas(50, 50), const Offset(50, 150));
    });

    test('centered places origin at midpoint', () {
      final m = CoordinateMapper.centered(const Size(200, 100), yUp: false);
      expect(m.toCanvas(0, 0), const Offset(100, 50));
    });
  });

  group('DashPattern', () {
    test('value equality', () {
      const a = DashPattern([8, 4]);
      const b = DashPattern([8, 4]);
      expect(a, equals(b));
    });
  });

  group('Widgets render', () {
    testWidgets('GeoCircle paints', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: GeoCircle.fromGeometry(
              circle: Circle(center: Point(50, 50), radius: 30),
              size: Size(100, 100),
            ),
          ),
        ),
      );
      expect(find.byType(GeoCircle), findsOneWidget);
    });

    testWidgets('GeometryCanvas paints mixed shapes', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: GeometryCanvas(
              size: const Size(200, 200),
              shapes: [
                StyledShape(
                  const Circle(center: Point(50, 50), radius: 20),
                  style: const ShapeStyle.filled(Color(0xFF0000FF)),
                ),
                StyledShape(
                  Triangle(
                    const Point(100, 100),
                    const Point(180, 180),
                    const Point(40, 180),
                  ),
                  style: const ShapeStyle.stroked(Color(0xFF000000)),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(GeometryCanvas), findsOneWidget);
    });
  });

  group('shapeToPath', () {
    test('Circle path bounds match radius', () {
      final p = shapeToPath(
        const Circle(center: Point(50, 50), radius: 20),
        CoordinateMapper.identity,
      );
      final b = p.getBounds();
      expect(b.left, closeTo(30, 0.01));
      expect(b.right, closeTo(70, 0.01));
      expect(b.top, closeTo(30, 0.01));
      expect(b.bottom, closeTo(70, 0.01));
    });

    test('Rectangle path closed and matches AABB', () {
      final p = shapeToPath(
        const Rectangle(x: 10, y: 20, width: 100, height: 50),
        CoordinateMapper.identity,
      );
      final b = p.getBounds();
      expect(b.left, 10);
      expect(b.top, 20);
      expect(b.width, 100);
      expect(b.height, 50);
    });

    test('Triangle path bounds match vertices', () {
      final p = shapeToPath(
        Triangle(const Point(0, 0), const Point(100, 0), const Point(50, 80)),
        CoordinateMapper.identity,
      );
      final b = p.getBounds();
      expect(b.left, 0);
      expect(b.right, 100);
      expect(b.top, 0);
      expect(b.bottom, 80);
    });

    test('Polygon path bounds match vertices', () {
      final p = shapeToPath(
        Polygon(const [
          Point(10, 10),
          Point(50, 10),
          Point(50, 40),
          Point(10, 40),
        ]),
        CoordinateMapper.identity,
      );
      final b = p.getBounds();
      expect(b, const Rect.fromLTRB(10, 10, 50, 40));
    });

    test('Ellipse path bounds match radii', () {
      final p = shapeToPath(
        const Ellipse(center: Point(0, 0), radiusX: 30, radiusY: 10),
        CoordinateMapper.identity,
      );
      final b = p.getBounds();
      expect(b.width, closeTo(60, 0.01));
      expect(b.height, closeTo(20, 0.01));
    });

    test('mapper transforms path', () {
      final p = shapeToPath(
        const Circle(center: Point(0, 0), radius: 10),
        CoordinateMapper.centered(const Size(200, 100), yUp: false),
      );
      final b = p.getBounds();
      // origin (0,0) maps to (100, 50); radius 10 → bounds 90..110, 40..60.
      expect(b.left, closeTo(90, 0.01));
      expect(b.top, closeTo(40, 0.01));
    });
  });

  group('ShapeClipper', () {
    test('shouldReclip on shape change', () {
      const a = ShapeClipper(shape: Circle(center: Point(0, 0), radius: 10));
      const b = ShapeClipper(shape: Circle(center: Point(0, 0), radius: 20));
      const same = ShapeClipper(shape: Circle(center: Point(0, 0), radius: 10));
      expect(a.shouldReclip(b), isTrue);
      expect(a.shouldReclip(same), isFalse);
    });

    test('getClip returns shape path', () {
      const c = ShapeClipper(shape: Circle(center: Point(50, 50), radius: 10));
      final p = c.getClip(const Size(100, 100));
      final b = p.getBounds();
      expect(b.center, const Offset(50, 50));
    });
  });

  group('ShapeWidget', () {
    testWidgets('clips child and paints style overlay', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: ShapeWidget(
              shape: Circle(center: Point(50, 50), radius: 50),
              size: Size(100, 100),
              style: ShapeStyle.stroked(Color(0xFFFFFFFF), width: 2),
              child: ColoredBox(color: Color(0xFF00FF00)),
            ),
          ),
        ),
      );
      expect(find.byType(ShapeWidget), findsOneWidget);
      expect(find.byType(ClipPath), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders without child', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: ShapeWidget(
              shape: Circle(center: Point(50, 50), radius: 50),
              size: Size(100, 100),
              style: ShapeStyle.filled(Color(0xFFFF0000)),
            ),
          ),
        ),
      );
      expect(find.byType(ClipPath), findsNothing);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('renders without style overlay', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: ShapeWidget(
              shape: Circle(center: Point(50, 50), radius: 50),
              size: Size(100, 100),
              child: ColoredBox(color: Color(0xFF0000FF)),
            ),
          ),
        ),
      );
      expect(find.byType(ClipPath), findsOneWidget);
    });
  });

  group('Geo* widget interactivity', () {
    testWidgets('GeoCircle.onTap fires only inside shape outline', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: GeoCircle.fromGeometry(
              circle: const Circle(center: Point(50, 50), radius: 20),
              size: const Size(100, 100),
              onTap: () => taps++,
            ),
          ),
        ),
      );
      // inside the radius-20 disc
      await tester.tapAt(const Offset(50, 50));
      expect(taps, 1);
      // inside the 100×100 widget rect but outside the circle
      await tester.tapAt(const Offset(5, 5));
      expect(taps, 1);
    });

    testWidgets('GeoRectangle.onTap respects cornerRadius', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: GeoRectangle.fromGeometry(
              rectangle: const geo.Rectangle(
                x: 0,
                y: 0,
                width: 100,
                height: 100,
              ),
              cornerRadius: const Radius.circular(40),
              size: const Size(100, 100),
              onTap: () => taps++,
            ),
          ),
        ),
      );
      // Center is well inside the rounded rect.
      await tester.tapAt(const Offset(50, 50));
      expect(taps, 1);
      // Top-left widget corner is outside the 40px arc.
      await tester.tapAt(const Offset(2, 2));
      expect(taps, 1);
    });

    testWidgets('GeoCircle.onHoverChanged fires on enter/exit', (tester) async {
      final events = <bool>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: GeoCircle.fromGeometry(
              circle: const Circle(center: Point(50, 50), radius: 20),
              size: const Size(100, 100),
              onHoverChanged: events.add,
            ),
          ),
        ),
      );
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );
      await gesture.addPointer(location: const Offset(0, 0));
      addTearDown(gesture.removePointer);
      await tester.pump();
      // enter the circle interior
      await gesture.moveTo(const Offset(50, 50));
      await tester.pump();
      // exit through a corner of the widget rect (still outside the circle)
      await gesture.moveTo(const Offset(2, 2));
      await tester.pump();
      expect(events, [true, false]);
    });
  });

  group('GeometryCanvas interactivity', () {
    testWidgets('top shape wins tap dispatch', (tester) async {
      var bottomTaps = 0;
      var topTaps = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: GeometryCanvas(
              size: const Size(200, 200),
              shapes: [
                StyledShape(
                  const Circle(center: Point(80, 80), radius: 40),
                  style: const ShapeStyle.filled(Color(0xFF0000FF)),
                  onTap: () => bottomTaps++,
                ),
                StyledShape(
                  const Circle(center: Point(100, 100), radius: 40),
                  style: const ShapeStyle.filled(Color(0xFFFF0000)),
                  onTap: () => topTaps++,
                ),
              ],
            ),
          ),
        ),
      );
      // Overlap region: top wins.
      await tester.tapAt(const Offset(90, 90));
      expect(topTaps, 1);
      expect(bottomTaps, 0);
      // Bottom-only region (inside r=40 around (80,80) but not (100,100)).
      await tester.tapAt(const Offset(60, 60));
      expect(bottomTaps, 1);
      expect(topTaps, 1);
      // Outside both.
      await tester.tapAt(const Offset(5, 5));
      expect(topTaps, 1);
      expect(bottomTaps, 1);
    });
  });
}
