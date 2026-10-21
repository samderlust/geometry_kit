# Contributing to geometry_kit

Thanks for helping. This guide covers how the repository is organized and the conventions it follows. For what each package does from a user's point of view, see its README.

## Setup

This is a Dart pub workspace (no Melos config). One `pub get` at the root resolves every package against the local copies of the others:

```bash
dart pub get
```

Then work inside a package:

```bash
cd packages/geometry_kit_3d      # pure Dart
dart analyze
dart test

cd packages/geometry_kit_widgets # Flutter (same for geometry_kit_editor)
flutter analyze
flutter test
```

`packages/geometry_kit/test/` is empty for now, so `dart test` there has nothing to run.

The example app in `packages/geometry_kit_widgets/example/` has 2D and 3D tabs and depends on every package by path:

```bash
cd packages/geometry_kit_widgets/example
flutter test        # smoke tests
flutter run
```

`packages/geometry_kit/flutter_example/` is an older `CustomPainter` showcase that is not part of the workspace.

## How the packages fit together

```
geometry_kit            pure Dart, immutable 2D shapes
  ↑
geometry_kit_3d         pure Dart, immutable 3D solids, math, meshes, camera
  ↑                     (prisms, revolutions and cross-sections use 2D shapes)
geometry_kit_widgets    Flutter: Geo* widgets, GeometryCanvas, GeoScene (3D)
  ↑
geometry_kit_editor     Flutter: selection, tools, undo on top of GeoScene
```

Each layer only depends on the ones below it. Geometry stays neutral and immutable; mutable app state (controllers, selection, history) lives in the editor.

A `GeoScene` frame and a pointer event go through these steps:

```
GeoScene build
  → ScenePainter.paint
    → SceneMeshCache.meshFor(node)          # local solid → SceneMesh, cached by value
    → GeoSolid.transform places the mesh    # no re-triangulation when it moves
    → cull, shade, sort back to front       # painter's algorithm, one drawVertices
    → GeoPath3 / GeoLabel3 / GeoHandle on top

pointer down
  → _ClaimRecognizer → SceneInteraction.onPointerDown(ScenePointer)
    → true:  gesture is claimed, wins the arena; moves/up go to that interaction only
    → false: ScaleGestureRecognizer orbits / zooms, TapGestureRecognizer → onTap
```

In the editor, `EditorScene` installs a `SceneInteraction` that forwards each gesture to the `EditorTool` that claimed it. Tools change the document through `EditorController`: `begin` → `preview`* → `commit` / `cancel`, so one drag is one undo step.

## Code layout

| Package | Folder | Contents |
| --- | --- | --- |
| `geometry_kit` | `lib/src/interface/` | `Shape`, the base of every 2D shape |
| | `lib/src/kit/` | `Point`, `Line`, `Circle`, `Polygon`, `Spline` and the other 2D shapes |
| `geometry_kit_3d` | `lib/src/math/` | `Point3`, `Quaternion`, `Transform3`, `Ray3`, `Segment3`, `Plane`, `Aabb` |
| | `lib/src/solid/` | `Solid` interface, `Sphere`, `Box`, `Cylinder`, `Cone`, `RevolvedSolid` |
| | `lib/src/bridge/` | `Prism`, `SolidOfRevolution`, `CrossSection` (the 2D ↔ 3D bridges) |
| | `lib/src/mesh/`, `lib/src/camera/` | `Mesh` (OBJ/STL export), triangulation, `OrbitCamera` |
| `geometry_kit_widgets` | `lib/src/widgets/`, `painters/` | `Geo*` widgets and their `CustomPainter`s |
| | `lib/src/style/`, `coord/`, `canvas/` | `ShapeStyle` + theme, `CoordinateMapper`, `GeometryCanvas` |
| | `lib/src/scene/` | `GeoScene`, scene nodes, `ScenePainter`, `SceneViewport`, `SceneInteraction` |
| `geometry_kit_editor` | `lib/src/` | `Document`, `EditorController`, `EditorScene`, `tools/` |

Each package exports its public API from one barrel file, `lib/<package>.dart`. Anything not exported there is private to the package.

## Conventions for geometry

- Shapes and solids are immutable. Transforms (`translate`, `scale`, `rotate`) return new instances.
- 3D is right-handed with Y up. Angles at the API are degrees; radians only inside.
- Value types implement `==` and `hashCode`. The mesh cache and `shouldRepaint` rely on value equality, so a solid rebuilt in `build()` must compare equal to the old one.
- Queries that can miss return `null` (`intersectRay`, `onPlane`, `project`), never throw.
- New solids implement every `Solid` member and get the standard checks in `solids_test.dart`: mesh volume and area against the closed form, ray hits against `contains`, closest point against the mesh.

## Coding conventions

- PascalCase for classes, camelCase for variables and functions, snake_case for file names
- Declare explicit types on public API; avoid `dynamic`
- Every public member has a `///` doc comment; add a short example for entry points
- Keep functions short with a single purpose; use early returns to avoid deep nesting
- Prefer composition over inheritance
- Tests follow Arrange-Act-Assert; widget behaviour goes through `testWidgets`, not just the controller
- Format with `dart format` at the default page width
- `dart doc` runs with 0 warnings: wrap literal brackets in backticks, since `[x]` is a doc link

Lints: `package:lints/recommended.yaml` for the pure Dart packages, `package:flutter_lints/flutter.yaml` for the Flutter ones.

## Versions and releases

Packages version independently. Bump a package when its published code changes, and update its `CHANGELOG.md`. When a package raises its own version, also raise the constraint in the packages that depend on it (for example `geometry_kit_editor` on `geometry_kit_widgets`).

Publish in dependency order, after a clean dry run:

```bash
dart pub publish --dry-run
```

`geometry_kit` → `geometry_kit_3d` → `geometry_kit_widgets` → `geometry_kit_editor`.

API docs are generated with `dart doc` into each package's `doc/api/`.

README images live in each package's `screenshots/` folder and are listed under `screenshots:` in its `pubspec.yaml`. They are drawn by a render script, not captured by hand, so regenerate them whenever rendering changes:

```bash
cd packages/geometry_kit_widgets/example
flutter test tool/readme_images_test.dart
```

The READMEs load them from `raw.githubusercontent.com/.../main/`, so new or changed images show on GitHub and pub.dev once they reach `main`.

## Pull requests

- `dart analyze` / `flutter analyze` and the tests pass in every package you touched, and `flutter test` passes in the example app
- New behaviour has tests; bug fixes come with a test that fails without the fix
- User-visible changes get a line in the package's `CHANGELOG.md`, and the README if usage changes
- New public API is exported from the barrel file and documented
