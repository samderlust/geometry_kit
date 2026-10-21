import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit/geometry_kit.dart' show Point;
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

const _camera = OrbitCamera(yaw: 0, pitch: 0, distance: 6);

Widget _app(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  final crate = GeoSolid(
    Box.cube(center: Point3.zero, size: 1),
    style: const ShapeStyle(
      fillColor: Colors.indigo,
      strokeColor: Colors.black,
    ),
    id: 'crate',
  );

  group('SceneMesh', () {
    test('cube has 12 sharp edges, each shared by two triangles', () {
      final sm = SceneMesh(Box.cube(center: Point3.zero, size: 1).toMesh());
      final edges = <(int, int)>{for (final c in sm.creases) ...c};
      expect(edges.length, 12);
    });

    test('smooth sphere has no creases', () {
      final sm = SceneMesh(
        const Sphere(center: Point3.zero, radius: 1).toMesh(segments: 48),
      );
      expect(sm.creases.every((c) => c.isEmpty), isTrue);
    });
  });

  group('SceneMeshCache', () {
    test('equal solids built separately share one mesh', () {
      final cache = SceneMeshCache();
      // A new instance every call, like a solid built inside build().
      GeoSolid fresh() =>
          GeoSolid(Cylinder(baseCenter: Point3.zero, radius: 1, height: 2));
      final first = cache.meshFor(fresh());
      expect(identical(cache.meshFor(fresh()), first), isTrue);
      expect(cache.length, 1);
    });

    test('segment count is part of the key', () {
      final cache = SceneMeshCache();
      const ball = Sphere(center: Point3.zero, radius: 1);
      final coarse = cache.meshFor(const GeoSolid(ball, segments: 8));
      final fine = cache.meshFor(const GeoSolid(ball, segments: 32));
      expect(identical(coarse, fine), isFalse);
      expect(cache.length, 2);
    });

    test('drops the least recently used mesh beyond capacity', () {
      final cache = SceneMeshCache(capacity: 2);
      GeoSolid ball(double r) =>
          GeoSolid(Sphere(center: Point3.zero, radius: r), segments: 8);
      final a = cache.meshFor(ball(1));
      cache.meshFor(ball(2));
      expect(identical(cache.meshFor(ball(1)), a), isTrue); // a is now newest
      cache.meshFor(ball(3)); // evicts radius 2, not a
      expect(cache.length, 2);
      expect(identical(cache.meshFor(ball(1)), a), isTrue);
    });
  });

  group('GeoSolid.transform', () {
    final t = Transform3(
      position: const Point3(0.4, 0.2, -0.3),
      rotation: Quaternion.fromAxisAngle(const Point3(1, 1, 0), 35),
      scale: 1.3,
    );
    const box = Box(center: Point3.zero, width: 1, height: 0.6, depth: 0.8);

    int drawn(GeoSolid node, SceneMeshCache cache) {
      final painter = ScenePainter(
        nodes: [node],
        camera: const OrbitCamera(yaw: 20, pitch: 25, distance: 6),
        cache: cache,
      );
      final recorder = PictureRecorder();
      painter.paint(Canvas(recorder), const Size(300, 300));
      recorder.endRecording();
      return painter.lastTriangleCount;
    }

    test('paints like the solid baked by the same transform', () {
      expect(
        drawn(GeoSolid(box, transform: t), SceneMeshCache()),
        drawn(GeoSolid(t.applyTo(box)), SceneMeshCache()),
      );
    });

    test('moving the transform reuses one cached mesh', () {
      final cache = SceneMeshCache();
      for (var i = 0; i < 50; i++) {
        drawn(
          GeoSolid(box, transform: t.translated(Point3(i * 0.01, 0, 0))),
          cache,
        );
      }
      expect(cache.length, 1);
    });

    test('picking uses the placed solid', () {
      final viewport = SceneViewport(_camera, const Size(300, 300));
      final moved = GeoSolid(
        Box.cube(center: Point3.zero, size: 1),
        transform: const Transform3(position: Point3(1.5, 0, 0)),
        id: 'moved',
      );
      final at = viewport.project(const Point3(1.5, 0, 0))!;
      expect(viewport.pick([moved], at)?.node.id, 'moved');
      expect(viewport.pick([moved], const Offset(150, 150)), isNull);
    });
  });

  group('ScenePainter', () {
    test('clips faces crossing the near plane instead of dropping them', () {
      // A huge floor slab under the camera: its top face reaches behind the
      // camera, and every other face is culled.
      final floor = GeoSolid(
        Box(
          center: const Point3(0, -1, 0),
          width: 100,
          height: 0.1,
          depth: 100,
        ),
      );
      final painter = ScenePainter(
        nodes: [floor],
        camera: const OrbitCamera(yaw: 0, pitch: 20, distance: 3),
        cache: SceneMeshCache(),
      );
      final recorder = PictureRecorder();
      painter.paint(Canvas(recorder), const Size(300, 300));
      recorder.endRecording();
      expect(painter.lastTriangleCount, 2);
    });

    test('paths that run behind the camera still draw', () {
      final painter = ScenePainter(
        nodes: GeoPath3.grid(extent: 50, step: 5),
        camera: const OrbitCamera(yaw: 0, pitch: 20, distance: 3),
        cache: SceneMeshCache(),
      );
      final recorder = PictureRecorder();
      painter.paint(Canvas(recorder), const Size(300, 300));
      expect(recorder.endRecording, returnsNormally);
    });

    test('culls back faces of opaque solids', () {
      final painter = ScenePainter(
        nodes: [crate],
        camera: _camera,
        cache: SceneMeshCache(),
      );
      final recorder = PictureRecorder();
      painter.paint(Canvas(recorder), const Size(300, 300));
      recorder.endRecording();
      // Looking straight at one face: only its 2 triangles survive.
      expect(painter.lastTriangleCount, 2);
    });

    test('translucent solids keep their back faces', () {
      final painter = ScenePainter(
        nodes: [
          GeoSolid(
            crate.solid,
            style: const ShapeStyle(fillColor: Colors.indigo, opacity: 0.5),
          ),
        ],
        camera: _camera,
        cache: SceneMeshCache(),
      );
      final recorder = PictureRecorder();
      painter.paint(Canvas(recorder), const Size(300, 300));
      recorder.endRecording();
      expect(painter.lastTriangleCount, greaterThan(2));
    });
  });

  group('GeoScene', () {
    testWidgets('renders solids, paths and labels', (tester) async {
      await tester.pumpWidget(
        _app(
          GeoScene(
            size: const Size(300, 200),
            camera: _camera,
            children: [
              ...GeoPath3.grid(extent: 2),
              crate,
              const GeoLabel3(Point3(0, 1, 0), 'crate'),
            ],
          ),
        ),
      );
      expect(find.byType(GeoScene), findsOneWidget);
      expect(tester.getSize(find.byType(GeoScene)), const Size(300, 200));
    });

    testWidgets('tap picks the solid under the pointer', (tester) async {
      SceneHit? tapped;
      var calls = 0;
      await tester.pumpWidget(
        _app(
          GeoScene(
            size: const Size(300, 300),
            camera: _camera,
            onTap: (h) {
              tapped = h;
              calls++;
            },
            children: [crate],
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(GeoScene));
      await tester.tapAt(origin + const Offset(150, 150));
      expect(tapped?.node.id, 'crate');
      expect(tapped!.hit.normal.z, closeTo(1, 1e-9));
      await tester.tapAt(origin + const Offset(5, 5));
      expect(calls, 2);
      expect(tapped, isNull);
    });

    testWidgets('dragging empty space orbits the camera', (tester) async {
      OrbitCamera? cam;
      await tester.pumpWidget(
        _app(
          GeoScene(
            size: const Size(300, 300),
            camera: _camera,
            onCameraChanged: (c) => cam = c,
            children: [crate],
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(GeoScene));
      await tester.dragFrom(
        origin + const Offset(20, 20),
        const Offset(100, 0),
      );
      expect(cam, isNotNull);
      expect(cam!.yaw, isNot(_camera.yaw));
    });

    testWidgets('onDragSolid moves the grabbed solid instead of orbiting', (
      tester,
    ) async {
      var moved = Point3.zero;
      OrbitCamera? cam;
      await tester.pumpWidget(
        _app(
          GeoScene(
            size: const Size(300, 300),
            camera: const OrbitCamera(yaw: 0, pitch: 40, distance: 6),
            onCameraChanged: (c) => cam = c,
            onDragSolid: (node, delta) => moved += delta,
            children: [crate],
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(GeoScene));
      await tester.dragFrom(
        origin + const Offset(150, 150),
        const Offset(60, 0),
      );
      expect(cam, isNull);
      expect(moved.x, greaterThan(0));
      expect(moved.y, closeTo(0, 1e-9));
    });
  });

  group('SceneViewport', () {
    final viewport = SceneViewport(_camera, const Size(300, 300));

    test('project and rayAt agree', () {
      expect(viewport.project(Point3.zero), const Offset(150, 150));
      final ray = viewport.rayAt(const Offset(150, 150));
      expect(ray.direction.isCloseTo(const Point3(0, 0, -1)), isTrue);
    });

    test('pickHandle is screen-space and the last drawn wins', () {
      const a = GeoHandle(Point3.zero, id: 'a');
      const b = GeoHandle(Point3.zero, id: 'b');
      expect(viewport.pickHandle([a, b], const Offset(155, 150))?.id, 'b');
      expect(viewport.pickHandle([a], const Offset(170, 150)), isNull);
      expect(
        viewport.pickHandle([a], const Offset(170, 150), slop: 20)?.id,
        'a',
      );
    });

    test('dragPlane falls back to facing the camera when edge-on', () {
      // Pitch 0: the ground plane is seen exactly edge-on.
      expect(
        viewport.dragPlane(Point3.zero).normal.isCloseTo(Point3.unitZ),
        isTrue,
      );
      final above = SceneViewport(
        const OrbitCamera(yaw: 0, pitch: 40, distance: 6),
        const Size(300, 300),
      );
      expect(above.dragPlane(Point3.zero).normal, Point3.unitY);
    });
  });

  group('GeoScene interaction', () {
    Future<Offset> pump(
      WidgetTester tester,
      SceneInteraction interaction, {
      ValueChanged<OrbitCamera>? onCameraChanged,
      ValueChanged<SceneHit?>? onTap,
    }) async {
      await tester.pumpWidget(
        _app(
          GeoScene(
            size: const Size(300, 300),
            camera: _camera,
            interaction: interaction,
            onCameraChanged: onCameraChanged,
            onTap: onTap,
            children: [
              crate,
              const GeoHandle(Point3(1.5, 0, 0), id: 'h'),
            ],
          ),
        ),
      );
      return tester.getTopLeft(find.byType(GeoScene));
    }

    testWidgets('a claimed gesture gets every move and does not orbit', (
      tester,
    ) async {
      final log = _Recorder(claim: (e) => e.pick() != null);
      OrbitCamera? cam;
      SceneHit? tapped;
      final origin = await pump(
        tester,
        log,
        onCameraChanged: (c) => cam = c,
        onTap: (h) => tapped = h,
      );
      await tester.dragFrom(
        origin + const Offset(150, 150),
        const Offset(80, 0),
      );
      expect(log.events.first, 'down');
      expect(log.events.last, 'up');
      expect(log.events.where((e) => e == 'move'), isNotEmpty);
      expect(cam, isNull);
      await tester.tapAt(origin + const Offset(150, 150));
      expect(tapped, isNull, reason: 'claimed taps skip onTap');
    });

    testWidgets('declined gestures orbit and are not followed', (tester) async {
      final log = _Recorder(claim: (e) => false);
      OrbitCamera? cam;
      final origin = await pump(tester, log, onCameraChanged: (c) => cam = c);
      await tester.dragFrom(origin + const Offset(20, 20), const Offset(80, 0));
      expect(log.events, ['down']);
      expect(cam, isNotNull);
    });

    testWidgets('the pointer event can pick handles', (tester) async {
      String? grabbed;
      final log = _Recorder(
        claim: (e) {
          grabbed = e.pickHandle()?.id;
          return grabbed != null;
        },
      );
      final origin = await pump(tester, log);
      final at = SceneViewport(
        _camera,
        const Size(300, 300),
      ).project(const Point3(1.5, 0, 0))!;
      await tester.tapAt(origin + at);
      expect(grabbed, 'h');
    });

    testWidgets('a second finger cancels the claim', (tester) async {
      final log = _Recorder(claim: (e) => true);
      final origin = await pump(tester, log);
      final g1 = await tester.startGesture(origin + const Offset(150, 150));
      final g2 = await tester.startGesture(origin + const Offset(200, 150));
      await g1.moveBy(const Offset(10, 0));
      await g1.up();
      await g2.up();
      expect(log.events, ['down', 'cancel']);
    });

    testWidgets('a claimed drag does not scroll an enclosing list', (
      tester,
    ) async {
      final log = _Recorder(claim: (e) => e.pick() != null);
      final scroll = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: scroll,
              children: [
                GeoScene(
                  size: const Size(300, 300),
                  camera: _camera,
                  interaction: log,
                  children: [crate],
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(GeoScene));
      await tester.dragFrom(
        origin + const Offset(150, 150),
        const Offset(0, -120),
      );
      expect(scroll.offset, 0);
      expect(log.events.last, 'up');

      // Empty space is not claimed, so the list scrolls as usual.
      await tester.dragFrom(
        origin + const Offset(10, 10),
        const Offset(0, -120),
      );
      expect(log.events.last, 'down');
    });

    testWidgets('removing the interaction mid-gesture cancels it and '
        'orbit works again', (tester) async {
      final log = _Recorder(claim: (e) => true);
      OrbitCamera? cam;
      Widget scene({SceneInteraction? interaction}) => _app(
        GeoScene(
          size: const Size(300, 300),
          camera: _camera,
          interaction: interaction,
          onCameraChanged: (c) => cam = c,
          children: [crate],
        ),
      );
      await tester.pumpWidget(scene(interaction: log));
      final origin = tester.getTopLeft(find.byType(GeoScene));
      final g = await tester.startGesture(origin + const Offset(150, 150));
      await g.moveBy(const Offset(10, 0));
      await tester.pumpWidget(scene());
      await g.moveBy(const Offset(10, 0));
      await g.up();
      expect(log.events, ['down', 'move', 'cancel']);

      await tester.dragFrom(origin + const Offset(20, 20), const Offset(80, 0));
      expect(cam, isNotNull, reason: 'orbit must not stay blocked');
    });

    testWidgets('swapping the interaction mid-gesture does not leak events '
        'to the new one', (tester) async {
      final first = _Recorder(claim: (e) => true);
      final second = _Recorder(claim: (e) => true);
      Widget scene(SceneInteraction i) => _app(
        GeoScene(
          size: const Size(300, 300),
          camera: _camera,
          interaction: i,
          children: [crate],
        ),
      );
      await tester.pumpWidget(scene(first));
      final origin = tester.getTopLeft(find.byType(GeoScene));
      final g = await tester.startGesture(origin + const Offset(150, 150));
      await tester.pumpWidget(scene(second));
      await g.moveBy(const Offset(10, 0));
      await g.up();
      expect(first.events, ['down', 'cancel']);
      expect(second.events, isEmpty);
    });

    testWidgets('onDragSolid still drags when the floor is edge-on', (
      tester,
    ) async {
      var moved = Point3.zero;
      await tester.pumpWidget(
        _app(
          GeoScene(
            size: const Size(300, 300),
            camera: _camera, // pitch 0
            onDragSolid: (node, delta) => moved += delta,
            children: [crate],
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(GeoScene));
      await tester.dragFrom(
        origin + const Offset(150, 150),
        const Offset(0, -40),
      );
      expect(moved.y, greaterThan(0));
      expect(moved.magnitude, lessThan(2));
    });

    testWidgets('handles render on top', (tester) async {
      await tester.pumpWidget(
        _app(
          GeoScene(
            size: const Size(300, 300),
            camera: _camera,
            children: [
              crate,
              const GeoHandle(Point3.zero, id: 'c', shape: HandleShape.square),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  test('camera ray helper used by GeoScene round-trips', () {
    final s = _camera.project(Point3.zero, 300, 300)!;
    expect(s, const Point(150, 150));
  });
}

class _Recorder extends SceneInteraction {
  _Recorder({required this.claim});

  final bool Function(ScenePointer e) claim;
  final events = <String>[];

  @override
  bool onPointerDown(ScenePointer e) {
    events.add('down');
    return claim(e);
  }

  @override
  void onPointerMove(ScenePointer e) => events.add('move');

  @override
  void onPointerUp(ScenePointer e) => events.add('up');

  @override
  void onPointerCancel() => events.add('cancel');
}
