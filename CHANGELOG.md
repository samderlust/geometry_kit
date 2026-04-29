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
- **chore:** removed unused `TransformationsMixin` dead code
- **chore:** established angle convention — transforms take degrees, `Line` angle methods return `Rad`
- **test:** added comprehensive test suite (164 tests) covering all classes

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
