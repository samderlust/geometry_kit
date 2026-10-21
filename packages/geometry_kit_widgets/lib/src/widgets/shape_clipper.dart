import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../util/shape_path.dart';

/// A [CustomClipper] that clips its host widget to the outline of a
/// [geo.Shape].
///
/// Use directly with [ClipPath] to clip any subtree to a geometry shape:
///
/// ```dart
/// ClipPath(
///   clipper: const ShapeClipper(
///     shape: Circle(center: Point(50, 50), radius: 50),
///   ),
///   child: Image.asset('earth.png'),
/// )
/// ```
///
/// Path generation matches what painters use internally — see
/// [shapeToPath]. [geo.Line] produces an open two-vertex path, which is
/// degenerate for clipping; consumers can detect this via the path's zero
/// area and avoid wrapping a `Line` shape with a clipper.
class ShapeClipper extends CustomClipper<Path> {
  /// The geometric shape whose outline is used as the clip path.
  final geo.Shape shape;

  /// Mapper from geometry coordinates to canvas coordinates. Defaults to
  /// [CoordinateMapper.identity] — geometry coords match canvas coords 1:1.
  final CoordinateMapper mapper;

  /// Creates a clipper for [shape].
  const ShapeClipper({
    required this.shape,
    this.mapper = CoordinateMapper.identity,
  });

  @override
  Path getClip(Size size) => shapeToPath(shape, mapper);

  @override
  bool shouldReclip(covariant ShapeClipper old) =>
      old.shape != shape || old.mapper != mapper;
}
