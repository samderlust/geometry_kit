## 1.2.0-dev

- **fix:** `Point.translate()` now correctly translates instead of doubling input (variable shadowing bug)
- **fix:** `Circle.hasPoint()` inverted logic — now correctly returns `true` when point is inside; added type annotation
- **fix:** `Circle.scale()` now actually scales radius and center
- **fix:** `Line.getIntersectPoint()` checks both segment parameters, preventing false positives
- **fix:** `Line.slope` handles vertical lines (returns `infinity` instead of crashing)
- **fix:** `Line.yIntercept` returns `NaN` for vertical lines instead of crashing
- **fix:** `Line.xIntercept` returns `NaN` for horizontal lines instead of crashing
- **fix:** `Line.hasPoint()` uses epsilon-based comparison instead of exact float equality
- **fix:** `Triangle.orthocenter` rewritten with vector-based formula — no longer crashes on vertical/horizontal sides
- **fix:** `Polygon.getInnerCentroid()` corrected centroid formula using proper shoelace calculation
- **fix:** `Polygon.area` now always returns positive value (`.abs()` applied)
- **fix:** `AngleUtils.minOfArcToRadian()` corrected formula (was multiplying instead of dividing)
- **fix:** removed debug `print()` left in `Triangle.angles`
- **feat:** added `Rectangle` class with AABB constructors (`fromPoints`, `fromCenter`, `square`), containment, overlap detection, diagonal, corners
- **feat:** added `Ellipse` class with dual radii, area, perimeter (Ramanujan approximation), containment, eccentricity, foci
- **feat:** added `Ray` class with origin/direction, `pointAt`, intersection with `Line` and `Circle`
- **feat:** added `Arc` class with arc length, sector area, start/end/mid points, parametric sampling, `fromDegrees` factory
- **feat:** added `Polygon.regular()` factory constructor for regular polygons (hexagons, pentagons, etc.)
- **feat:** added `translate`, `scale`, `rotate` to `Line`
- **feat:** exported `Shape` abstract class for consumers to extend
- **feat:** `Polygon` transform methods now return `Polygon` instead of `Shape` (covariant return types)
- **chore:** deprecated `AngleUtils` in favor of `Rad`/`Deg` extensions from `units.dart`
- **chore:** removed unused `TransformationsMixin` dead code
- **chore:** established angle convention — transforms take degrees, `Line` angle methods return `Rad`
- **test:** comprehensive test suite (278 tests) covering all classes

## 1.1.0-dev

- add `translate`,`scale`, `rotate` to [Shape]

## 1.0.0-dev (breaking change)

- rewrite package with new models

## 0.1.1

- Add angle utils.
- Line Utils
  - add calculating angle between 2 lines

## 0.1.0

- Initial version.
