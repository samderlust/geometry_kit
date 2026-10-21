# geometry_kit_3d

Immutable 3D solids for Dart, built on [`geometry_kit`](../geometry_Kit).

Solids know their own volume, surface area and bounds, answer ray and
containment queries, slice into 2D cross-sections, and export triangle meshes
(OBJ, STL, or packed buffers for a GPU). Prisms and solids of revolution are
built straight from geometry_kit 2D shapes. Pure Dart: runs in Flutter, on a
server, or in a CLI.

For rendering in Flutter, see `GeoScene` in
[`geometry_kit_widgets`](../geometry_kit_widgets).

## Conventions

- Right-handed coordinates, **Y up**.
- Angles at the API are **degrees** (matching geometry_kit's `rotate(deg)`).
- Everything is immutable: `translate`, `scale` and `rotate` return new solids.

## Solids

| Solid               | Built from                                         |
| ------------------- | -------------------------------------------------- |
| `Sphere`            | centre, radius                                     |
| `Box`               | centre, width × height × depth, `Quaternion` rotation |
| `Cylinder`          | base centre, axis, radius, height                  |
| `Cone`              | base centre, axis, radius, height                  |
| `Prism`             | a 2D `Polygon` extruded along a `PlaneFrame`       |
| `SolidOfRevolution` | a 2D profile (`List<Point>`) spun around an axis   |

Every solid implements `Solid`:

```dart
abstract interface class Solid {
  double get volume;
  double get surfaceArea;
  Aabb get bounds;
  bool contains(Point3 point);
  Point3 closestPoint(Point3 point);
  double distanceTo(Point3 point);
  RayHit? intersectRay(Ray3 ray);
  Solid translate({double x, double y, double z});
  Solid scale(double factor);
  Solid rotate(Point3 axis, double deg, {Point3 pivot});
  Mesh toMesh({int segments});
}
```

`Cylinder`, `Cone` and `SolidOfRevolution` share one exact implementation
(`RevolvedSolid`): ray hits, containment and closest points are solved from the
2D profile, not from a mesh.

## Examples

### Slice a cone

```dart
final cone = Cone(baseCenter: Point3(0, -1, 0), radius: 1, height: 2);
final plane = Plane.fromPointNormal(
  Point3.zero,
  Point3.unitY.rotate(Point3.unitZ, 30),
);

final label = switch (cone.slice(plane)) {
  CircleSection(:final circle) => 'Circle r=${circle.radius}',
  EllipseSection(:final ellipse) => 'Ellipse ${ellipse.radiusX} × ${ellipse.radiusY}',
  ParabolaSection() => 'Parabola',
  HyperbolaSection() => 'Hyperbola',
  EmptySection() => 'No intersection',
};
```

Sections are geometry_kit 2D shapes in a frame lying in the plane:
`section.toPolygon()` keeps working in 2D, `section.toPoints3()` maps the
outline back to 3D.

### Extrude a floor plan

```dart
final plan = Polygon([
  Point(0, 0), Point(6, 0), Point(6, 3),
  Point(3.5, 3), Point(3.5, 5), Point(0, 5),
]);
final room = Prism.extrude(plan, height: 2.7);

print(plan.area);         // 25.0 m²   (2D API)
print(room.volume);       // 67.5 m³
print(room.lateralArea);  // 59.4 m² of wall
```

With the default `PlaneFrame.ground`, 2D x maps to 3D x and 2D y to 3D −z, so
the plan looks like its drawing when seen from above.

### Revolve a spline

```dart
final profile = Spline([
  Point(0.55, 0), Point(0.85, 0.7), Point(0.32, 1.5), Point(0.5, 1.9),
]);
final vase = SolidOfRevolution(profile.sample(48));
print(vase.volume); // in dm³ = litres when units are decimetres

final mesh = vase.toMesh(segments: 48);
File('vase.stl').writeAsStringSync(mesh.toStl(name: 'vase'));
```

### Pick and collide

```dart
const camera = OrbitCamera(yaw: 30, pitch: 25, distance: 8);
final ray = camera.rayThrough(Point(tapX, tapY), width, height);
final hit = nearestHit(ray, solids);          // RayHit? with distance, point, normal

final drone = Sphere(center: dronePosition, radius: 0.3);
final touching = solids.where(drone.intersects); // exact, after a bounds check
```

`Box.intersectsBox` runs a separating-axis test for two oriented boxes.

### Keep a pose with Transform3

Transforms on a solid are baked into its fields, so a box rotated twice
cannot tell you how far it was turned. Keep the solid in local space and
its placement in a `Transform3` (position, rotation, uniform scale) when you
need the pose itself, for example in an editor:

```dart
final crate = Box.cube(center: Point3.zero, size: 1); // local space
var pose = const Transform3(position: Point3(0, 0.5, 0));

pose = pose.rotated(Point3.unitY, 30).translated(const Point3(1, 0, 0));
final placed = pose.applyTo(crate);        // the solid in world space
final (:axis, :degrees) = pose.rotation.toAxisAngle(); // 30° about +Y

// Drag along the x axis: closest point on the axis to the pointer ray.
final onAxis = ray.closestPointOnLine(pose.position, Point3.unitX);
```

## Math types

`Point3` (also used as a vector), `Quaternion`, `Transform3`, `Ray3`,
`Segment3`, `Plane`, `PlaneFrame`, `Aabb`, `Mesh`, `MeshBuilder`,
`OrbitCamera`.
