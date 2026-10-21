# geometry_kits_mono

Dart monorepo using **native pub workspaces** (not Melos — `melos` is a dev dependency but there is no `melos.yaml`).

## Packages

| Package | Type | Path |
|---------|------|------|
| `geometry_kit` | Pure Dart library | `packages/geometry_kit/` |
| `geometry_kit_3d` | Pure Dart library (depends on `geometry_kit`) | `packages/geometry_kit_3d/` |
| `geometry_kit_widgets` | Flutter widgets | `packages/geometry_kit_widgets/` |
| `geometry_kit_editor` | Flutter editing layer (depends on `geometry_kit_widgets`) | `packages/geometry_kit_editor/` |
| Example app | Flutter | `packages/geometry_kit_widgets/example/` |

## Commands

Run commands from inside each package directory:

```bash
cd packages/geometry_kit        # pure Dart
cd packages/geometry_kit_3d     # pure Dart
cd packages/geometry_kit_widgets # Flutter
cd packages/geometry_kit_editor  # Flutter

dart pub get       # install deps (workspace-aware from root)
dart analyze       # lint
dart format .      # format

dart test          # run tests (geometry_kit: empty; geometry_kit_3d: 3 files; widgets: 2 files)
flutter test       # for Flutter packages
```

## SDK constraints

- Root: `^3.10.0`
- `geometry_kit`: `>=3.5.0 <4.0.0`
- `geometry_kit_3d`: `>=3.5.0 <4.0.0`
- `geometry_kit_widgets`, `geometry_kit_editor`: `^3.11.3` + Flutter `>=3.27.0`

## Architecture

- `geometry_kit` — immutable 2D shapes (`Point`, `Line`, `Circle`, `Triangle`, `Polygon`, `Rectangle`, `Ellipse`, `Quadrilateral`, `Arc`, `Ring`, `Capsule`, `Polyline`, `Ray`, `QuadraticBezier`, `CubicBezier`, `Spline`). All extend abstract `Shape`. Barrel: `lib/geometry_kit.dart`.
- `geometry_kit_3d` — immutable 3D solids (`Sphere`, `Box`, `Cylinder`, `Cone`, `Prism`, `SolidOfRevolution`) implementing `Solid`; math types (`Point3`, `Quaternion`, `Ray3`, `Plane`, `PlaneFrame`, `Aabb`), `Mesh` (OBJ/STL export), `OrbitCamera`, `Cone.slice` → sealed `CrossSection`. Right-handed, Y-up, degrees at the API. `Cylinder`/`Cone`/`SolidOfRevolution` share `RevolvedSolid` (exact queries from a 2D meridian polygon). Barrel: `lib/geometry_kit_3d.dart`.
- `geometry_kit_widgets` — `Geo*` widgets backed by `CustomPainter`, plus `GeoScene` (3D: `GeoSolid`, `GeoPath3`, `GeoLabel3`, `GeoHandle`; painter's-algorithm renderer in `lib/src/scene/`). `SceneViewport` does rays/projection/picking; `GeoScene.interaction` (`SceneInteraction`) gets pointers before the camera and can claim a gesture. Barrel: `lib/geometry_kit_widgets.dart`.
- `geometry_kit_editor` — mutable editing state on top of `GeoScene`: `Document` of `EditorNode`s (local-space `Solid` + `Transform3`), `EditorController` (selection, active `EditorTool`, snapshot undo/redo, `begin`/`preview`/`commit` transactions), `SelectTool`, `EditorScene`. Barrel: `lib/geometry_kit_editor.dart`.
- All shapes are immutable — transforms (`translate`, `scale`, `rotate`) return new instances.

## Tests

- `geometry_kit/test/` is **empty** — no tests written yet.
- `geometry_kit_3d/test/` — `math_test.dart`, `solids_test.dart` (every solid: mesh volume/area vs closed form, ray hits vs `contains`, closest point vs mesh), `bridge_test.dart` (cone slices, revolution, mesh export).
- `geometry_kit_widgets/test/geometry_kit_widgets_test.dart` — tests ShapeStyle, CoordinateMapper, DashPattern, GeoCircle, GeometryCanvas.
- `geometry_kit_widgets/test/geo_scene_test.dart` — SceneMesh creases, culling, GeoScene tap/orbit/drag, SceneViewport, interaction claims.
- `geometry_kit_editor/test/` — `editor_controller_test.dart` (Document, selection, history, transactions), `editor_scene_test.dart` (tap/shift/drag/keys through `EditorScene`).
- `geometry_kit_widgets/example/test/editor_demo_smoke_test.dart` — editor demo renders at phone and desktop width.

## Example apps

- `packages/geometry_kit/flutter_example/` — 17 demos using `CustomPainter` (not in workspace)
- `packages/geometry_kit_widgets/example/` — home has 2D and 3D tabs; 3D demos live in `lib/demos3d/` (each page = scene + controls + readouts + code; shared pieces in `_kit.dart`) (in workspace; iOS deployment target 15.0)

## Lint configs

- `geometry_kit`, `geometry_kit_3d`: `package:lints/recommended.yaml`
- `geometry_kit_widgets`: `package:flutter_lints/flutter.yaml`
