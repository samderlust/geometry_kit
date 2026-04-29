[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# Geometry Kit

A set of utils that help with geometry (line, circle, triangle, polygon,...)

## Features

- **Point** — distance, translation, rotation, scaling, arithmetic operators (`+`, `-`, `*`, `/`)
- **Line** — slope, intercepts, intersection detection, angle between lines, distance from a point, transforms
- **Ray** — origin + direction, point along ray, intersection with Line and Circle
- **Arc** — center/radius/angles, arc length, sector area, start/end/mid points, parametric sampling
- **Circle** — area, perimeter, point containment, scaling, translation
- **Ellipse** — dual radii, area, perimeter (Ramanujan), containment, eccentricity, foci
- **Rectangle** — area, perimeter, containment, overlap detection, diagonal, corners, AABB constructors
- **Triangle** — area, perimeter, angles, height, baseline, orthocenter, rotation, scaling, translation
- **Polygon** — area, perimeter, point containment (ray-casting), bounding box, circumcircle, incircle, centroid, regular polygon factory
- **Angle utilities** — `Rad`/`Deg` extensions (`.toRad`, `.toDeg`), degree/radian/gradian conversions

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

```dart
// Rectangle
final rect = Rectangle(x: 0, y: 0, width: 10, height: 5);
print(rect.area); // 50.0
print(rect.contains(Point(3, 2))); // true
print(rect.diagonal); // ~11.18

// Or use convenience constructors
final square = Rectangle.square(x: 0, y: 0, size: 4);
final centered = Rectangle.fromCenter(center: Point(5, 5), width: 10, height: 6);
```

```dart
// Ellipse
final ellipse = Ellipse(center: Point(0, 0), radiusX: 5, radiusY: 3);
print(ellipse.area); // ~47.12
print(ellipse.contains(Point(2, 1))); // true
print(ellipse.foci); // two focal points
```

```dart
// Ray — raycasting
final ray = Ray(Point(0, 0), Point(1, 0)); // rightward ray
final wall = Line(Point(5, -3), Point(5, 3));
final hit = ray.intersectsLine(wall);
print(hit); // Point(x: 5.0, y: 0.0)
```

```dart
// Arc
final arc = Arc.fromDegrees(
  center: Point(0, 0), radius: 10, startDeg: 0, endDeg: 90,
);
print(arc.length); // quarter circumference
print(arc.startPoint); // Point(x: 10.0, y: 0.0)
print(arc.sectorArea); // area of pie slice
```

```dart
// Regular Polygon
final hexagon = Polygon.regular(sides: 6, radius: 5, center: Point(0, 0));
print(hexagon.vertices.length); // 6
print(hexagon.area); // ~64.95
```

## Appreciate Your Feedbacks and Contributes

I'm not a math guy, to be honest, I'm stupid at math, your feedbacks and contributes will be much appreciated.

If you find anything need to be improve or want to request a feature. Please go ahead and create an issue in the [Github](https://github.com/samderlust/geometry_kit) repo
