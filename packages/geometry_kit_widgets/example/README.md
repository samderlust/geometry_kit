# geometry_kit_widgets — example

Showcase app for [`geometry_kit_widgets`](../).

## Run

```bash
flutter run
```

## Demos

| Screen              | Covers                                                        |
| ------------------- | ------------------------------------------------------------- |
| GeoCircle           | Stroked, filled, fill+stroke+opacity, dashed                  |
| GeoEllipse          | Wide, tall, dashed                                            |
| GeoRectangle        | Sharp, rounded, fill + stroke                                 |
| GeoTriangle         | Free-form, equilateral via `Triangle.equilateral`, dashed     |
| GeoQuadrilateral    | Trapezoid, rhombus, kite                                      |
| GeoPolygon          | Regular hexagon, pentagon, free-form                          |
| GeoLine             | Solid, diagonal, dashed, round caps                           |
| GeometryCanvas      | Mixed shapes, stacked transparency                            |
| ShapeStyleTheme     | Inherited default style with interactive color + dash toggle  |
| CoordinateMapper    | identity / yUp / centered                                     |
| Clipping & layering | `clipBehavior` (hardEdge vs none), Stack layering, transparent canvas |

Each demo lives in `lib/demos/`. Shared scaffolding in `lib/demos/_demo_card.dart`.
