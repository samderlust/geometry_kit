## 0.4.0

Curve widgets, drag, grid and debug overlays (roadmap phases 2 and 3).

### Breaking

- `StyledShape.shape`, `ShapeWidget.shape` and `ShapeClipper.shape` are now
  typed `Geometry` (new in `geometry_kit` 1.3.0) instead of `Shape`: the
  curve types (`Arc`, `Ring`, `Ray`, the Beziers, `Spline`, `Polyline`, and
  `Line`) are geometry but not shapes. Passing a `Shape` still works; code
  that read `.shape` as a `Shape` (e.g. `.shape.area`) needs a type check.
  `shapeToPath` takes a `Geometry` too.
- Requires `geometry_kit` 1.3.0.

### Curve widgets

- `GeoArc` (open arc, or the pie slice with `sector: true`), `GeoRing`
  (hole stays empty), `GeoCapsule`, `GeoBezierCurve` (`.quadratic`,
  `.cubic`, `.fromGeometry`), `GeoSpline`, `GeoPolyline`, `GeoRay` (cut at
  the widget edge).
- `ArcSector` wraps an `Arc` to paint or hit-test the closed slice, e.g. in
  a `GeometryCanvas`. It is a `Geometry`, with `translate`.
- `shapeToPath` builds paths for all of them; it takes an optional `size`
  to cut a `Ray`.
- `GeometryCanvas` paints every supported type, `Line` included (it used to
  skip lines). Open curves are stroked only, falling back to `fillColor`
  like `GeoLine`.

### Interaction

- Open curves hit-test by distance: within half the stroke width plus 4px.
  `GeoLine` now takes `onTap` / `onHoverChanged`.
- Drag on every `Geo*` widget and on `StyledShape`: `onDragStart`,
  `onDragUpdate`, `onDragEnd`. Only drags that start on the shape move it.
  The shape is drawn displaced while dragging; `onDragEnd` reports the
  total in geometry space for the owner to commit. `GeometryCanvas` drags
  the topmost draggable shape.
- `CoordinateMapper.vectorFromCanvas` maps a canvas delta to geometry
  space.
- Pointers that miss the shape now pass through: `Geo*` widgets and
  `GeometryCanvas` filter at hit-test time, so a widget stacked on top no
  longer swallows taps meant for a shape below it, and the area around a
  shape scrolls an enclosing list. (Previously the whole widget rect was
  opaque.)
- A drag that starts on a shape wins over an enclosing scroll view, and the
  shape tracks the finger from touch-down.

### Authoring aids

- `GeometryCanvas.grid` (`GeoGrid`): grid lines at multiples of `spacing`
  in geometry space, optional major lines, and the axes.
- `GeoDebugOverlay` on every `Geo*` widget, `StyledShape` and
  `GeometryCanvas`: tight bounding box, center crosshair, vertices (Bezier
  control points with handles), dimension labels.

### Performance

- Paths are memoised per geometry instance (and mapper / size), so hover
  hit-testing no longer rebuilds a polygon or spline path on every pointer
  move.

## 0.3.0

Adds 3D scenes for `geometry_kit_3d` solids on top of 0.2.0.

> Note: 0.2.0 was published from sources that had not reached the
> repository; they are restored here, so everything listed under 0.2.0 is
> still included.

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
  finger cancels the claim. `onDragSolid` is built on it and drags on a
  camera-facing plane at low pitch instead of flinging the solid.
- `GeoSolid.transform` (`Transform3`): the mesh is cached for the local
  solid and placed at paint time, so moving a solid does not
  re-triangulate it or flood the mesh cache. `GeoSolid.worldSolid` gives the
  placed solid for exact queries; picking uses it.
- Inside a scroll view, drags that start on a `GeoScene` orbit the camera
  instead of scrolling the page (vertical drags used to scroll). With
  `enableOrbit: false` the page scrolls as before.
- `GeoHandle` scene node: a fixed-size dot or square at a 3D point, drawn
  on top and picked on screen.

### Solid gradients

- `GeoSolid.gradient` takes a `SolidGradient`, used in place of
  `ShapeStyle.fillColor`. It is laid across the solid's local bounding box,
  so it moves, turns and scales with `GeoSolid.transform`.
  `ShapeStyle.opacity` and edge outlines still apply.
