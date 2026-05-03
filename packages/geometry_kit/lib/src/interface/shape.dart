/// Base interface for all 2D geometric shapes.
///
/// All shapes must provide [area], [perimeter], and transform methods
/// ([translate], [scale], [rotate]). Transform methods return new instances
/// (shapes are immutable).
abstract interface class Shape {
  /// Area of this shape.
  double get area;

  /// Perimeter (circumference) of this shape.
  double get perimeter;

  /// translate the shape with [x] in horizontally and [y] vertically
  Shape translate({double x = 0, double y = 0});

  /// scale the shape by [value]
  Shape scale(double value);

  /// Rotate the shape by [deg] degrees
  Shape rotate(double deg);
}
