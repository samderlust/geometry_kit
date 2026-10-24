import 'shape.dart';

/// Any 2D geometry in this package: the closed [Shape]s and the open or
/// unbounded curves.
///
/// Implemented by [Shape] (and so by every closed shape) and by `Line`,
/// `Polyline`, `Arc`, `Ray`, `Ring`, `QuadraticBezier`, `CubicBezier` and
/// `Spline`.
///
/// The only member is [translate], the one operation every type supports.
/// The rest of the [Shape] contract doesn't fit curves (a ray has no area
/// and an infinite length), so it stays on [Shape]. This gives packages such
/// as `geometry_kit_widgets` one type to accept for "anything drawable"
/// instead of `Object`, and lets them move any geometry without a type
/// switch.
///
/// The interface is not `sealed`, so other packages can implement it for
/// their own geometry (e.g. `ArcSector` in `geometry_kit_widgets`). Code that
/// switches over geometry types should keep a fallback case.
abstract interface class Geometry {
  /// Returns a copy moved by [x] horizontally and [y] vertically.
  ///
  /// Every implementation narrows the return type to its own class, so
  /// `circle.translate(x: 1)` is still a `Circle`.
  Geometry translate({double x = 0, double y = 0});
}