- `Anchor3` names a point in that box, -1 to 1 per axis (x left→right,
  y bottom→top, z back→front), with constants such as `Anchor3.top`,
  `.left`, `.front` and `.topLeftFront`. `Anchor3.resolve` and
  `Anchor3.of` convert to and from local points.
- `SolidGradient.linear(start:, end:)` runs from one anchor to another
  (top to bottom by default), so the anchors pick the side it starts from.
  `SolidGradient.radial(center:, radius:)` runs outward from a point: the
  top by default, with `radius` reaching right across the solid when left
  out (`RadialSolidGradient.effectiveRadius`). Both take `colors` and
  optional `stops`; `reversed` runs either the other way.
- Colours are worked out per vertex and shaded per face. Gradients that
  bend within a face (radial, three or more colours, or ends inside the
  box; see `SolidGradient.needsRefinement`) draw on `SceneMesh.refined`,
  which splits big faces at most twice while keeping normals and sharp
  edges. A two-colour linear gradient across the box is exact as is and
  adds no triangles.
- `SceneMesh.vertexColors` keeps the last gradient's colours, so orbiting
  or dragging a solid does not recompute them.

### Fixes

- Fill and stroke colours with their own alpha are no longer forced opaque:
  the colour's alpha is now multiplied by `ShapeStyle.opacity` instead of
  replaced by it.

## 0.2.0

Bundles three internal milestones (decorative styling, theme merge +
animation, widget clipping) into one published release on top of 0.1.1.

### Breaking

- `ShapeStyle.strokeWidth`, `opacity`, `strokeCap`, `strokeJoin` are now
  nullable (`double?` / `StrokeCap?` / `StrokeJoin?`). Constructor defaults
  are unchanged (`1.0` / `1.0` / `StrokeCap.butt` / `StrokeJoin.miter`), so
  most call sites compile unmodified. Code that reads these fields
  unconditionally (e.g. `style.strokeWidth.toString()`) must adopt
  `style.strokeWidth ?? 1.0` for the equivalent fallback. Painters inside
  the package already do this.
- `ShapeStyleTheme.resolve(context, fallback)` is now
  `resolve(context, explicit, {fallback})`. When `explicit` is non-null the
  resolver returns `explicit.merge(ambient)` — fields the override leaves
  `null` fall back to the ambient theme rather than fully replacing it. When
  `explicit` is `null`, the ambient theme (or the optional `fallback`) is
  returned, matching the previous behaviour. All built-in `Geo*` widgets
  switched from `style ?? ShapeStyleTheme.resolve(context, const ShapeStyle())`
  to `ShapeStyleTheme.resolve(context, style)`.

### Added

- **Decorative styling**
  - `ShapeStyle.fillGradient` and `ShapeStyle.strokeGradient` — accept any
    Flutter `Gradient` (linear, radial, sweep). Gradients win over solid
    colors when both are set on the same channel. Resolved against the
    painted shape's axis-aligned bounding rect at paint time.
  - `ShapeStyle.gradientFilled(Gradient)` convenience constructor.
  - `PaintBuilder` typedef + `ShapeStyle.fillPaintBuilder` /
    `ShapeStyle.strokePaintBuilder` — escape hatch for advanced Skia
    features (`MaskFilter`, `ImageFilter`, `BlendMode`, custom shaders)
    without expanding the primary style surface.
- **Theme merge + animation**
  - `ShapeStyle.merge(ShapeStyle? base)` — field-level fallback. Used by
    `ShapeStyleTheme.resolve` so a child override and an ambient theme
    combine per-field instead of all-or-nothing.
  - `ShapeStyle.lerp(a, b, t)` static method. Smoothly interpolates colors
    and the `strokeWidth` / `opacity` scalars; gradients, dash patterns,
    enum fields, and `PaintBuilder`s snap at `t >= 0.5`.
  - `ShapeStyleTween` — `Tween<ShapeStyle?>` driving `ShapeStyle.lerp`.
  - `AnimatedShapeStyle` widget — sibling of `AnimatedDefaultTextStyle`.
    Animates a `ShapeStyle` over a `Duration` and supplies the interpolated
    value to descendants through `ShapeStyleTheme`.
