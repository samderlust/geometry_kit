# Geometry Kit Widgets — Flutter Widget Library Plan

A roadmap for `geometry_kit_widgets`, a companion Flutter package that wraps `geometry_kit` shapes into declarative, customizable, interactive Flutter widgets backed by `CustomPainter`.

> **Status (v0.4.0):** Phases 1–3 shipped. Phase 4 (polish) is next. Sections
> below describe the API as built; notes marked *Shipped as* record where the
> implementation departed from the original sketch.

---

## 1. Goals & Non-Goals

### Goals

- Provide a declarative Flutter-idiomatic widget for every major shape in `geometry_kit`.
- Let users drop shapes into any Flutter layout without touching `Canvas` or `CustomPainter` directly.
- Support styling (fill, stroke, dash, opacity) through a shared `ShapeStyle` system.
- Enable hit testing and interactivity (tap, hover, drag) using the geometry classes' own `contains()` logic.
- Ship a flagship `GeometryCanvas` widget for multi-shape scenes.

### Non-Goals

- Animation engine or tweening (users compose with Flutter's existing animation system).
- ~~3D rendering~~ — *Shipped as* `GeoScene` in this package (v0.3.0) rather than a separate `geometry_kit_3d_widgets`; out of scope for this plan.
- SVG export or rasterization.
- Replacing general-purpose drawing packages like `flutter_svg` or `flame`.

---

## 2. Package Structure

### 2.1 New sibling package: `geometry_kit_widgets`

```
geometry_kit_widgets/
├── lib/
│   ├── geometry_kit_widgets.dart          # barrel export
│   ├── src/
│   │   ├── style/
│   │   │   ├── shape_style.dart
│   │   │   ├── shape_style_theme.dart      # InheritedWidget for defaults
│   │   │   └── dash_pattern.dart
│   │   ├── coord/
│   │   │   └── coordinate_mapper.dart      # Y-up/Y-down + origin offset
│   │   ├── util/
│   │   │   └── dashed_path.dart            # shared PathMetrics dashing
│   │   ├── painters/
│   │   │   ├── circle_painter.dart
│   │   │   ├── ellipse_painter.dart
│   │   │   ├── rectangle_painter.dart
│   │   │   ├── triangle_painter.dart
│   │   │   ├── quadrilateral_painter.dart
│   │   │   ├── polygon_painter.dart
│   │   │   ├── line_painter.dart
│   │   │   ├── ray_painter.dart
│   │   │   ├── arc_painter.dart
│   │   │   ├── ring_painter.dart
│   │   │   ├── capsule_painter.dart
│   │   │   ├── bezier_painter.dart
│   │   │   ├── spline_painter.dart
│   │   │   └── polyline_painter.dart
│   │   ├── widgets/
│   │   │   ├── geo_circle.dart
│   │   │   ├── geo_ellipse.dart
│   │   │   ├── geo_rectangle.dart
│   │   │   ├── geo_triangle.dart
│   │   │   ├── geo_quadrilateral.dart
│   │   │   ├── geo_polygon.dart
│   │   │   ├── geo_line.dart
│   │   │   ├── geo_ray.dart
│   │   │   ├── geo_arc.dart
│   │   │   ├── geo_ring.dart
│   │   │   ├── geo_capsule.dart
│   │   │   ├── geo_bezier_curve.dart
│   │   │   ├── geo_spline.dart
│   │   │   └── geo_polyline.dart
│   │   └── canvas/
│   │       ├── geometry_canvas.dart
│   │       └── styled_shape.dart
├── test/
├── example/
└── pubspec.yaml
```

*Shipped as* (v0.4.0): the seven curve painters are one `painters/geometry_painter.dart`. Additions not in the tree above: `util/shape_path.dart` (`shapeToPath`), `util/shape_hit_test.dart` (path cache + hit-test), `util/arc_sector.dart`, `util/paint_helpers.dart`, `debug/geo_debug_overlay.dart`, `canvas/geo_grid.dart`, `widgets/geo_shape_container.dart` + `widgets/shape_pointer_region.dart` (shared paint / tap / hover / drag plumbing), `widgets/shape_widget.dart` + `widgets/shape_clipper.dart`, `style/animated_shape_style.dart`, and `scene/` (3D).

### 2.1.1 Naming convention

Widget classes use `Geo*` prefix (`GeoCircle`, `GeoLine`) to avoid collision with `geometry_kit` core types (`Circle`, `Line`) when both packages imported with no `as` prefix. Decision locked v0.1 — renaming post-release breaking.

### 2.2 Dependency graph

```
geometry_kit          (pure Dart — no Flutter dependency)
      ↑
geometry_kit_widgets  (Flutter — depends on geometry_kit)
```

`geometry_kit` must never gain a Flutter dependency. The widget layer is always the dependent, never the dependency.

### 2.3 `pubspec.yaml`

```yaml
name: geometry_kit_widgets
description: Flutter widgets for geometry_kit shapes — CustomPainter-backed, styled, and interactive.
version: 0.1.0

environment:
  sdk: ^3.11.3
  flutter: ">=3.27.0"   # withValues(alpha:) requires 3.27+

dependencies:
  flutter:
    sdk: flutter
  geometry_kit: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
```

---

## 3. Core Styling System

### 3.1 `ShapeStyle`

A shared, immutable style object passed to every widget. Keeps per-widget parameter lists short.

```dart
@immutable
class ShapeStyle {
  /// Fill color. Null means no fill (transparent interior).
  final Color? fillColor;

  /// Stroke (outline) color. Null means no stroke.
  final Color? strokeColor;

  /// Stroke width in logical pixels.
  final double strokeWidth;

  /// Opacity applied to the entire shape (fill + stroke).
  final double opacity;

  /// Optional dash pattern for the stroke.
  /// e.g. [8, 4] → 8px dash, 4px gap.
  final DashPattern? dashPattern;

  /// Stroke cap style (round, square, butt).
  final StrokeCap strokeCap;

  /// Stroke join style (round, miter, bevel).
  final StrokeJoin strokeJoin;

  const ShapeStyle({
    this.fillColor,
    this.strokeColor = Colors.black,
    this.strokeWidth = 1.0,
    this.opacity = 1.0,
    this.dashPattern,
    this.strokeCap = StrokeCap.butt,
    this.strokeJoin = StrokeJoin.miter,
  });

  /// Convenience: filled only.
  const ShapeStyle.filled(Color color)
      : fillColor = color,
        strokeColor = null,
        strokeWidth = 0,
        opacity = 1.0,
        dashPattern = null,
        strokeCap = StrokeCap.butt,
        strokeJoin = StrokeJoin.miter;

  /// Convenience: stroked only.
  const ShapeStyle.stroked(Color color, {double width = 1.0})
      : fillColor = null,
        strokeColor = color,
        strokeWidth = width,
        opacity = 1.0,
        dashPattern = null,
        strokeCap = StrokeCap.butt,
        strokeJoin = StrokeJoin.miter;

  ShapeStyle copyWith({ ... });
}
```

### 3.2 `DashPattern`

```dart
@immutable
class DashPattern {
  /// Alternating on/off lengths in logical pixels.
  /// [8, 4] → 8px on, 4px off.
  final List<double> intervals;
  final double phase;

  const DashPattern(this.intervals, {this.phase = 0});

  static const none = null;
}
```

Dashes are drawn manually on the `Canvas` using `PathMetrics` — no external dependency needed. Shared in `lib/src/util/dashed_path.dart`; every painter calls the helper so dash logic isn't duplicated.

### 3.3 `ShapeStyleTheme` (InheritedWidget)

Wraps a subtree to supply default `ShapeStyle`. Reduces boilerplate when many widgets share a style.

```dart
ShapeStyleTheme(
  data: const ShapeStyle.stroked(Colors.indigo, width: 2),
  child: Column(children: [
    GeoCircle(radius: 30),         // inherits indigo stroke
    GeoTriangle(...),              // inherits indigo stroke
    GeoLine(..., style: const ShapeStyle.stroked(Colors.red)), // override
  ]),
)
```

`ShapeStyle.of(context)` resolves the closest ancestor; widgets fall back to it when no explicit `style` passed. Locked v0.1 — adding inherited theme later forces every widget signature to change default semantics.

### 3.4 Color opacity

All painters use `Color.withValues(alpha: x)` — `withOpacity` deprecated since Flutter 3.27.

---

## 4. Widget Catalog

### 4.1 Widget API pattern

Every shape widget follows the same two-constructor pattern:

```dart
// Primary — flat parameters, widget builds the geometry object internally.
// Easiest for beginners.
GeoCircle({
  required double radius,
  Offset center = Offset.zero, // relative to widget's own coordinate space
  ShapeStyle? style,           // null → inherits from ShapeStyleTheme or default
  CoordinateMapper? mapper,    // null → identity (widget Y-down)
  VoidCallback? onTap,
  ValueChanged<bool>? onHover,
  Size size = const Size(200, 200), // widget's layout size
})

// Named — geometry object as source of truth.
// Best when the Circle was already computed by business logic.
GeoCircle.fromGeometry({
  required Circle circle,
  ShapeStyle? style,
  CoordinateMapper? mapper,
  VoidCallback? onTap,
  ValueChanged<bool>? onHover,
  Size size = const Size(200, 200),
})
```

The `.fromGeometry` constructor is the canonical implementation; the primary constructor just builds the geometry object and delegates.

**Coordinate mapping (locked v0.1):** widget default = top-left origin, Y-down (Flutter native). `CoordinateMapper` injectable from v0.1 — not deferred — because changing default coordinate semantics later breaks every painter signature. Built-in mappers: `CoordinateMapper.identity`, `CoordinateMapper.yUp(Size size)`, `CoordinateMapper.centered(Size size)`.

### 4.2 Shape widget catalog

| Widget               | Geometry class                    | Notes                                    |
| -------------------- | --------------------------------- | ---------------------------------------- |
| `GeoCircle`          | `Circle`                          |                                          |
| `GeoEllipse`         | `Ellipse`                         |                                          |
| `GeoRectangle`       | `Rectangle`                       | Supports corner radius for rounded rects |
| `GeoTriangle`        | `Triangle`                        |                                          |
| `GeoQuadrilateral`   | `Quadrilateral`                   | Dedicated — parity with core             |
| `GeoPolygon`         | `Polygon`                         | Generic n-gon                            |
| `GeoLine`            | `Line`                            | Tap/hover/drag by distance (v0.4). Arrow heads not built yet |
| `GeoRay`             | `Ray`                             | Cut where it leaves the widget           |
| `GeoArc`             | `Arc`                             | `sector: true` draws the pie slice       |
| `GeoRing`            | `Ring`                            | Even-odd path; hole stays empty          |
| `GeoCapsule`         | `Capsule`                         | Any orientation                          |
| `GeoBezierCurve`     | `QuadraticBezier` / `CubicBezier` | `.quadratic` / `.cubic` / `.fromGeometry` (no `degree` param) |
| `GeoSpline`          | `Spline`                          | Control points via `debugOverlay`        |
| `GeoPolyline`        | `Polyline`                        | Vertices via `debugOverlay`              |

Closed shapes fill + stroke. Open curves (`Line`, `Polyline`, `Arc`, Beziers,
`Spline`, `Ray`) stroke only, falling back to `fillColor` when no stroke color
is set.

### 4.3 Shared optional parameters (all widgets)

*Shipped as* (v0.4.0) — every `Geo*` widget and `StyledShape`:

```dart
// Debug / authoring aids — one config object instead of four bools
final GeoDebugOverlay? debugOverlay;   // showBoundingBox, showCenter,
                                       // showVertices, showDimensions, color

// Interaction
final VoidCallback? onTap;
final ValueChanged<bool>? onHoverChanged;   // bool = isHovering
final VoidCallback? onDragStart;
final ValueChanged<Offset>? onDragUpdate;   // per-frame delta, geometry space
final ValueChanged<Offset>? onDragEnd;      // total, geometry space
```

`GeoDebugOverlay()` turns on bounding box, center and vertices;
`GeoDebugOverlay.all` adds dimension labels. `onDoubleTap` was not built.

---

## 5. Painter Layer

Each `XxxPainter` is a `CustomPainter` subclass that is **not** exported from the barrel. Users interact only with widgets, never painters directly. This keeps the internal implementation free to change.

*Shipped as:* the Phase 1 shapes keep one painter each. The Phase 2 curves share one generic `GeometryPainter` over `paintGeometry`, which builds the path with `shapeToPath` and picks fill + stroke (closed) or stroke only (open). `GeometryCanvas` uses `paintGeometry` for every shape instead of a per-type dispatch chain. Debug overlays are a separate `GeoDebugOverlayPainter` installed as the `CustomPaint.foregroundPainter`, so no shape painter knows about them.

### 5.1 Painter responsibilities

- Convert geometry coordinates to canvas coordinates.
- Apply `ShapeStyle` to `Paint` objects.
- Draw fill pass, then stroke pass (order matters for correct visual layering).
- Implement dashes via `PathMetrics` if `dashPattern != null`.
- Handle `shouldRepaint` correctly — repaint only when style or geometry changes.

### 5.2 Example: `_CirclePainter`

```dart
class _CirclePainter extends CustomPainter {
  final Circle circle;
  final ShapeStyle style;

  const _CirclePainter({required this.circle, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(circle.center.x, circle.center.y);

    if (style.fillColor != null) {
      canvas.drawCircle(
        center,
        circle.radius,
        Paint()
          ..color = style.fillColor!.withValues(alpha: style.opacity)
          ..style = PaintingStyle.fill,
      );
    }

    if (style.strokeColor != null && style.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = style.strokeColor!.withValues(alpha: style.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.strokeWidth
        ..strokeCap = style.strokeCap
        ..strokeJoin = style.strokeJoin;

      if (style.dashPattern != null) {
        _drawDashedCircle(canvas, center, circle.radius, strokePaint, style.dashPattern!);
      } else {
        canvas.drawCircle(center, circle.radius, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.circle != circle || old.style != style;
}
```

### 5.3 `shouldRepaint` perf

`Polygon`/`Spline`/`Polyline` `==` walks all vertices each frame. For shapes with > ~32 control points, painters cache `hashCode` or accept a `revision` int and compare that instead. Helper: `bool _shapeChanged(Shape a, Shape b)` in `util/`.

*Shipped as* (v0.4.0): painters already compare geometry with `identical`, so `==` never runs per frame. The measured cost was rebuilding paths on every hover hit-test, so paths are memoised per geometry instance instead (`cachedShapePath` in `util/shape_hit_test.dart`: an `Expando` keyed by the geometry, invalidated when mapper or size changes). The same entry caches flattened samples (for curve hit-tests) and tight bounds (`Path.getBounds` includes Bezier control points).

### 5.4 `RepaintBoundary`

`GeoCanvas` (and individual widgets when nested in scrollables) wrap the `CustomPaint` in a `RepaintBoundary`. Without it a hover anywhere in the parent tree forces a full canvas repaint.

---

## 6. Interactivity

### 6.1 Hit testing via geometry

All interaction is backed by the geometry class's `contains(Point)` method, so hit-test accuracy matches the mathematical shape exactly — not a bounding box approximation.

*Shipped as:* `hitTestShape` tests the canvas-space path rather than calling `contains` (not every geometry type has one, and the path already includes the mapper). Closed shapes use `Path.contains` (even-odd for `Ring`). Open curves have no interior, so they test distance to the flattened curve against `strokeWidth / 2 + 4px`. The sketch below is the original idea.

```dart
// Inside GeoCircle's build method:
GestureDetector(
  behavior: HitTestBehavior.translucent, // see §6.4
  onTapUp: (details) {
    final localPos = details.localPosition;
    final point = Point(localPos.dx, localPos.dy);
    if (circle.contains(point)) {
      widget.onTap?.call();
    }
  },
  child: CustomPaint(
    painter: _CirclePainter(circle: circle, style: widget.style),
    size: widget.size,
  ),
)
```

### 6.2 Hover (desktop & web)

```dart
MouseRegion(
  onHover: (event) {
    final point = Point(event.localPosition.dx, event.localPosition.dy);
    final isInside = circle.contains(point);
    widget.onHover?.call(isInside);
  },
  child: ...,
)
```

### 6.3 Drag

*Shipped as* (v0.4.0) — preview, then commit. **Do not rebuild geometry per frame**: `ShapePointerRegion` keeps the drag offset in state, and `GeoShapeContainer` wraps the `CustomPaint` (and its debug overlay) in a `Transform.translate` inside the clip. `GeometryCanvas` does the same with `canvas.save(); canvas.translate(...)` around the dragged shape. Geometry stays immutable.

- A drag starts only if the pan-down position hits the shape (hit-test is on the shape at rest, with the drag offset subtracted).
- `onDragStart()` — drag began.
- `onDragUpdate(Offset delta)` — per-frame delta in **geometry space** (`CoordinateMapper.vectorFromCanvas` applies the Y flip). Informational: the widget already draws the drag, so moving geometry here too doubles it.
- `onDragEnd(Offset total)` — total displacement in geometry space. The preview offset resets to zero in the same frame, so the owner commits by translating its geometry.
- `GeometryCanvas` drags the topmost draggable shape under the pointer; shapes are tracked by paint index during the drag.

Pointer routing: `ShapeHitFilter` rejects positions off the shape at render hit-test time, so pointers there reach widgets behind (stacked `Geo*` widgets, scroll views). On the shape, `ShapeDragGestureRecognizer` (a pan that accepts after half the touch slop, `DragStartBehavior.down`) beats a scroll view's drag recognizer, so the shape moves instead of the page and stays under the finger. Verified on the iOS simulator in the example app.

### 6.4 `HitTestBehavior`

- Filled shapes → `HitTestBehavior.opaque` (whole bounds catches taps).
- Stroke-only shapes → `HitTestBehavior.translucent` (taps inside hollow interior pass through to widgets below).
- Default: `translucent`. Override via `hitTestBehavior` param.

*Shipped as:* no `hitTestBehavior` param. A render-level filter makes every widget behave like `translucent` off the shape and `opaque` on it, which is what both cases above wanted.

---

## 7. `GeometryCanvas` — Multi-Shape Widget

The flagship widget. Renders an arbitrary list of styled shapes onto a single `CustomPainter` canvas with unified hit testing across all shapes.

### 7.1 `StyledShape`

```dart
@immutable
class StyledShape {
  final Geometry shape;     // any geometry_kit Geometry (or ArcSector)
  final ShapeStyle style;
  final String? id;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHoverChanged;
  final VoidCallback? onDragStart;
  final ValueChanged<Offset>? onDragUpdate;
  final ValueChanged<Offset>? onDragEnd;
  final GeoDebugOverlay? debugOverlay;   // overrides the canvas-wide one
}
```

*Shipped as:* `shape` is `Geometry`, not `Shape` (breaking in v0.4.0). Most curve types in `geometry_kit` (`Arc`, `Ring`, `Ray`, Beziers, `Spline`, `Polyline`, and `Line`) do not implement `Shape`, and making them do so would mean inventing `area`/`rotate` for open and infinite curves in the core. Instead `geometry_kit` 1.3.0 adds an empty `Geometry` interface that `Shape` and every curve implement; `Object` was rejected because it accepted anything at compile time. It is deliberately not `sealed`, so other packages can implement it. `ArcSector` (widgets package) wraps an `Arc` to get the closed slice. Callbacks live on each `StyledShape` instead of canvas-level `onShapeTap(id)`.

### 7.2 `GeometryCanvas`

```dart
GeometryCanvas(
  size: const Size(400, 300),
  shapes: [
    StyledShape(
      Circle(center: Point(100, 100), radius: 50),
      style: ShapeStyle.filled(Colors.blue.withOpacity(0.4)),
      id: 'my-circle',
    ),
    StyledShape(
      Triangle(Point(200, 50), Point(300, 200), Point(150, 200)),
      style: ShapeStyle.stroked(Colors.red, width: 2),
      id: 'my-triangle',
    ),
    StyledShape(
      Line(Point(0, 0), Point(400, 300)),
      style: ShapeStyle.stroked(Colors.grey, width: 1),
    ),
  ],
  onShapeTap: (id) => print('Tapped: $id'),
  onShapeHover: (id, isHovering) { ... },
  showGrid: false,
  backgroundColor: Colors.white,
)
```

*Shipped as:* `GeometryCanvas(size, shapes, mapper, backgroundColor, clipBehavior, grid, debugOverlay)`. Per-shape callbacks on `StyledShape` replace `onShapeTap` / `onShapeHover`; `grid: GeoGrid(...)` replaces `showGrid`.

### 7.3 Hit testing in `GeometryCanvas`

Shapes are hit-tested in **reverse paint order** (top-most shape wins):

```dart
onTapUp: (details) {
  final point = Point(details.localPosition.dx, details.localPosition.dy);
  for (final s in widget.shapes.reversed) {
    if (_shapeContains(s.shape, point)) {
      widget.onShapeTap?.call(s.id);
      return;
    }
  }
},
```

`_shapeContains` dispatches to the correct `contains()` call per shape type. **Decision (locked):** use a type-switch in the widgets package, not a visitor on `Shape`. Visitor pattern would force `geometry_kit` core to know about every concrete subtype; type-switch keeps the pure-Dart core unchanged. Drawback: adding a new `Shape` subclass in core requires a corresponding case in widgets — caught by an exhaustive `assert` in dev builds.

### 7.4 Optional grid & axes

*Shipped as* (v0.4.0) — one config object; the origin comes from the canvas `CoordinateMapper` rather than a separate `origin` param:

```dart
GeometryCanvas(
  size: const Size(400, 300),
  mapper: CoordinateMapper.centered(const Size(400, 300)),
  grid: const GeoGrid(
    spacing: 20,          // geometry units
    majorEvery: 5,        // every 5th line in majorColor
    showAxes: true,       // axes through the geometry origin
  ),
  shapes: [...],
)
```

Painted after `backgroundColor`, before shapes. Lines sit at whole multiples of `spacing` in geometry space. Axis tick labels are not built.

The grid + axes combo makes `GeometryCanvas` a great educational and debugging tool.

---

## 8. Animation Compatibility

Widgets are intentionally stateless about animation — they render whatever geometry they're given. This means they compose naturally with Flutter's animation primitives:

```dart
// Animate a circle's radius with AnimationController
AnimatedBuilder(
  animation: _radiusAnim,
  builder: (context, _) => CircleWidget(
    radius: _radiusAnim.value,
    style: const ShapeStyle.filled(Colors.teal),
  ),
)

// Or use implicit animations with TweenAnimationBuilder
TweenAnimationBuilder<double>(
  tween: Tween(begin: 10, end: 80),
  duration: const Duration(seconds: 1),
  builder: (context, radius, _) => CircleWidget(radius: radius),
)
```

No special animation API needed — the widget just rebuilds cheaply because `CustomPainter.shouldRepaint` is tightly scoped.

---

## 9. Testing Strategy

### Widget tests

- Each widget renders without errors at various sizes.
- `onTap` fires when tapped inside the shape, not outside.
- `onHover` toggles correctly as pointer enters/leaves.
- Style changes trigger repaint (`shouldRepaint` returns `true`).

### Painter tests (using `flutter_test` `paints` matcher)

- Fill is drawn when `fillColor != null`.
- Stroke is drawn when `strokeColor != null`.
- No drawing occurs for invisible styles (null fill + null stroke).

### Golden tests

- One golden per widget with a canonical style — catches visual regressions.
- Stored under `test/goldens/`.

### `GeometryCanvas` tests

- Hit-test ordering (top shape wins).
- Correct shape dispatched to `onShapeTap`.
- Empty shapes list renders without error.

---

## 10. Documentation Plan

- Dedicated `README.md` for `geometry_kit_widgets` with quick-start example.
- Dartdoc on every public class and parameter.
- A `COOKBOOK.md` with copy-paste recipes:
  - "Draw a dashed circle"
  - "Clickable polygon"
  - "Animated bezier curve"
  - "Multi-shape canvas with hit testing"
  - "Draggable shapes"
- Interactive examples in the existing `flutter_example/` app — at least one demo per widget.

---

## 11. Phased Rollout

### Phase 1 — Core shapes + locked API surface (v0.1.0) ✅

Locked-now items (breaking to add later):

- `ShapeStyle`, `DashPattern`, `ShapeStyleTheme` (InheritedWidget)
- `CoordinateMapper` (identity / yUp / centered)
- `Geo*` naming convention
- Type-switch dispatch in `GeometryCanvas`
- `HitTestBehavior` defaults
- Basic `Semantics(label: ...)` on interactive widgets

Shape widgets:

- `GeoCircle`, `GeoEllipse`, `GeoRectangle`, `GeoTriangle`, `GeoQuadrilateral`, `GeoPolygon`
- `GeoLine`
- `GeometryCanvas` (render only, no interaction yet)
- Widget + golden tests
- CI guard: `geometry_kit` has no Flutter dep

### Phase 2 — Curves & interaction (v0.2.0 interaction, v0.4.0 curves) ✅

- `GeoArc`, `GeoRing`, `GeoCapsule`
- `GeoBezierCurve`, `GeoSpline`, `GeoPolyline`
- `GeoRay`
- Tap + hover interactivity on all widgets
- `GeometryCanvas` hit testing + `onShapeTap`

### Phase 3 — Advanced (v0.4.0) ✅

> v0.3.0 shipped 3D scenes (`GeoScene`) instead, so phase 2's curves and phase 3
> landed together in v0.4.0. Performance shipped as per-instance path
> memoisation (an `Expando` keyed by geometry identity) rather than
> hashCode caching: painters already compare geometry by identity, and the
> real cost was rebuilding paths on every hover hit-test.


- Drag support on all widgets and `GeometryCanvas` (canvas.translate strategy)
- Grid + axes on `GeometryCanvas`
- Debug overlay params (`showBoundingBox`, `showCenter`, `showVertices`, `showDimensions`)
- Performance: hashCode caching for large polygons/splines

### Phase 4 — Polish (v0.5.0+)

- Tooltip support on hover
- Export `GeometryCanvas` to `ui.Image` (for screenshot/share)
- Dark mode style presets
- Extended a11y: semantic descriptions of shape geometry

---

## 12. Resolved Decisions & Open Questions

### Resolved (locked v0.1)

1. **Coordinate convention** — Y-down default (Flutter native). `CoordinateMapper` injectable from v0.1 for Y-up math convention.
2. **`Shape` dispatch** — type-switch in widgets package; pure-Dart core stays free of widget concerns.
3. **Naming** — `Geo*` prefix; avoids collision with `geometry_kit` core types.
4. **Theme** — `ShapeStyleTheme` InheritedWidget for default styles, in v0.1.
5. **HitTestBehavior** — `translucent` default, `opaque` for filled-only convenience constructor.
6. **Color opacity** — `withValues(alpha: x)` (Flutter 3.27+).

### Resolved (v0.4.0)

7. **Curve geometry in `StyledShape`** — field typed `Geometry` (core 1.3.0 marker interface over `Shape` and the curves). Unknown `Geometry` implementations are skipped with a debug warning.
8. **Open-curve hit-test** — distance to the flattened curve, `strokeWidth / 2 + 4px`; `GeoLine` gained tap/hover/drag.
9. **Drag model** — preview-then-commit; deltas and totals in geometry space.
10. **Pointer routing** — off-shape pointers pass through (render hit-test filter); on-shape drags beat scroll views (early-accepting pan recognizer).
11. **Debug overlays** — one `GeoDebugOverlay` config object (not four bools), drawn as a foreground painter.
12. **Perf** — per-instance path memoisation instead of `hashCode` caching.

### Still open

1. **`SizedBox` vs `LayoutBuilder`** — explicit `Size` or fill-available? Plan offers both (`size` param + `GeoCircle.expand()` constructor).
2. **Responsiveness** — logical pixels (absolute) vs normalized (0–1 of widget size)? Offer via `CoordinateSpace` enum if demand emerges; default absolute.
3. **Dash path performance** — `PathMetrics` is CPU-bound. Benchmark in Phase 1; isolate offload only if measured cost > 1 frame on long polylines. Still not benchmarked.
4. **`GeoLine` arrow heads** — in the catalog, not built.

---

## 13. Risks & Mitigations

| Risk                                            | Mitigation                                                                                |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `geometry_kit` gains a Flutter dep accidentally | CI script: `dart pub deps --json \| jq '.packages[] \| select(.name=="flutter")'` empty   |
| Hit-test mismatch (visual vs logical shape)     | Use geometry `contains()` exclusively — never use bounding box                            |
| Dashed path perf on complex curves              | Benchmark in Phase 1; add isolate offload in Phase 3 if needed                            |
| API sprawl from too many widget params          | Enforce `ShapeStyle` for all visual params; keep widgets thin                             |
| Golden test flakiness across platforms          | Run goldens on a pinned Linux CI environment only                                         |
| Coordinate confusion (Y-up vs Y-down)           | Default Y-down with clear docs; `CoordinateMapper` as escape hatch                        |
| Vertex `==` cost on large polygons              | Painters compare by `identical`; paths memoised per instance (v0.4.0)                     |
| Drag rebuilds geometry per frame                | Drag offset drawn via `Transform.translate` / `canvas.translate`; geometry stays immutable (v0.4.0) |
| `Path.getBounds` loose on curves                | Tight bounds from flattened samples for overlays (v0.4.0)                                 |
| Nested-tree forced repaint on hover             | Wrap `CustomPaint` in `RepaintBoundary` in widget + canvas                                |

---

## 14. Success Criteria

v0.1.0 (shipped):

- [x] All Phase 1 widgets implemented with painter + widget layers.
- [x] `ShapeStyle` covers fill, stroke, opacity, dash, cap, join.
- [x] `ShapeStyleTheme` resolves defaults (`ShapeStyleTheme.of` / `resolve`).
- [x] `CoordinateMapper` (identity, yUp, centered) wired through every widget.
- [x] `GeometryCanvas` renders a list of mixed shapes correctly.
- [x] `Geo*` naming applied consistently; no `*Widget` suffix in public API.
- [ ] Widget tests and golden tests pass on CI. (Widget tests yes; no goldens yet.)
- [x] `Semantics(label: ...)` present on every interactive widget.
- [x] `RepaintBoundary` wraps every `CustomPaint`.
- [x] `README.md` has a working quick-start example.
- [ ] `geometry_kit` has zero Flutter dependencies (true today; CI script not added).
- [x] Published to pub.dev as `geometry_kit_widgets`.

v0.4.0 (Phases 2–3):

- [x] Seven curve widgets, each with flat + `.fromGeometry` constructors.
- [x] `shapeToPath` and `GeometryCanvas` support every curve type; `ArcSector` for slices.
- [x] Tap / hover / drag on all 14 widgets and on `StyledShape`.
- [x] `GeoGrid` on `GeometryCanvas`; `GeoDebugOverlay` everywhere.
- [x] Tests in `test/curves_and_interaction_test.dart`.
- [x] Example app demo page for curves, drag, grid and overlays (`example/lib/demos/curves_demo.dart`).
- [ ] Published to pub.dev, in order: `geometry_kit` 1.3.0 (`Geometry` interface) → `geometry_kit_widgets` 0.4.0 → `geometry_kit_editor` 0.2.0 (constraint `^0.4.0`).

v0.5.0 (Phase 4): tooltips, `ui.Image` export, dark presets, semantic geometry descriptions.
