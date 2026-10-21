## 0.1.0

Initial release.

### Math

- `Point3`, `Quaternion`, `Ray3`, `Segment3`, `Plane`, `PlaneFrame`, `Aabb`.
- `Transform3`: position, rotation and uniform scale, with `apply`,
  `inverse`, composition and `applyTo(Solid)`.
- `Quaternion.toAxisAngle()`; `Ray3.closestPointOnLine` for axis dragging.

### Solids

- `Solid` interface: `volume`, `surfaceArea`, `bounds`, `contains`,
  `closestPoint`, `distanceTo`, `intersectRay`, transforms, `toMesh`.
- `Sphere`, `Box` (oriented by a `Quaternion`), `Cylinder`, `Cone`.
- `RevolvedSolid` base: exact ray, containment and closest-point queries from
  a 2D profile.
- `Sphere.intersects` (exact against every solid), `Box.intersectsBox`
  (separating axis test), `nearestHit` for picking.

### Bridges from 2D

- `Prism.extrude(Polygon, height:)` — concave plans supported.
- `SolidOfRevolution(List<Point>)` — lathe a profile such as a sampled `Spline`.
- `Cone.slice` / `Sphere.slice` → sealed `CrossSection` (`CircleSection`,
  `EllipseSection`, `ParabolaSection`, `HyperbolaSection`, `EmptySection`)
  with geometry_kit `Circle` / `Ellipse` / `Polygon` results.

### Meshes and camera

- `Mesh` with volume, surface area, merge, transforms, packed GPU buffers,
  `toObj()` and `toStl()`; `MeshBuilder`.
- `OrbitCamera` with `project` and `rayThrough` for screen ↔ world;
  `view()` returns a `CameraView` that computes the camera axes once for
  bulk projection; `zoom` / `withDistance` clamp to `minDistance`…`maxDistance`.
