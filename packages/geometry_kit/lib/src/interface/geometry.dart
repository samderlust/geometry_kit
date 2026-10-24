import 'shape.dart';

/// Any 2D geometry in this package: the closed [Shape]s and the open or
/// unbounded curves.
///
/// Implemented by [Shape] (and so by every closed shape) and by `Line`,
/// `Polyline`, `Arc`, `Ray`, `Ring`, `QuadraticBezier`, `CubicBezier` and
/// `Spline`.
///
/// It declares no members: curves don't share the [Shape] contract (a ray
/// has no area and an infinite length). It gives packages such as
/// `geometry_kit_widgets` one type to accept for "anything drawable" instead
/// of `Object`.
///
/// The interface is not `sealed`, so other packages can implement it for
/// their own geometry (e.g. `ArcSector` in `geometry_kit_widgets`). Code that
/// switches over geometry types should keep a fallback case.
abstract interface class Geometry {}
