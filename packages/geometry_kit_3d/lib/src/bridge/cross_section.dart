import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';

import '../math/plane.dart';
import '../math/point3.dart';
import '../mesh/triangulate.dart';

/// The flat region where a plane cuts a solid.
///
/// Coordinates are 2D geometry_kit shapes in [frame], a coordinate system
/// lying in the cutting plane. Use [toPolygon] to keep working in 2D, or
/// [toPoints3] to draw the outline back in 3D.
///
/// ```dart
/// final label = switch (cone.slice(plane)) {
///   CircleSection(:final circle) => 'Circle r=${circle.radius}',
///   EllipseSection(:final ellipse) => 'Ellipse ${ellipse.radiusX}×${ellipse.radiusY}',
///   ParabolaSection() => 'Parabola',
///   HyperbolaSection() => 'Hyperbola',
///   EmptySection() => 'No intersection',
/// };
/// ```
sealed class CrossSection {
  /// 2D coordinate system in the cutting plane.
  final PlaneFrame frame;

  const CrossSection(this.frame);

  /// Closed outline in [frame] coordinates, counter-clockwise. Empty for
  /// [EmptySection].
  List<Point> get outline;

  /// Area of the section.
  double get area => outline.length < 3 ? 0 : signedArea2d(outline).abs();

  /// Whether the plane missed the solid.
  bool get isEmpty => outline.length < 3;

  /// The outline as a geometry_kit [Polygon].
  ///
  /// Throws [StateError] for an empty section.
  Polygon toPolygon() {
    if (isEmpty) throw StateError('Empty cross-section has no polygon.');
    return Polygon(outline);
  }

  /// The outline mapped back into world space.
  List<Point3> toPoints3() => [for (final p in outline) frame.toWorld(p)];
}

/// The plane does not cut the solid.
final class EmptySection extends CrossSection {
  /// Creates an empty section.
  const EmptySection(super.frame);

  @override
  List<Point> get outline => const [];
}

/// A circular section, such as a plane perpendicular to a cone's axis.
final class CircleSection extends CrossSection {
  /// The circle in [frame] coordinates.
  final Circle circle;

  /// Number of outline points.
  final int samples;

  /// Creates a circular section.
  const CircleSection(super.frame, this.circle, {this.samples = 128});

  @override
  double get area => pi * circle.radius * circle.radius;

  @override
  List<Point> get outline => [
        for (var i = 0; i < samples; i++)
          Point(
            circle.center.x + circle.radius * cos(2 * pi * i / samples),
            circle.center.y + circle.radius * sin(2 * pi * i / samples),
          ),
      ];
}

/// An elliptical section. Its major axis lies along the frame's x axis.
///
/// When [clipped] is true the ellipse runs past the solid (for example
/// through a cone's base), so the section is the part of [ellipse] inside
/// the solid and [outline] follows that cut.
final class EllipseSection extends CrossSection {
  /// The full ellipse of the cut in [frame] coordinates.
  final Ellipse ellipse;

  /// Whether the solid cuts off part of [ellipse].
  final bool clipped;

  /// Number of outline points for an unclipped ellipse.
  final int samples;

  final List<Point>? _clippedOutline;

  /// Creates an elliptical section.
  const EllipseSection(
    super.frame,
    this.ellipse, {
    this.clipped = false,
    this.samples = 128,
    List<Point>? clippedOutline,
  }) : _clippedOutline = clippedOutline;

  @override
  double get area =>
      clipped ? super.area : pi * ellipse.radiusX * ellipse.radiusY;

  @override
  List<Point> get outline =>
      _clippedOutline ??
      [
        for (var i = 0; i < samples; i++) ellipse.pointAt(2 * pi * i / samples),
      ];
}

/// A parabolic section, closed by a straight cut (such as a cone's base).
final class ParabolaSection extends CrossSection {
  @override
  final List<Point> outline;

  /// Creates a parabolic section from its sampled outline.
  const ParabolaSection(super.frame, this.outline);
}

/// A hyperbolic section, closed by a straight cut (such as a cone's base).
final class HyperbolaSection extends CrossSection {
  @override
  final List<Point> outline;

  /// Creates a hyperbolic section from its sampled outline.
  const HyperbolaSection(super.frame, this.outline);
}
