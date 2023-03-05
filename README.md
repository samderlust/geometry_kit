[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# Geometry Kit

A set of utils that help with geometry (line, circle, triangle, polygon,...)

!!! Warning: Pre-release v1.0.0 contain breaking changes from previous version.

## Features

- distance from a point to a line
- check if to line segments intersect
- find intersect point of 2 line segments
- get area or perimeter of shapes,
- calculate circumcircle or incircle of a polygon
- check if a point is in side a polygon

## Installing the library:

Like any other package, add the library to your pubspec.yaml dependencies:

```
dependencies:
    geometry_kit: <latest_version>
```

Then import it wherever you want to use it:

```
import 'package:fetching_state/fetching_state.dart';
```

## Usage

```dart

  // Line
  final line1 = Line(Point(0, 2), Point(2, 0));
  final line2 = Line(Point(0, -1), Point(3, 2));

  final intersect = line1.intersect(line2);

  print(intersect); //Point(1.5, 0.5)
}

```

```dart
  //Polygon
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

I'm not a math guy, to be honest, I'm stupid at math your feedbacks and contributes will be much appreciated.

If you find anything need to be improve or want to request a feature. Please go ahead and create an issue in the [Github](https://github.com/samderlust/geometry_kit) repo
