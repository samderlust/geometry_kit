import 'package:flutter/foundation.dart';
import 'package:geometry_kit/geometry_kit.dart';

/// The pie slice bounded by an [Arc] and the two radii to its endpoints.
///
/// `geometry_kit` models an [Arc] as an open curve. Wrap one in
/// [ArcSector] to paint (or hit-test) the closed sector instead — e.g. in a
/// `GeometryCanvas`:
///
/// ```dart
/// StyledShape(
///   ArcSector(Arc.fromDegrees(
///     center: Point(100, 100), radius: 60, startDeg: 0, endDeg: 90,
///   )),
///   style: const ShapeStyle.filled(Colors.orange),
/// )
/// ```
///
/// `GeoArc(sector: true)` does the same for a single widget.
@immutable
class ArcSector {
  /// The arc forming the curved edge of the sector.
  final Arc arc;

  /// Creates the sector bounded by [arc].
  const ArcSector(this.arc);

  /// Area of the sector.
  double get area => arc.sectorArea;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ArcSector && other.arc == arc);

  @override
  int get hashCode => arc.hashCode;

  @override
  String toString() => 'ArcSector($arc)';
}
