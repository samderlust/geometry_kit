# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dart package providing 2D geometry primitives and utilities: Point, Line, Circle, Triangle, Polygon, and angle conversion tools. Published as `geometry_kit` on pub.dev.

## Commands

```bash
dart pub get              # Install dependencies
dart test                 # Run all tests
dart test test/kit/line_test.dart  # Run single test file
dart analyze              # Static analysis (uses package:lints/recommended)
dart format .             # Format code
```

## Architecture

- **`lib/geometry_kit.dart`** — barrel export file, all public API surfaces here
- **`lib/src/interface/`** — base abstractions:
  - `Shape` (abstract class) — requires `area`, `perimeter`, `translate`, `scale`, `rotate`
  - `TransformationsMixin<T>` — generic mixin for transform operations with pivot support
- **`lib/src/kit/`** — geometry primitives:
  - `Point` — immutable 2D point with arithmetic operators (`+`, `-`, `*`, `/`, `%` for cross product)
  - `Line` — defined by two Points; provides slope, intercepts, intersection, angle calculation, distance-from-point
  - `Circle`, `Triangle`, `Polygon` — extend `Shape`; Triangle/Polygon delegate transforms to Point methods
  - `units.dart` — `Rad`/`Deg` typedefs (both `double`) with `.toDeg`/`.toRad` extensions
  - `angle_utils.dart` — static converter class for degree/radian/gradian/arc-minute/arc-second

## Key Patterns

- All geometry classes are immutable (final fields, transform methods return new instances)
- `Shape` subclasses must implement `area`, `perimeter`, and three transform methods
- Angles flow as radians internally; `Rad`/`Deg` typedefs clarify intent at API boundaries
- Point equality is value-based (custom `==` and `hashCode`)
- Line intersection uses parametric segment test (t ∈ [0,1]), returns `null` if no intersection
- Polygon `contains` uses ray-casting algorithm
