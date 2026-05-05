# geometry_kits_mono

Dart monorepo using **native pub workspaces** (not Melos — `melos` is a dev dependency but there is no `melos.yaml`).

## Packages

| Package | Type | Path |
|---------|------|------|
| `geometry_kit` | Pure Dart library | `packages/geometry_kit/` |
| `geometry_kit_widgets` | Flutter widgets | `packages/geometry_kit_widgets/` |
| Example app | Flutter | `packages/geometry_kit_widgets/example/` |

## Commands

Run commands from inside each package directory:

```bash
cd packages/geometry_kit        # pure Dart
cd packages/geometry_kit_widgets # Flutter

dart pub get       # install deps (workspace-aware from root)
dart analyze       # lint
dart format .      # format

dart test          # run tests (geometry_kit: empty; widgets: 1 file)
flutter test       # for Flutter packages
```

## SDK constraints

- Root: `^3.10.0`
- `geometry_kit`: `>=3.5.0 <4.0.0`
- `geometry_kit_widgets`: `^3.11.3` + Flutter `>=3.27.0`

## Architecture

- `geometry_kit` — immutable 2D shapes (`Point`, `Line`, `Circle`, `Triangle`, `Polygon`, `Rectangle`, `Ellipse`, `Quadrilateral`, `Arc`, `Ring`, `Capsule`, `Polyline`, `Ray`, `QuadraticBezier`, `CubicBezier`, `Spline`). All extend abstract `Shape`. Barrel: `lib/geometry_kit.dart`.
- `geometry_kit_widgets` — `Geo*` widgets backed by `CustomPainter`. Barrel: `lib/geometry_kit_widgets.dart`.
- All shapes are immutable — transforms (`translate`, `scale`, `rotate`) return new instances.

## Tests

- `geometry_kit/test/` is **empty** — no tests written yet.
- `geometry_kit_widgets/test/geometry_kit_widgets_test.dart` — tests ShapeStyle, CoordinateMapper, DashPattern, GeoCircle, GeometryCanvas.

## Example apps

- `packages/geometry_kit/flutter_example/` — 17 demos using `CustomPainter` (not in workspace)
- `packages/geometry_kit_widgets/example/` — 10 widget demos (in workspace)

## Lint configs

- `geometry_kit`: `package:lints/recommended.yaml`
- `geometry_kit_widgets`: `package:flutter_lints/flutter.yaml`
