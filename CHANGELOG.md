## 1.2.0-dev

- **fix:** `Point.translate()` now correctly translates instead of doubling input (variable shadowing bug)
- **fix:** `Circle.hasPoint()` inverted logic — now correctly returns `true` when point is inside
- **fix:** `Circle.scale()` now actually scales radius and center
- **fix:** `Line.getIntersectPoint()` checks both segment parameters, preventing false positives
- **fix:** `Line.slope` handles vertical lines (returns `infinity` instead of crashing)
- **fix:** `Polygon.getInnerCentroid()` corrected centroid formula using proper shoelace calculation
- **fix:** removed debug `print()` left in `Triangle.angles`

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
