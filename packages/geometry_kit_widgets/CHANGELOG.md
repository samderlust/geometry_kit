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
