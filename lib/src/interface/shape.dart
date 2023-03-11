abstract class Shape {
  const Shape();
  double get area;
  double get perimeter;

  /// translate the shape with [x] in horizontally and [y] vertically
  Shape translate({double x = 0, double y = 0});

  /// scale the shape by [value]
  Shape scale(double value);

  /// rotate the shape with x degrees
  Shape rotate(double deg);
}
