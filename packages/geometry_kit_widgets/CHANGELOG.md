## 0.2.0

### 3D scenes

- `GeoScene` — renders `geometry_kit_3d` solids on a Flutter canvas with an
  `OrbitCamera`, flat shading from a `DirectionalLight`, back-face culling and
  painter's-algorithm depth sorting. Drag to orbit, pinch/scroll to zoom.
- `GeoSolid`, `GeoPath3` (with `GeoPath3.grid`), `GeoLabel3` scene nodes.
- Picking: `onTap` / `onHover` return a `SceneHit`; `onDragSolid` moves a
  grabbed solid on the horizontal plane.
- `ScenePainter`, `SceneMeshCache`, `SceneMesh` exposed for custom painting.
  The mesh cache is keyed by solid value (LRU, 256 entries), so solids
  rebuilt in `build()` are not re-triangulated.
- Faces and paths crossing the camera's near plane are clipped, not
  dropped; pinch zoom stops at `OrbitCamera.minDistance`.
- `SceneViewport` (camera + size): `rayAt`, `project`, `pick`,
  `pickHandle`, `onPlane`, and `dragPlane`, which falls back to a
  camera-facing plane when the requested one is seen edge-on.
- `GeoScene.interaction`: a `SceneInteraction` gets raw pointer events
  before the camera and can claim a gesture; a claimed gesture wins the
  arena, so neither the camera nor an enclosing scroll view reacts. A second
  finger cancels the claim. `onDragSolid` is
  built on it and now drags on a camera-facing plane at low pitch instead of
  flinging the solid.
- `GeoSolid.transform` (`Transform3`): the mesh is cached for the local
  solid and placed at paint time, so moving a solid does not
  re-triangulate it or flood the mesh cache. `GeoSolid.worldSolid` gives the
  placed solid for exact queries; picking uses it.
- `GeoHandle` scene node: a fixed-size dot or square at a 3D point, drawn
  on top and picked on screen.

### Fixes

- Fill and stroke colours with their own alpha are no longer forced opaque:
  the colour's alpha is now multiplied by `ShapeStyle.opacity` instead of
  replaced by it.

## 0.1.1

- update git info

## 0.1.0

Initial release. Phase 1 of the widget library.

### Widgets

- `GeoCircle`, `GeoEllipse`, `GeoRectangle`, `GeoTriangle`, `GeoQuadrilateral`,
  `GeoPolygon`, `GeoLine` — declarative `CustomPainter`-backed widgets, each
  with flat and `.fromGeometry` constructors.
- `GeometryCanvas` + `StyledShape` — multi-shape rendering on a single canvas
  with type-switch dispatch.

### Styling

- `ShapeStyle` — fill, stroke, opacity, dash pattern, cap, join (value
  equality, `copyWith`).
- `ShapeStyle.filled` / `ShapeStyle.stroked` convenience constructors.
- `ShapeStyleTheme` — `InheritedWidget` for default style inheritance via
  `ShapeStyle.of(context)` / `ShapeStyleTheme.resolve`.
- `DashPattern` — shared `PathMetrics`-based dash drawing across all painters.
- Color opacity uses `withValues(alpha:)` (Flutter 3.27+).

### Coordinates

- `CoordinateMapper` — `identity` (default, Y-down), `yUp(size)`,
  `centered(size, {yUp})`.
- Locked into v0.1 so painter signatures stay stable.

### Composition

- Every widget exposes `clipBehavior` (default `Clip.hardEdge`) — shapes
  never bleed past widget bounds unless explicitly opted in with `Clip.none`.
- `GeometryCanvas.backgroundColor` defaults to `null` — transparent canvas
  layers cleanly over other widgets.
- Internal `GeoShapeContainer` keeps `ClipRect` + `RepaintBoundary` +
  `Semantics` consistent across every widget.

### Other

- Dartdoc on every public class, constructor, and parameter.
- `Semantics(label: ...)` on every widget for accessibility.
- `RepaintBoundary` wraps every `CustomPaint`.
- Eight passing widget + unit tests.
