[![GitHub](https://img.shields.io/badge/GitHub-samderlust/geometry__kits__mono-181717?logo=github)](https://github.com/samderlust/geometry_kits_mono)
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# geometry_kit_widgets

Flutter widgets for [`geometry_kit`](../geometry_Kit) shapes — `CustomPainter`-backed, styled, and composable.

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

## Phase 1 widgets

| Widget               | Geometry        |
| -------------------- | --------------- |
| `GeoCircle`          | `Circle`        |
| `GeoEllipse`         | `Ellipse`       |
| `GeoRectangle`       | `Rectangle`     |
| `GeoTriangle`        | `Triangle`      |
| `GeoQuadrilateral`   | `Quadrilateral` |
| `GeoPolygon`         | `Polygon`       |
| `GeoLine`            | `Line`          |

Each widget exposes two constructors: a flat one (build geometry from primitives) and `.fromGeometry` (pass an existing geometry instance).

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

### Theming

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

Resolution order: explicit `style` → closest `ShapeStyleTheme` ancestor → default 1px black stroke.

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

## Other features

- `Semantics(label: ...)` baked into every widget for accessibility.
- `RepaintBoundary` wraps every `CustomPaint` to keep nearby state changes from forcing a full repaint.
- Dash patterns are drawn via shared `PathMetrics` helper — no extra dependency.

## See also

The `example/` app ships ten interactive demos covering every widget, theme overrides, dash patterns, coordinate mappers, multi-shape canvas, and clipping/layering.

```bash
cd example && flutter run
```

## Roadmap

- **Phase 2**: tap/hover interactivity, `GeoArc`, `GeoRing`, `GeoCapsule`, `GeoBezierCurve`, `GeoSpline`, `GeoPolyline`, `GeoRay`, `GeometryCanvas` hit-testing.
- **Phase 3**: drag, grid + axes overlay, debug parameters (`showBoundingBox`, `showCenter`, `showVertices`).
- **Phase 4**: tooltips, image export, dark mode presets.

---

[![GitHub](https://img.shields.io/badge/GitHub-samderlust/geometry__kits__mono-181717?logo=github)](https://github.com/samderlust/geometry_kits_mono)
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)
