import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

void main() {
  // Slice a cone and name the conic.
  final cone = Cone(baseCenter: const Point3(0, -1, 0), radius: 1, height: 2);
  for (final tilt in [0.0, 30.0, 90 - cone.halfAngle, 80.0]) {
    final plane = Plane.fromPointNormal(
      const Point3(0, -0.2, 0),
      Point3.unitY.rotate(Point3.unitZ, tilt),
    );
    final name = switch (cone.slice(plane)) {
      CircleSection() => 'circle',
      EllipseSection() => 'ellipse',
      ParabolaSection() => 'parabola',
      HyperbolaSection() => 'hyperbola',
      EmptySection() => 'nothing',
    };
    print('tilt ${tilt.toStringAsFixed(1)}° → $name');
  }

  // Extrude an L-shaped floor plan.
  final plan = Polygon(const [
    Point(0, 0),
    Point(6, 0),
    Point(6, 3),
    Point(3.5, 3),
    Point(3.5, 5),
    Point(0, 5),
  ]);
  final room = Prism.extrude(plan, height: 2.7);
  print('room: ${room.volume.toStringAsFixed(1)} m³, '
      '${room.lateralArea.toStringAsFixed(1)} m² of wall');

  // Revolve a spline into a vase and export it.
  final vase = SolidOfRevolution(Spline(const [
    Point(0.55, 0),
    Point(0.85, 0.7),
    Point(0.32, 1.5),
    Point(0.5, 1.9),
  ]).sample(48));
  final mesh = vase.toMesh(segments: 48);
  print('vase: ${vase.volume.toStringAsFixed(2)} L, $mesh');

  // Pick the nearest solid along a camera ray.
  const camera = OrbitCamera(yaw: 0, pitch: 0, distance: 10);
  final ray = camera.rayThrough(const Point(200, 150), 400, 300);
  final hit = nearestHit(ray, [
    const Sphere(center: Point3(0, 0, 2), radius: 1),
    Box.cube(center: Point3.zero, size: 1),
  ]);
  print(
      'ray hit ${hit?.solid.runtimeType} at ${hit?.distance.toStringAsFixed(2)}');
}
