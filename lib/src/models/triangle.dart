import 'dart:math';

/// Triangle
class Triangle {
  final Point a;
  final Point b;
  final Point c;
  Triangle(
    this.a,
    this.b,
    this.c,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Triangle && other.a == a && other.b == b && other.c == c;
  }

  @override
  int get hashCode => a.hashCode ^ b.hashCode ^ c.hashCode;
}

extension TriangleExtension on Triangle {
  List<Point> get values => [a, b, c];
}