- **Widget clipping**
  - `shapeToPath(Shape, CoordinateMapper)` — top-level helper that returns
    the canvas-space `Path` for any supported `geometry_kit` shape
    (`Circle`, `Ellipse`, `Rectangle`, `Triangle`, `Quadrilateral`,
    `Polygon`, `Line`). Uses the same path bodies the painters render;
    throws `UnsupportedError` for unhandled shape types.
  - `ShapeClipper` — `CustomClipper<Path>` wrapping a shape for direct use
    with Flutter's `ClipPath`. Accepts any `geometry_kit` `Shape` plus a
    `CoordinateMapper` (defaults to `identity`).
  - `ShapeWidget` — host widget that composes a shape outline, an optional
    clipped child, and an optional `ShapeStyle` overlay. Stroke draws above
    the clipped child so clip-edge anti-aliasing does not eat the outline.
- **Tap + hover interactivity**
  - `GeoCircle`, `GeoEllipse`, `GeoRectangle`, `GeoTriangle`,
    `GeoQuadrilateral`, `GeoPolygon` gain optional `onTap` and
    `onHoverChanged` parameters. Hit-test is shape-precise via
    `shapeToPath(...).contains(localPosition)` — pointer events outside
    the shape outline are ignored even when they land in the host widget
    rect.
  - `StyledShape` gains matching `onTap` / `onHoverChanged`. `GeometryCanvas`
    walks shapes top-down on each pointer event and dispatches to the
    first hit; the topmost (last-painted) shape wins both tap and hover.
  - Hover supports both mouse pointers (via `MouseRegion`) and
    stylus/touch hover (via `Listener.onPointerHover`). `GeoLine` does
    not expose interaction in v1 (zero-area path makes shape-precise
    hit-test degenerate; reach for a `Geo*` filled shape or
    `GestureDetector` if line interaction is needed).
- **Examples**
  - Solar system demo upgraded with radial-gradient sun, gradient-shaded
    planets (sun-tracking day/night highlight), pulsing halo via
    `MaskFilter.blur`, and live sliders for orbit speed and planet scale.
  - Clipping demo gains a "ShapeWidget" section (gradient circle, text in
    triangle, pentagon over grid) plus an interactive image-clip
    playground (vertex-count + rotation sliders, source picker for network
    photo / Flutter logo / gradient).

### Changed

- `ShapeStyle.opacity` now applies only to solid colors — encode alpha into
  gradient color stops directly.
- Painters refactored to share path construction via the new `shapeToPath`
  helper. Behaviour identical; rectangle's `cornerRadius` branch stays in
  `RectanglePainter` since corner radius is a widget-level concept, not a
  field on `geo.Rectangle`. `LinePainter` retains its own path build.

### Notes

- `GeoLine` does not support `strokeGradient` (zero-area bounds make shader
  resolution degenerate). Asserted in debug, ignored in release. `GeoLine`
  does support `strokePaintBuilder` for blur / mask effects.
- `PaintBuilder` equality is by function identity. Use top-level or
  `static` builders when value-equality matters for `shouldRepaint`.
- Field-level theme merging only kicks in when an override explicitly sets
  fields to `null` (the constructor's non-null defaults otherwise win).
  Use the raw constructor — not `copyWith` — to write `null` into a field,
  since `copyWith` cannot transition a value to null.
- `ShapeWidget` does not auto-fit a shape to widget bounds. Geometry
  coordinates must already match the rendered widget space, or be
  transformed via `mapper`. Sizing happens through the optional `size`
  parameter or the parent's bounded constraints.
- Clipping a `Line` is degenerate (zero-area path); `ShapeClipper`
  documents the case rather than asserting.
- Hit-test arena: `Geo*` widgets and `GeometryCanvas` use opaque
  `GestureDetector`s. Taps inside the host widget rect but outside the
  shape outline are still consumed (no callback fires) — siblings under
  the widget rect won't see those taps. Set the widget's size tightly
  to the shape if pass-through is needed.

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
