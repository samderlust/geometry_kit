[![GitHub](https://img.shields.io/badge/GitHub-samderlust/geometry__kit-181717?logo=github)](https://github.com/samderlust/geometry_kit)
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# geometry_kit_widgets

Flutter widgets for [`geometry_kit`](../geometry_kit) shapes — `CustomPainter`-backed, styled, and composable.

![2D widgets: gradient circle, dashed rectangle, triangle, sweep-gradient pentagon, ellipse, quadrilateral and dotted circle](https://raw.githubusercontent.com/samderlust/geometry_kit/main/packages/geometry_kit_widgets/screenshots/widgets_2d.png)

![GeoScene: a 3D bar chart on a floor grid with a dashed trend line and handles](https://raw.githubusercontent.com/samderlust/geometry_kit/main/packages/geometry_kit_widgets/screenshots/scene.png)

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return GeoCircle.fromGeometry(
      circle: const Circle(radius: 40, center: Point(100, 100)),
      style: const ShapeStyle.stroked(Colors.indigo, width: 2),
      size: const Size(200, 200),
    );
  }
}
```

## Two ways to render

**Standalone** — each `Geo*` widget owns its own `CustomPaint`. Drop into any layout:

```dart
Column(children: [
  GeoCircle(radius: 30, ...),
  Text('label'),
  GeoTriangle(...),
])
```

**Multi-shape `GeometryCanvas`** — share a single paint pass across many shapes (cheaper, layered, unified hit-testing in later phases):

```dart
GeometryCanvas(
  size: const Size(400, 300),
  shapes: [
    StyledShape(
      Circle(center: Point(100, 100), radius: 50),
      style: const ShapeStyle.filled(Colors.blue),
    ),
    StyledShape(
      Triangle(Point(200, 50), Point(300, 200), Point(150, 200)),
      style: const ShapeStyle.stroked(Colors.red, width: 2),
    ),
  ],
)
```

Both paths use the same painter classes — pick whichever fits the layout.

## Widgets

| Widget             | Geometry                          | Kind   |
| ------------------ | --------------------------------- | ------ |
| `GeoCircle`        | `Circle`                          | closed |
| `GeoEllipse`       | `Ellipse`                         | closed |
| `GeoRectangle`     | `Rectangle`                       | closed |
| `GeoTriangle`      | `Triangle`                        | closed |
| `GeoQuadrilateral` | `Quadrilateral`                   | closed |
| `GeoPolygon`       | `Polygon`                         | closed |
| `GeoRing`          | `Ring`                            | closed |
| `GeoCapsule`       | `Capsule`                         | closed |
| `GeoArc`           | `Arc` (`sector: true` → closed)   | open   |
| `GeoLine`          | `Line`                            | open   |
| `GeoPolyline`      | `Polyline`                        | open   |
| `GeoBezierCurve`   | `QuadraticBezier` / `CubicBezier` | open   |
| `GeoSpline`        | `Spline`                          | open   |
| `GeoRay`           | `Ray` (cut at the widget edge)    | open   |

Each widget exposes a flat constructor (build geometry from primitives) and
`.fromGeometry` (pass an existing geometry instance). `GeoBezierCurve` has
`.quadratic` and `.cubic` instead of a flat one.

Closed shapes fill and stroke. Open curves are stroked only — a
`fillColor`-only style strokes in that color — and hit-test within half the
stroke width plus a few pixels of the curve. `GeoRing` leaves its hole
empty; `GeoArc(sector: true)` draws the pie slice.

```dart
GeoBezierCurve.cubic(
  start: const Offset(10, 150),
  control1: const Offset(40, 10),
  control2: const Offset(160, 10),
  end: const Offset(190, 150),
  style: const ShapeStyle.stroked(Colors.teal, width: 3),
)

GeoArc(
  radius: 60,
  center: const Offset(100, 100),
  startDeg: -30,
  endDeg: 210,
  sector: true,
  style: const ShapeStyle.filled(Colors.orange),
)
```

In a `GeometryCanvas`, wrap an `Arc` in `ArcSector` to get the slice.

## Styling

`ShapeStyle` bundles fill, stroke, opacity, dash pattern, cap, and join into one immutable object:

```dart
const ShapeStyle();                                  // 1px black stroke
const ShapeStyle.filled(Colors.indigo);              // solid fill
const ShapeStyle.stroked(Colors.red, width: 3);      // 3px red stroke
const ShapeStyle(
  fillColor: Colors.blue,
  strokeColor: Colors.indigo,
  strokeWidth: 2,
  opacity: 0.7,
  dashPattern: DashPattern([8, 4]),
);
```

### Gradients

Pass any Flutter `Gradient` (linear, radial, sweep) on `fillGradient` or
`strokeGradient`. Gradients win over solid colors. Resolved against the
shape's axis-aligned bounding rect at paint time:

```dart
const ShapeStyle(
  fillGradient: RadialGradient(
    colors: [Color(0xFFFFF6C8), Color(0xFFFFD15C), Color(0xFFE08A1F)],
    stops: [0.0, 0.55, 1.0],
  ),
  strokeColor: null,
  strokeWidth: 0,
);

const ShapeStyle.gradientFilled(
  LinearGradient(colors: [Color(0xFF4FA3E3), Color(0xFF1B4F8B)]),
);
```

`opacity` does not modulate gradients — encode alpha directly into the
gradient color stops. `GeoLine` ignores `strokeGradient` (asserted in debug):
zero-area bounds make shader resolution degenerate.

### Paint escape hatch

For Skia features `ShapeStyle` does not surface directly (`MaskFilter`,
`ImageFilter`, `BlendMode`, custom shaders), use `fillPaintBuilder` /
`strokePaintBuilder`. The hook receives the resolved base `Paint` plus the
shape's bounds:

```dart
Paint glow(Paint base, Rect bounds) =>
    base..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

const ShapeStyle(
  fillColor: Color(0x55FFD15C),
  fillPaintBuilder: glow,
);
```

Prefer top-level or `static` builders — `ShapeStyle` equality compares them
by reference, so a fresh closure each build will defeat
`shouldRepaint` short-circuiting.

### Theming + field-level merge

Wrap a subtree in `ShapeStyleTheme` to share a default style:

```dart
ShapeStyleTheme(
  data: const ShapeStyle.stroked(Colors.teal, width: 2),
  child: Column(children: [
    GeoCircle(radius: 30),       // teal stroke
    GeoTriangle(...),            // teal stroke
    GeoLine(..., style: const ShapeStyle.stroked(Colors.red)), // override
  ]),
)
```

Resolution: `explicit.merge(ambient)` per field — fields the override
leaves `null` fall back to the closest `ShapeStyleTheme`, otherwise to the
constructor default (`strokeWidth: 1.0`, `strokeCap: butt`, …). All
scalar fields (`strokeWidth`, `opacity`, `strokeCap`, `strokeJoin`) are
nullable; pass `null` explicitly via the raw constructor (not `copyWith`)
to opt a field into theme inheritance.

```dart
ShapeStyleTheme(
  data: const ShapeStyle(strokeColor: Colors.teal, strokeWidth: 2),
  child: GeoCircle(
    radius: 30,
    // dashes here, teal stroke + 2px width inherited from theme
    style: const ShapeStyle(
      strokeColor: null,
      strokeWidth: null,
      dashPattern: DashPattern([6, 4]),
    ),
  ),
)
```

### Animating styles

`ShapeStyle.lerp` interpolates colors and the `strokeWidth` / `opacity`
scalars; gradients, dash patterns, enum fields, and `PaintBuilder`s snap
at `t >= 0.5`. Drop-in implicit animation via `AnimatedShapeStyle`:

```dart
AnimatedShapeStyle(
  style: highlighted ? hotStyle : coolStyle,
  duration: const Duration(milliseconds: 250),
  child: const GeoCircle(radius: 30),
)
```

`AnimatedShapeStyle` supplies the interpolated style to descendants via a
`ShapeStyleTheme`, so any `Geo*` widget without an explicit `style` (or
with a partial style that nulls the relevant fields) follows the animation.
For explicit driving use `ShapeStyleTween` with an `AnimationController`.

## Coordinate mapping

Default = Flutter native (top-left origin, Y-down). Inject a `CoordinateMapper` for math conventions:

```dart
GeoCircle(
  radius: 30,
  mapper: CoordinateMapper.yUp(const Size(200, 200)),
  size: const Size(200, 200),
)

// Origin at the canvas center, Y-up:
GeometryCanvas(
  size: const Size(400, 300),
  mapper: CoordinateMapper.centered(const Size(400, 300)),
  shapes: [...],
)
```

Built-in mappers: `identity`, `yUp(size)`, `centered(size, {yUp = true})`.

## Clipping & layering

Every `Geo*` widget and `GeometryCanvas` accepts `clipBehavior` (default `Clip.hardEdge`). Shapes that extend past `size` are clipped to widget bounds — they don't bleed onto neighbors. Set `Clip.none` to allow overflow.

```dart
GeoCircle(
  radius: 120,
  size: const Size(80, 80),
  clipBehavior: Clip.none,    // circle draws outside the 80x80 box
)
```

`GeometryCanvas` defaults to `backgroundColor: null` (transparent) so widgets stacked underneath remain visible.

### Clipping arbitrary widgets to a shape

`ShapeWidget` hosts any child widget clipped to a geometry shape, with an
optional `ShapeStyle` overlay drawn above the clipped child:

```dart
ShapeWidget(
  shape: const Circle(center: Point(50, 50), radius: 50),
  size: const Size(100, 100),
  style: const ShapeStyle.stroked(Colors.white, width: 2),
  child: Image.network('https://picsum.photos/seed/earth/200'),
)
```

For raw control, `ShapeClipper` is a `CustomClipper<Path>` you can pass
to Flutter's `ClipPath` directly. And `shapeToPath(shape, mapper)` returns
the same canvas-space `Path` the painters use — useful for hit-test
regions, reflowing text inside a shape, or animated path morphs.

```dart
ClipPath(
  clipper: ShapeClipper(
    shape: Polygon(vertices),
    mapper: CoordinateMapper.centered(size),
  ),
  child: child,
)
```

`shapeToPath` supports `Circle`, `Ellipse`, `Rectangle`, `Triangle`,
`Quadrilateral`, `Polygon`, and `Line`. Clipping a `Line` is degenerate
(zero-area path) — documented but not asserted.

## Tap + hover interactivity

Every `Geo*` widget accepts optional `onTap` and `onHoverChanged`
callbacks. Hit-test is shape-precise — pointer events inside the host
widget rect but outside the shape are ignored. Closed shapes test
containment (`GeoRectangle.cornerRadius` is honoured, `GeoRing`'s hole
misses); open curves test distance to the curve.

```dart
GeoCircle(
  radius: 30,
  center: const Offset(50, 50),
  size: const Size(100, 100),
  style: const ShapeStyle.filled(Colors.indigo),
  onTap: () => print('tapped'),
  onHoverChanged: (hovering) => setState(() => _hot = hovering),
)
```

Pair with `AnimatedShapeStyle` to fade hover styles smoothly:

```dart
AnimatedShapeStyle(
  style: _hot ? hotStyle : coolStyle,
  duration: const Duration(milliseconds: 150),
  child: GeoCircle(radius: 30, onHoverChanged: (v) => setState(() => _hot = v)),
)
```

`StyledShape` exposes the same callbacks; `GeometryCanvas` walks shapes
top-down on each pointer event and dispatches to the topmost shape under
the pointer. A common pattern is to reorder the shape list on tap so the
tapped shape moves to the top of the paint stack:

```dart
List<String> _order = ['blue', 'orange', 'green'];

GeometryCanvas(
  size: const Size(300, 220),
  shapes: _order.map((id) => StyledShape(
    _circleFor(id),
    id: id,
    style: _styleFor(id),
    onTap: () => setState(() {
      _order = [..._order.where((e) => e != id), id];
    }),
  )).toList(),
)
```

Hover supports both mouse pointers and stylus / touch hover.

Pointers that miss the shape are not hit at all — they reach whatever is
behind, so `Geo*` widgets can be stacked in a `Stack` and each one still
gets its own taps and drags. `GeometryCanvas` does the same for pointers
that miss every interactive shape.

## Drag

Set any of `onDragStart`, `onDragUpdate`, `onDragEnd` to make a shape
draggable — on every `Geo*` widget and on `StyledShape`. Only drags that
start on the shape move it; those win over an enclosing scroll view, while
drags elsewhere still scroll it.

While the drag is in flight the widget draws the shape displaced by the
pointer; geometry is not rebuilt per frame. When the pointer lifts,
`onDragEnd` reports the total displacement **in geometry space** (a Y-up
mapper's flip is applied) and the drawn offset resets — commit the move by
translating your geometry there:

```dart
Circle _circle = const Circle(center: Point(80, 80), radius: 30);

GeoCircle.fromGeometry(
  circle: _circle,
  style: const ShapeStyle.filled(Colors.indigo),
  onDragEnd: (d) => setState(() => _circle = _circle.translate(x: d.dx, y: d.dy)),
)
```

Every `Geometry` has `translate`, so a canvas of mixed shapes commits drags
without a type switch: `shape.translate(x: d.dx, y: d.dy)`.

`onDragUpdate` gives per-frame deltas for live readouts. It is
informational: the widget already draws the drag, so moving the geometry
there too would double it. `GeometryCanvas` drags the topmost draggable
shape under the pointer.

## Grid + axes

`GeometryCanvas(grid: GeoGrid(...))` paints grid lines at multiples of
`spacing` in geometry space, plus the axes through the origin. Lines follow
the canvas mapper, so a centered mapper puts the axes in the middle:

```dart
GeometryCanvas(
  size: const Size(400, 300),
  mapper: CoordinateMapper.centered(const Size(400, 300)),
  grid: const GeoGrid(spacing: 20, majorEvery: 5),
  shapes: [...],
)
```

## Debug overlays

`debugOverlay: GeoDebugOverlay(...)` on any `Geo*` widget or `StyledShape`
(or on `GeometryCanvas` for every shape) draws authoring aids above the
shape:

| Flag              | Draws                                                                 |
| ----------------- | --------------------------------------------------------------------- |
| `showBoundingBox` | dashed tight bounds of the outline                                    |
| `showCenter`      | crosshair at the center / centroid / midpoint / ray origin            |
| `showVertices`    | dots at corners, endpoints, polyline points, spline control points; Bezier controls as hollow dots with handle lines |
| `showDimensions`  | a label: radius, side lengths, width × height, length, sweep angle   |

The first three are on by default; `GeoDebugOverlay.all` adds dimensions.

```dart
GeoSpline(
  points: const [Offset(10, 150), Offset(70, 30), Offset(130, 120), Offset(190, 40)],
  debugOverlay: GeoDebugOverlay.all,
)
```

## 3D scenes

`GeoScene` draws [`geometry_kit_3d`](../geometry_kit_3d) solids with an orbit
camera, flat shading and picking. It runs on the normal Flutter `Canvas`, so it
works on every platform with no GPU setup.

```dart
GeoScene(
  camera: const OrbitCamera(yaw: 35, pitch: 25, distance: 7),
  onTap: (hit) => debugPrint(hit?.node.id),
  children: [
    ...GeoPath3.grid(extent: 3, step: 0.5),
    GeoSolid(
      Box.fromBase(center: Point3.zero, width: 1, depth: 1, height: 1.5),
      style: const ShapeStyle(fillColor: Colors.indigo, strokeColor: Colors.black),
      id: 'crate',
    ),
    const GeoLabel3(Point3(0, 1.8, 0), 'crate'),
  ],
)
```

| Node        | Draws                                                        |
| ----------- | ------------------------------------------------------------ |
| `GeoSolid`  | Any `Solid`, shaded by the scene light; edges from `strokeColor`; optional `gradient` |
| `GeoPath3`  | A 3D polyline (on top of solids, or underneath with `overlay: false`) |
| `GeoLabel3` | Text pinned to a 3D point                                   |
| `GeoHandle` | A fixed-size dot or square at a 3D point, drawn on top and picked on screen |

Give a `GeoSolid` a `transform` (`Transform3`) to place a local-space solid:
the mesh is cached once and moved at paint time, so animating or dragging it
never re-triangulates.

### Gradients on solids

![Solid gradients: top-to-bottom cube, three-colour corner-to-corner cube, radial cylinder and radial sphere](https://raw.githubusercontent.com/samderlust/geometry_kit/main/packages/geometry_kit_widgets/screenshots/gradients.png)

Give a `GeoSolid` a `gradient` to colour it with a `SolidGradient` instead of
`fillColor`. The gradient is laid across the solid's **local** bounding box,
so it moves, turns and scales with the solid's `transform`. Opacity and edge
outlines still come from `style`.

Positions are `Anchor3`s: points in that box, -1 to 1 on each axis.

| Axis | -1 | 1 |
| ---- | -- | - |
| `x`  | left | right |
| `y`  | bottom | top |
| `z`  | back | front |

Constants cover the usual spots: `Anchor3.center`, `.top`, `.bottom`,
`.left`, `.right`, `.front`, `.back`, `.topLeftFront`, `.bottomRightBack`.

**Linear**: from `start` to `end`. The two anchors pick the side the
gradient starts from; swap them (or use `reversed`) to flip it.

```dart
GeoSolid(
  Box.cube(center: Point3.zero, size: 1),
  gradient: const SolidGradient.linear(
    start: Anchor3.topLeftFront,
    end: Anchor3.bottomRightBack,
    colors: [Colors.teal, Colors.orange, Colors.purple],
    stops: [0, 0.4, 1], // optional; evenly spread when left out
  ),
)
```

**Radial**: outward from `center`, reaching the last colour at `radius`
(in anchor units). Both are optional: the centre defaults to the top, and
without a radius the gradient reaches right across the solid.

```dart
GeoSolid(
  const Sphere(center: Point3.zero, radius: 1),
  gradient: const SolidGradient.radial(
    center: Anchor3.top,
    colors: [Colors.amber, Colors.deepPurple],
  ),
)
```

Keep a radial centre off the middle of a ball: every point on a sphere is
the same distance from its middle, so it would come out one colour.

Colours are set at each mesh vertex and blended across triangles. A
two-colour linear gradient that spans the box is exact as is. Radial
gradients, three or more colours, or ends inside the box bend within a
face, so those solids are drawn on a finer mesh, with up to 16 times the
triangles on big flat faces (see `SolidGradient.needsRefinement` and
`SceneMesh.refined`).

Gestures: drag to orbit, pinch or scroll to zoom. `onTap` / `onHover` report a
`SceneHit` (the node plus distance, point and normal). Set `onDragSolid` and
dragging a solid moves it on the horizontal plane instead of orbiting.

For custom tools, pass a `SceneInteraction` as `interaction`: it sees each
pointer before the camera and can claim the gesture. `SceneViewport` turns
pointer positions into rays, picks solids and `GeoHandle`s, and finds drag
planes. [`geometry_kit_editor`](../geometry_kit_editor) builds selection,
drag-to-move and undo on top of this.

How it renders: each solid is triangulated, back faces are culled, triangles are
sorted back to front and filled with one `drawVertices` call. That is fine for
charts, rooms and simple models up to a few thousand triangles. There is no
depth buffer, so faces that cut through each other can draw in the wrong order.
For heavy models, export `solid.toMesh()` to a GPU renderer instead.

## Other features

- `Semantics(label: ...)` baked into every widget for accessibility.
- `RepaintBoundary` wraps every `CustomPaint` to keep nearby state changes from forcing a full repaint.
- Dash patterns are drawn via shared `PathMetrics` helper — no extra dependency.
- Paths are memoised per geometry instance, so hover hit-testing on dense polygons and splines does not rebuild them on every pointer move.

## See also

The `example/` app ships interactive demos covering every widget, theme
overrides, dash patterns, coordinate mappers, multi-shape canvas, gradient
+ `PaintBuilder` styling (animated solar system with sliders for orbit
speed and planet scale), shape clipping (gradient circle, text in
triangle, plus a live image-clip playground with vertex-count + rotation
sliders and a network/Flutter-logo/gradient source picker), and tap +
hover interactivity (per-`Geo*` callbacks plus a canvas demo where
tapping a shape reorders it to the top of the paint stack).
The 3D tab covers a solids tour, cone slice, bar chart, room,
draw-and-extrude, picking & contact, vase export and the editor demo (with
solid, linear and radial fills for the selection); each
shows the live scene, its controls and the code that builds it.

```bash
cd example && flutter run
```

## Roadmap

- **Done in 0.4.0**: curve widgets (`GeoArc`, `GeoRing`, `GeoCapsule`, `GeoBezierCurve`, `GeoSpline`, `GeoPolyline`, `GeoRay`), drag on every widget and `GeometryCanvas`, grid + axes, debug overlays, path memoisation.
- **Next (0.5.0)**: tooltips on hover, `GeometryCanvas` export to `ui.Image`, dark mode style presets, semantic descriptions of shape geometry.
- **Deferred** (gated on demand): multi-ancestor `ShapeStyleTheme` merge
  chain, `ShapeStyleResolver` builder for context-driven theming, shader
  cache for animated gradient grids. See `plan/decorative_styling.md`.

---

[![GitHub](https://img.shields.io/badge/GitHub-samderlust/geometry__kit-181717?logo=github)](https://github.com/samderlust/geometry_kit)
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)
