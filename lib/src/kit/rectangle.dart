import 'dart:math' as math;

import '../interface/shape.dart';
import 'circle.dart';
import 'line.dart';
import 'point.dart';
import 'polygon.dart';

/// An axis-aligned rectangle defined by position and size.
///
/// The rectangle is defined by [x], [y] (bottom-left corner),
/// [width], and [height].
class Rectangle implements Shape {
  /// X coordinate of the bottom-left corner
  final double x;

  /// Y coordinate of the bottom-left corner
  final double y;

  /// Width of the rectangle
  final double width;

  /// Height of the rectangle
  final double height;

  const Rectangle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Create a rectangle from two opposite corner points
  factory Rectangle.fromPoints(Point a, Point b) {
    final minX = math.min(a.x, b.x);
    final minY = math.min(a.y, b.y);
    final w = (a.x - b.x).abs();
    final h = (a.y - b.y).abs();
    return Rectangle(x: minX, y: minY, width: w, height: h);
  }

  /// Create a rectangle from center point, width, and height
  factory Rectangle.fromCenter({
    required Point center,
    required double width,
    required double height,
  }) {
    return Rectangle(
      x: center.x - width / 2,
      y: center.y - height / 2,
      width: width,
      height: height,
    );
  }

  /// Create a square from bottom-left corner and side length
  factory Rectangle.square({
    required double x,
    required double y,
    required double size,
  }) {
    return Rectangle(x: x, y: y, width: size, height: size);
  }

  /// Whether this rectangle is a square
  bool get isSquare => width == height;

  /// The center point of the rectangle
  Point get center => Point(x + width / 2, y + height / 2);

  /// Bottom-left corner
  Point get bottomLeft => Point(x, y);

  /// Bottom-right corner
  Point get bottomRight => Point(x + width, y);

  /// Top-left corner
  Point get topLeft => Point(x, y + height);

  /// Top-right corner
  Point get topRight => Point(x + width, y + height);

  /// The four corner points
  List<Point> get vertices => [bottomLeft, bottomRight, topRight, topLeft];

  /// The four edges of the rectangle
  List<Line> get edges => [
        Line(bottomLeft, bottomRight),
        Line(bottomRight, topRight),
        Line(topRight, topLeft),
        Line(topLeft, bottomLeft),
      ];

  /// Length of the diagonal
  double get diagonal => math.sqrt(width * width + height * height);

  /// Check if a point is inside this rectangle
  bool contains(Point point) {
    return point.x >= x &&
        point.x <= x + width &&
        point.y >= y &&
        point.y <= y + height;
  }

  /// Check if this rectangle overlaps with another rectangle
  bool overlaps(Rectangle other) {
    return x < other.x + other.width &&
        x + width > other.x &&
        y < other.y + other.height &&
        y + height > other.y;
  }

  /// Check if a line segment intersects this rectangle
  bool intersectsLine(Line line) {
    // If either endpoint inside, intersects
    if (contains(line.a) || contains(line.b)) return true;
    // Check against all 4 edges
    return edges.any((edge) => edge.intersect(line));
  }

  /// Check if a circle intersects this rectangle
  bool intersectsCircle(Circle circle) {
    // Clamp circle center to nearest point on rect
    final cx = circle.center.x.clamp(x, x + width);
    final cy = circle.center.y.clamp(y, y + height);
    final nearest = Point(cx, cy);
    return circle.center.distanceTo(nearest) <= circle.radius;
  }

  /// Convert this rectangle to a [Polygon]
  Polygon toPolygon() => Polygon(vertices);

  @override
  double get area => width * height;

  @override
  double get perimeter => 2 * (width + height);

  @override
  Rectangle rotate(double deg) {
    // Rotation breaks axis-alignment, so rotate all corners
    // and return the bounding rectangle of the result
    final c = center;
    final rotated = vertices.map((v) {
      final dx = v.x - c.x;
      final dy = v.y - c.y;
      final rad = deg * math.pi / 180;
      final nx = dx * math.cos(rad) - dy * math.sin(rad) + c.x;
      final ny = dx * math.sin(rad) + dy * math.cos(rad) + c.y;
      return Point(nx, ny);
    }).toList();

    final minX = rotated.map((p) => p.x).reduce(math.min);
    final minY = rotated.map((p) => p.y).reduce(math.min);
    final maxX = rotated.map((p) => p.x).reduce(math.max);
    final maxY = rotated.map((p) => p.y).reduce(math.max);

    return Rectangle(
      x: minX,
      y: minY,
      width: maxX - minX,
      height: maxY - minY,
    );
  }

  @override
  Rectangle scale(double value) {
    return Rectangle(
      x: x * value,
      y: y * value,
      width: width * value,
      height: height * value,
    );
  }

  @override
  Rectangle translate({double x = 0, double y = 0}) {
    return Rectangle(
      x: this.x + x,
      y: this.y + y,
      width: width,
      height: height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rectangle &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ width.hashCode ^ height.hashCode;

  @override
  String toString() =>
      'Rectangle(x: $x, y: $y, width: $width, height: $height)';
}
