[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# Geometry Kit

A set of utils that help with geometry (line, circle, triangle, polygon,...)

## Features

- **Point** — distance, translation, rotation, scaling, arithmetic operators (`+`, `-`, `*`, `/`)
- **Line** — slope, intercepts, intersection detection, angle between lines, distance from a point
- **Circle** — area, perimeter, point containment, scaling, translation
- **Triangle** — area, perimeter, angles, height, baseline, orthocenter, rotation, scaling, translation
- **Polygon** — area, perimeter, point containment (ray-casting), bounding box, circumcircle, incircle, centroid, closest/furthest vertex
- **Angle utilities** — degree/radian/gradian/arc-minute/arc-second conversions

## Installing the library:

Like any other package, add the library to your pubspec.yaml dependencies:

```
dependencies:
    geometry_kit: <latest_version>
```

Then import it wherever you want to use it:

```dart
import 'package:geometry_kit/geometry_kit.dart';
```

## Usage

```dart
// Line intersection
final line1 = Line(Point(0, 2), Point(2, 0));
final line2 = Line(Point(0, -1), Point(3, 2));

final intersect = line1.intersect(line2);
print(intersect); // true

final point = line1.getIntersectPoint(line2);
print(point); // Point(x: 1.5, y: 0.5)
```

```dart
// Polygon containment
final polygon = Polygon([
    Point(1, 0),
    Point(0, 2),
    Point(0, 3),
    Point(2, 5),
    Point(3, 5),
    Point(5, 3),
    Point(5, 1),
    Point(3, 0),
  ]);

  final point1 = Point(5, 2);
  var isInside = polygon.contains(point1);
  print(isInside); // true

  final point2 = Point(9, 2);
  isInside = polygon.contains(point2);
  print(isInside); //false
```

## Appreciate Your Feedbacks and Contributes

I'm not a math guy, to be honest, I'm stupid at math, your feedbacks and contributes will be much appreciated.

If you find anything need to be improve or want to request a feature. Please go ahead and create an issue in the [Github](https://github.com/samderlust/geometry_kit) repo
