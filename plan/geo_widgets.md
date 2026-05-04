# Geometry Kit Widgets — Flutter Widget Library Plan

A roadmap for `geometry_kit_widgets`, a companion Flutter package that wraps `geometry_kit` shapes into declarative, customizable, interactive Flutter widgets backed by `CustomPainter`.

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
- 3D rendering (scoped to 2D shapes; 3D widgets can follow as `geometry_kit_3d_widgets`).
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
| `GeoLine`            | `Line` / `Segment`                | Supports arrows via `arrowHead` param    |
| `GeoRay`             | `Ray`                             | Drawn clipped to widget bounds           |
| `GeoArc`             | `Arc`                             | Supports sector fill                     |
| `GeoRing`            | `Ring`                            |                                          |
| `GeoCapsule`         | `Capsule`                         |                                          |
| `GeoBezierCurve`     | `QuadraticBezier` / `CubicBezier` | `degree` param selects type              |
| `GeoSpline`          | `Spline`                          | Optionally shows control points          |
| `GeoPolyline`        | `Polyline`                        | Optionally shows vertices                |

### 4.3 Shared optional parameters (all widgets)

```dart
// Debug / authoring aids
final bool showBoundingBox;       // draws the AABB in a muted color
final bool showCenter;            // draws a crosshair at the centroid
final bool showVertices;          // draws dots at key points (polygon corners, etc.)
final bool showDimensions;        // draws length/radius labels

// Interaction
final VoidCallback? onTap;
final VoidCallback? onDoubleTap;
final ValueChanged<bool>? onHover;           // bool = isHovering
final ValueChanged<Offset>? onPanUpdate;    // drag offset delta
```

Debug parameters default to `false` and are invaluable during development.

---

## 5. Painter Layer

Each `_XxxPainter` is a `CustomPainter` subclass that is **not** exported publicly. Users interact only with widgets, never painters directly. This keeps the internal implementation free to change.

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

### 5.4 `RepaintBoundary`

`GeoCanvas` (and individual widgets when nested in scrollables) wrap the `CustomPaint` in a `RepaintBoundary`. Without it a hover anywhere in the parent tree forces a full canvas repaint.

---

## 6. Interactivity

### 6.1 Hit testing via geometry

All interaction is backed by the geometry class's `contains(Point)` method, so hit-test accuracy matches the mathematical shape exactly — not a bounding box approximation.

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

Widget tracks `_dragOffset` in state. **Do not rebuild geometry per frame** — `Polygon.translate` allocates new vertex list each tick (GC pressure on long drags). Instead apply `canvas.translate(dx, dy)` in the painter, leaving geometry immutable:

```dart
// In _CirclePainter.paint
canvas.save();
canvas.translate(dragOffset.dx, dragOffset.dy);
// ... draw at original geometry coords ...
canvas.restore();
```

Hit testing for the dragged shape subtracts `_dragOffset` from local pointer position before calling `contains()`. Widget exposes:

- `onPanUpdate(Offset delta)` — per-frame delta (matches Flutter's `DragUpdateDetails.delta`).
- `onDragEnd(Offset totalOffset)` — accumulated translation since drag start; parent uses this to mutate its model.

### 6.4 `HitTestBehavior`

- Filled shapes → `HitTestBehavior.opaque` (whole bounds catches taps).
- Stroke-only shapes → `HitTestBehavior.translucent` (taps inside hollow interior pass through to widgets below).
- Default: `translucent`. Override via `hitTestBehavior` param.

---

## 7. `GeometryCanvas` — Multi-Shape Widget

The flagship widget. Renders an arbitrary list of styled shapes onto a single `CustomPainter` canvas with unified hit testing across all shapes.

### 7.1 `StyledShape`

```dart
@immutable
class StyledShape {
  final Shape shape;        // any geometry_kit Shape subclass
  final ShapeStyle style;
  final String? id;         // optional identifier for hit-test callbacks

  const StyledShape(this.shape, {required this.style, this.id});
}
```

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

```dart
GeometryCanvas(
  showGrid: true,
  gridSpacing: 20,
  gridColor: Colors.grey.withOpacity(0.2),
  showAxes: true,
  axisColor: Colors.grey,
  origin: Offset(200, 150), // where (0,0) maps to in widget space
  ...
)
```

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

### Phase 1 — Core shapes + locked API surface (v0.1.0)

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

### Phase 2 — Curves & interaction (v0.2.0)

- `GeoArc`, `GeoRing`, `GeoCapsule`
- `GeoBezierCurve`, `GeoSpline`, `GeoPolyline`
- `GeoRay`
- Tap + hover interactivity on all widgets
- `GeometryCanvas` hit testing + `onShapeTap`

### Phase 3 — Advanced (v0.3.0)

- Drag support on all widgets and `GeometryCanvas` (canvas.translate strategy)
- Grid + axes on `GeometryCanvas`
- Debug overlay params (`showBoundingBox`, `showCenter`, `showVertices`, `showDimensions`)
- Performance: hashCode caching for large polygons/splines

### Phase 4 — Polish (v0.4.0+)

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

### Still open

1. **`SizedBox` vs `LayoutBuilder`** — explicit `Size` or fill-available? Plan offers both (`size` param + `GeoCircle.expand()` constructor).
2. **Responsiveness** — logical pixels (absolute) vs normalized (0–1 of widget size)? Offer via `CoordinateSpace` enum if demand emerges; default absolute.
3. **Dash path performance** — `PathMetrics` is CPU-bound. Benchmark in Phase 1; isolate offload only if measured cost > 1 frame on long polylines.

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
| Vertex `==` cost on large polygons              | Cache `hashCode` or expose `revision` int; painters compare cheap field first             |
| Drag rebuilds geometry per frame                | Apply `canvas.translate` in painter; geometry stays immutable                             |
| Nested-tree forced repaint on hover             | Wrap `CustomPaint` in `RepaintBoundary` in widget + canvas                                |

---

## 14. Success Criteria

v0.1.0 ships when:

- [ ] All Phase 1 widgets implemented with painter + widget layers.
- [ ] `ShapeStyle` covers fill, stroke, opacity, dash, cap, join.
- [ ] `ShapeStyleTheme` resolves defaults via `ShapeStyle.of(context)`.
- [ ] `CoordinateMapper` (identity, yUp, centered) wired through every widget.
- [ ] `GeometryCanvas` renders a list of mixed shapes correctly.
- [ ] `Geo*` naming applied consistently; no `*Widget` suffix in public API.
- [ ] Widget tests and golden tests pass on CI.
- [ ] `Semantics(label: ...)` present on every interactive widget.
- [ ] `RepaintBoundary` wraps every `CustomPaint`.
- [ ] `README.md` has a working quick-start example.
- [ ] `geometry_kit` has zero Flutter dependencies (enforced by CI script).
- [ ] Published to pub.dev as `geometry_kit_widgets`.
