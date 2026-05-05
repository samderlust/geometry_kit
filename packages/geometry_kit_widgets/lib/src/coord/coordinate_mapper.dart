import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Maps geometry-space coordinates to/from canvas-space coordinates.
///
/// Flutter's canvas uses a top-left origin with the Y axis pointing down.
/// Geometry code often uses a bottom-left or centered origin with Y up.
/// A [CoordinateMapper] applies the translation and Y-axis flip needed to
/// reconcile the two.
///
/// The default ([CoordinateMapper.identity]) treats geometry coordinates as
/// canvas coordinates with no transformation.
///
/// ```dart
/// // Math convention: origin at bottom-left, Y up.
/// final mapper = CoordinateMapper.yUp(const Size(400, 300));
///
/// // Centered origin (great for symmetric scenes).
/// final mapper = CoordinateMapper.centered(const Size(400, 300));
/// ```
@immutable
class CoordinateMapper {
  /// Canvas-space location of the geometry origin (0, 0).
  final Offset origin;

  /// If true, geometry +Y points up (canvas +Y points down → flipped).
  final bool yUp;

  /// Creates a mapper with explicit [origin] and [yUp] flag.
  const CoordinateMapper({this.origin = Offset.zero, this.yUp = false});

  /// Identity mapper: geometry coords == canvas coords. Default.
  static const CoordinateMapper identity = CoordinateMapper();

  /// Math-convention mapper: origin at bottom-left of [size], Y up.
  factory CoordinateMapper.yUp(Size size) =>
      CoordinateMapper(origin: Offset(0, size.height), yUp: true);

  /// Centered mapper: origin at the center of [size]. Y is up by default.
  factory CoordinateMapper.centered(Size size, {bool yUp = true}) =>
      CoordinateMapper(
        origin: Offset(size.width / 2, size.height / 2),
        yUp: yUp,
      );

  /// Maps a geometry-space point to canvas space.
  Offset toCanvas(double gx, double gy) =>
      Offset(origin.dx + gx, origin.dy + (yUp ? -gy : gy));

  /// Maps a geometry-space [Offset] to canvas space.
  Offset offsetToCanvas(Offset geo) => toCanvas(geo.dx, geo.dy);

  /// Maps a canvas-space point back to geometry space.
  Offset fromCanvas(double cx, double cy) =>
      Offset(cx - origin.dx, (yUp ? -1 : 1) * (cy - origin.dy));

  /// Maps a canvas-space [Offset] to geometry space.
  Offset offsetFromCanvas(Offset canvas) =>
      fromCanvas(canvas.dx, canvas.dy);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoordinateMapper &&
          other.origin == origin &&
          other.yUp == yUp);

  @override
  int get hashCode => Object.hash(origin, yUp);
}
