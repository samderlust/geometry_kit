import 'dart:math' as math;
import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _blue = Color(0xFF0000FF);

void main() {
  // 2 wide, 4 tall, 1 deep, so anchor units differ per axis.
  const box = Box(center: Point3.zero, width: 2, height: 4, depth: 1);
  final bounds = box.bounds;

  group('Anchor3', () {
    test('resolves to box points and back', () {
      expect(Anchor3.top.resolve(bounds), const Point3(0, 2, 0));
      expect(Anchor3.topLeftFront.resolve(bounds), const Point3(-1, 2, 0.5));
      expect(
        Anchor3.of(const Point3(1, -2, -0.5), bounds),
        Anchor3.bottomRightBack,
      );
    });

    test('flat axes map to the centre', () {
      final flat = Aabb(const Point3(0, 0, 0), const Point3(1, 0, 1));
      expect(Anchor3.of(const Point3(1, 0, 0), flat).y, 0);
    });
  });

  group('SolidGradient', () {
    test('colorAt spreads colours evenly without stops', () {
      const g = SolidGradient.linear(colors: [_red, _green, _blue]);
      expect(g.colorAt(0), _red);
      expect(g.colorAt(0.5), _green);
      expect(g.colorAt(1), _blue);
      expect(g.colorAt(0.25), isSameColorAs(Color.lerp(_red, _green, 0.5)!));
    });

    test('colorAt honours stops and clamps', () {
      const g = SolidGradient.linear(colors: [_red, _blue], stops: [0.2, 0.6]);
      expect(g.colorAt(-1), _red);
      expect(g.colorAt(0.2), _red);
      expect(g.colorAt(0.4), isSameColorAs(Color.lerp(_red, _blue, 0.5)!));
      expect(g.colorAt(0.9), _blue);
    });

    test('linear runs from start to end in anchor space', () {
      const g = SolidGradient.linear(
        start: Anchor3.top,
        end: Anchor3.bottom,
        colors: [_red, _blue],
      );
      expect(g.t(const Point3(0.7, 2, 0.1), bounds), 0);
      expect(g.t(const Point3(-1, 0, 0), bounds), 0.5);
      expect(g.t(const Point3(0, -2, 0), bounds), 1);
    });

    test('choosing the side is choosing start and end', () {
      const g = SolidGradient.linear(
        start: Anchor3.left,
        end: Anchor3.right,
        colors: [_red, _blue],
      );
      expect(g.colorOf(const Point3(-1, 1, 0), bounds), _red);
      expect(g.colorOf(const Point3(1, 1, 0), bounds), _blue);
      // Reversed swaps which side gets which colour.
      expect(g.reversed.colorOf(const Point3(-1, 1, 0), bounds), _blue);
      expect(g.reversed.colorOf(const Point3(1, 1, 0), bounds), _red);
    });

    test('linear reversed swaps start and end', () {
      const g = LinearSolidGradient(
        start: Anchor3.top,
        end: Anchor3.left,
        colors: [_red, _blue],
      );
      expect(g.reversed.start, Anchor3.left);
      expect(g.reversed.end, Anchor3.top);
      expect(g.reversed.colors, g.colors);
      expect(g.reversed.reversed, g);
    });

    test('radial reversed mirrors colours and stops', () {
      const g = RadialSolidGradient(
        colors: [_red, _green, _blue],
        stops: [0, 0.25, 1],
      );
      final r = g.reversed;
      expect(r.colors, [_blue, _green, _red]);
      expect(r.stops, [0, 0.75, 1]);
      expect(r.reversed, g);
    });

    test('radial measures distance from the centre', () {
      const g = SolidGradient.radial(
        center: Anchor3.center,
        radius: 1,
        colors: [_red, _blue],
      );
      expect(g.t(Point3.zero, bounds), 0);
      expect(g.t(const Point3(0, 2, 0), bounds), 1);
      expect(g.t(const Point3(0.5, 0, 0), bounds), 0.5);
    });

    test('default radial varies across a sphere', () {
      // A centred radial would give every surface point the same colour.
      final mesh = const Sphere(
        center: Point3.zero,
        radius: 0.45,
      ).toMesh(segments: 32);
      const g = SolidGradient.radial(colors: [_red, _blue]);
      final ts = [for (final p in mesh.positions) g.t(p, mesh.bounds)];
      expect(ts.reduce(math.min), lessThan(0.3));
      expect(ts.reduce(math.max), greaterThan(0.95));
      expect(ts.reduce(math.max), lessThanOrEqualTo(1 + 1e-9));
    });

    test('auto radius reaches right across the solid', () {
      const corner = RadialSolidGradient(
        center: Anchor3.topLeftFront,
        colors: [_red, _blue],
      );
      expect(corner.effectiveRadius, closeTo(math.sqrt(3) + 1, 1e-12));
      const top = RadialSolidGradient(
        center: Anchor3.top,
        colors: [_red, _blue],
      );
      expect(top.effectiveRadius, 2);
      expect(top.t(Anchor3.bottom.resolve(bounds), bounds), 1);
      expect(top.t(Anchor3.top.resolve(bounds), bounds), 0);
    });

    test('equal by value', () {
      expect(
        const SolidGradient.linear(colors: [_red, _blue]),
        SolidGradient.linear(colors: [_red, _blue].toList()),
      );
      expect(
        const SolidGradient.linear(colors: [_red, _blue]),
        isNot(const SolidGradient.radial(colors: [_red, _blue])),
      );
    });
  });

  group('SceneMesh.refined', () {
    final cube = SceneMesh(Box.cube(center: Point3.zero, size: 1).toMesh());

    test('splits big faces and keeps the 12 box edges sharp', () {
      final fine = cube.refined();
      expect(fine.mesh.triangleCount, greaterThan(cube.mesh.triangleCount));
      // Every crease segment still lies on one of the cube's edges: two of
      // its coordinates sit on ±0.5.
      final segments = <(int, int)>{for (final c in fine.creases) ...c};
      expect(segments, isNotEmpty);
      for (final (a, b) in segments) {
        final p = fine.mesh.positions[a], q = fine.mesh.positions[b];
        final onFaces = [
          for (var i = 0; i < 3; i++)
            if ((p[i].abs() - 0.5).abs() < 1e-9 &&
                (q[i].abs() - 0.5).abs() < 1e-9)
              i,
        ];
        expect(onFaces.length, greaterThanOrEqualTo(2));
      }
      // Same total surface area.
      expect(fine.mesh.surfaceArea, closeTo(cube.mesh.surfaceArea, 1e-9));
    });

    test('fine meshes are left alone', () {
      final ball = SceneMesh(
        const Sphere(center: Point3.zero, radius: 1).toMesh(segments: 48),
      );
      expect(ball.refined().mesh.triangleCount, ball.mesh.triangleCount);
    });

    test('the cache refines only solids with a gradient', () {
      final cache = SceneMeshCache();
      final plain = cache.meshFor(GeoSolid(box));
      final shaded = cache.meshFor(
        const GeoSolid(
          box,
          gradient: SolidGradient.linear(colors: [_red, _blue]),
        ),
      );
      expect(shaded.mesh.triangleCount, greaterThan(plain.mesh.triangleCount));
      expect(cache.length, 2);
    });
  });

  group('ScenePainter with a gradient', () {
    Future<Color> pixel(
      GeoSolid node,
      Offset at, {
      OrbitCamera camera = const OrbitCamera(yaw: 0, pitch: 0, distance: 8),
    }) async {
      final painter = ScenePainter(
        nodes: [node],
        camera: camera,
        cache: SceneMeshCache(),
        light: const DirectionalLight(
          direction: Point3(0, 0, 1),
          ambient: 0,
          intensity: 1,
        ),
      );
      final recorder = PictureRecorder();
      painter.paint(Canvas(recorder), const Size(200, 200));
      final image = await recorder.endRecording().toImage(200, 200);
      final data = (await image.toByteData())!;
      final i = (at.dy.toInt() * 200 + at.dx.toInt()) * 4;
      return Color.fromARGB(
        data.getUint8(i + 3),
        data.getUint8(i),
        data.getUint8(i + 1),
        data.getUint8(i + 2),
      );
    }

    // Front face of the box faces the camera and the light head-on.
    const node = GeoSolid(
      box,
      gradient: SolidGradient.linear(
        start: Anchor3.top,
        end: Anchor3.bottom,
        colors: [_red, _blue],
      ),
    );

    test('top of the front face is near the start colour', () async {
      final top = await pixel(node, const Offset(100, 60));
      final bottom = await pixel(node, const Offset(100, 140));
      expect(top.r, greaterThan(top.b));
      expect(bottom.b, greaterThan(bottom.r));
    });

    test('the gradient turns with the transform', () async {
      // Upside down: the start colour is now at the bottom of the screen.
      final flipped = GeoSolid(
        box,
        transform: Transform3(
          rotation: Quaternion.fromAxisAngle(Point3.unitZ, 180),
        ),
        gradient: node.gradient,
      );
      final top = await pixel(flipped, const Offset(100, 60));
      final bottom = await pixel(flipped, const Offset(100, 140));
      expect(top.b, greaterThan(top.r));
      expect(bottom.r, greaterThan(bottom.b));
    });
  });
}
