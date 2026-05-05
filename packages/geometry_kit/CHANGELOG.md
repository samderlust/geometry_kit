## 1.2.2

- update git hub info

## 1.2.1

- **fix:** `Line` — tightened NaN checks across slope/intercept calculations
- **refactor:** `Quadrilateral` and `Triangle` — clearer getter names for sides and special points
- **docs:** expanded dartdoc on `Circle`, `Line`, `Point`, `Polygon`, `Quadrilateral`, `Ring`, `Triangle`, and `units`
- **chore:** moved package into `geometry_kits_mono` monorepo alongside new `geometry_kit_widgets`

## 1.2.0

### New Classes

- **feat:** added `Rectangle` class with AABB constructors (`fromPoints`, `fromCenter`, `square`), containment, overlap detection, diagonal, corners, `intersectsLine()`, `intersectsCircle()`
- **feat:** added `Ellipse` class with dual radii, area, perimeter (Ramanujan approximation), containment, eccentricity, foci
- **feat:** added `Ray` class with origin/direction, `pointAt`, intersection with `Line` and `Circle`
- **feat:** added `Arc` class with arc length, sector area, start/end/mid points, parametric sampling, `fromDegrees` factory
- **feat:** added `Quadrilateral` class with classification checks (`isParallelogram`, `isRhombus`, `isTrapezoid`, `isKite`, `isRectangle`, `isSquare`, `isConvex`), diagonals, center, containment
- **feat:** added `Ring` class (annulus) with `innerRadius`, `outerRadius`, `width`, circumferences, containment
- **feat:** added `Capsule` class (stadium shape) with `medialAxis`, `radius`, `boundingBox`, `endCaps`, `fromRect()` and `circle()` factories, containment
- **feat:** added `Polyline` class (open path) with `length`, `segments`, `boundingBox`, parametric `pointAt()`, `simplify()` (Ramer-Douglas-Peucker)
- **feat:** added `Bezier` class (quadratic Bezier curve) with parametric `pointAt()`, `split()`, `boundingBox`, `length`
- **feat:** added `Spline` class (Catmull-Rom) with `sample()`, `tangentAt()`, `toPolyline()`, `approximateLength()`
- **feat:** added `Segment` type alias for `Line`

### New Methods on Existing Classes

- **feat:** `Point` — added `angleTo()`, `dot()`, `magnitude`, `normalized`, `midPointTo()`
- **feat:** `Line` — added `isVertical`, `isHorizontal`, `isParallelTo()`, `isPerpendicularTo()`, `translate()`, `scale()`, `rotate()`
- **feat:** `Triangle` — added `isScalene`, `centroid`, `circumcenter`, `incenter`, `contains()`
- **feat:** `Polygon` — added `centroid`, `isConvex`, `intersectsLine()`, `intersectsCircle()`, `regular()` factory
- **feat:** `Circle` — added `contains()`, `distanceTo()`, `intersectsLine()`, `intersectsCircle()`

### Bug Fixes

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

### Breaking Changes

- **refactor:** `Shape` subclasses now use `implements Shape` instead of `extends Shape`
- **feat:** `Polygon` transform methods now return `Polygon` instead of `Shape` (covariant return types)
- **feat:** exported `Shape` abstract class for consumers to extend

### Maintenance

- **chore:** deprecated `AngleUtils` in favor of `Rad`/`Deg` extensions from `units.dart`
- **chore:** removed unused `TransformationsMixin` dead code
- **chore:** established angle convention — transforms take degrees, `Line` angle methods return `Rad`
- **test:** comprehensive test suite covering all classes

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
