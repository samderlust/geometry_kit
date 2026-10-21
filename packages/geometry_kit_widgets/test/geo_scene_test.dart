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

  group('ScenePainter', () {
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

  test('camera ray helper used by GeoScene round-trips', () {
    final s = _camera.project(Point3.zero, 300, 300)!;
    expect(s, const Point(150, 150));
  });
}
