# geometry_kit_widgets

Flutter widgets for [`geometry_kit`](../geometry_Kit) shapes — `CustomPainter`-backed, styled, and interactive.

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

## Theming

Wrap a subtree in `ShapeStyleTheme` to share defaults:

```dart
ShapeStyleTheme(
  data: const ShapeStyle.stroked(Colors.teal, width: 2),
  child: Column(children: [
    GeoCircle(radius: 30),       // teal stroke
    GeoTriangle(...),            // teal stroke
  ]),
)
```

## Multi-shape canvas

```dart
GeometryCanvas(
  size: const Size(400, 300),
  shapes: [
    StyledShape(
      Circle(center: Point(100, 100), radius: 50),
      style: ShapeStyle.filled(Colors.blue),
    ),
    StyledShape(
      Triangle(Point(200, 50), Point(300, 200), Point(150, 200)),
      style: const ShapeStyle.stroked(Colors.red, width: 2),
    ),
  ],
)
```

## Coordinate mapping

Default = Flutter native (top-left, Y-down). For math-convention Y-up:

```dart
GeoCircle(
  radius: 30,
  mapper: CoordinateMapper.yUp(const Size(200, 200)),
  size: const Size(200, 200),
)
```
