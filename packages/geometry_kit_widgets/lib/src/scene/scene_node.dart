import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

import '../style/shape_style.dart';
import 'solid_gradient.dart';

/// Something a [GeoScene] can draw.
@immutable
sealed class SceneNode {
  const SceneNode();
}

/// A shaded 3D solid in a [GeoScene].
///
/// [ShapeStyle.fillColor] is the base colour, shaded by the scene light;
/// set [gradient] to colour the solid with a [SolidGradient] instead.
/// [ShapeStyle.opacity] below 1 makes the solid see-through.
/// [ShapeStyle.strokeColor] outlines the solid's sharp edges (box corners,
/// cylinder rims), not every triangle. [ShapeStyle.fillGradient],
/// [ShapeStyle.strokeGradient] and paint builders apply to flat 2D shapes
/// and [GeoPath3] only.
///
/// ```dart
/// GeoSolid(
///   Box.fromBase(center: Point3.zero, width: 1, depth: 1, height: 2),
///   style: const ShapeStyle(fillColor: Colors.indigo, strokeColor: Colors.black),
///   id: 'crate',
/// )
/// ```
class GeoSolid extends SceneNode {
  /// The geometry to draw, in local space when [transform] is set.
  final Solid solid;

  /// Placement of [solid] in the world. The mesh is cached for the local
  /// solid and moved at paint time, so animating or dragging the transform
  /// does not re-triangulate anything.
  final Transform3 transform;

  /// Fill, opacity and edge style.
  final ShapeStyle style;

  /// Colours the solid across its local bounds, in place of
  /// [ShapeStyle.fillColor]. [ShapeStyle.opacity] still applies.
  final SolidGradient? gradient;

  /// Slices around curved solids; more is smoother and slower.
  final int segments;

  /// Whether taps, hovers and drags can pick this solid.
  final bool pickable;

  /// Optional identifier, handy in pick callbacks.
  final String? id;

  /// Creates a scene solid.
  const GeoSolid(
    this.solid, {
    this.transform = Transform3.identity,
    this.style = const ShapeStyle.filled(Color(0xFF90A4AE)),
    this.gradient,
    this.segments = 32,
    this.pickable = true,
    this.id,
  });

  /// [solid] placed by [transform], for exact queries such as picking.
  Solid get worldSolid =>
      transform == Transform3.identity ? solid : transform.applyTo(solid);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoSolid &&
          other.solid == solid &&
          other.transform == transform &&
          other.style == style &&
          other.gradient == gradient &&
          other.segments == segments &&
          other.pickable == pickable &&
          other.id == id);

  @override
  int get hashCode =>
      Object.hash(solid, transform, style, gradient, segments, pickable, id);
}

/// A 3D polyline for guides, outlines and grids.
///
/// With [overlay] true (the default) the path is drawn after all solids, so
/// it is never hidden. With [overlay] false it is drawn before them, like a
/// floor grid that solids stand on.
class GeoPath3 extends SceneNode {
  /// Points of the path, in order.
  final List<Point3> points;

  /// Whether to join the last point back to the first.
  final bool closed;

  /// Stroke, fill (for closed paths) and dash style.
  final ShapeStyle style;

  /// Whether to draw on top of the solids (true) or underneath them.
  final bool overlay;

  /// Creates a 3D path.
  const GeoPath3(
    this.points, {
    this.closed = false,
    this.style = const ShapeStyle.stroked(Color(0xFF000000)),
    this.overlay = true,
  });

  /// Lines of a square grid on the horizontal plane `y = [y]`, from
  /// `-extent` to `+extent` on x and z, drawn underneath the solids.
  static List<GeoPath3> grid({
    double extent = 5,
    double step = 1,
    double y = 0,
    ShapeStyle style = const ShapeStyle.stroked(Color(0x33000000)),
  }) {
    final lines = <GeoPath3>[];
    final n = (extent / step).floor();
    for (var i = -n; i <= n; i++) {
      final v = i * step;
      lines
        ..add(
          GeoPath3(
            [Point3(v, y, -extent), Point3(v, y, extent)],
            style: style,
            overlay: false,
          ),
        )
        ..add(
          GeoPath3(
            [Point3(-extent, y, v), Point3(extent, y, v)],
            style: style,
            overlay: false,
          ),
        );
    }
    return lines;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPath3 &&
          other.closed == closed &&
          other.style == style &&
          other.overlay == overlay &&
          _pointsEqual(other.points, points));

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(points), closed, style, overlay);
}

/// Text pinned to a 3D position, drawn over the solids.
class GeoLabel3 extends SceneNode {
  /// World position of the label's anchor.
  final Point3 position;

  /// The text.
  final String text;

  /// Text style.
  final TextStyle style;

  /// Where the text sits relative to the anchor; centred by default.
  final Alignment alignment;

  /// Creates a 3D label.
  const GeoLabel3(
    this.position,
    this.text, {
    this.style = const TextStyle(fontSize: 11, color: Color(0xFF444444)),
    this.alignment = Alignment.center,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoLabel3 &&
          other.position == position &&
          other.text == text &&
          other.style == style &&
          other.alignment == alignment);

  @override
  int get hashCode => Object.hash(position, text, style, alignment);
}

/// Shape of a [GeoHandle] on screen.
enum HandleShape {
  /// A round dot.
  circle,

  /// An axis-aligned square.
  square,
}

/// A grab point pinned to a 3D position, drawn at a fixed size on screen
/// over everything else.
///
/// Editors use handles for resize corners, polygon vertices and gizmo
/// tips. Handles are picked on screen by [SceneViewport.pickHandle], within
/// [radius] plus a little slop, not by ray casting, so they stay easy to
/// grab at any zoom.
///
/// ```dart
/// GeoHandle(
///   const Point3(0.5, 1, 0.5),
///   id: 'corner-0',
///   style: const ShapeStyle(fillColor: Colors.white, strokeColor: Colors.blue),
/// )
/// ```
class GeoHandle extends SceneNode {
  /// World position of the handle's centre.
  final Point3 position;

  /// Identifier reported when the handle is picked.
  final String id;

  /// Half the handle's size in logical pixels.
  final double radius;

  /// Dot or square.
  final HandleShape shape;

  /// Fill and outline.
  final ShapeStyle style;

  /// Creates a handle.
  const GeoHandle(
    this.position, {
    required this.id,
    this.radius = 6,
    this.shape = HandleShape.circle,
    this.style = const ShapeStyle(
      fillColor: Color(0xFFFFFFFF),
      strokeColor: Color(0xFF2A56D6),
      strokeWidth: 1.5,
    ),
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoHandle &&
          other.position == position &&
          other.id == id &&
          other.radius == radius &&
          other.shape == shape &&
          other.style == style);

  @override
  int get hashCode => Object.hash(position, id, radius, shape, style);
}

/// Directional light for a [GeoScene], plus flat ambient fill.
@immutable
class DirectionalLight {
  /// Direction pointing towards the light, in world space.
  final Point3 direction;

  /// Brightness of surfaces facing away from the light (0–1).
  final double ambient;

  /// Extra brightness of surfaces facing the light head-on.
  final double intensity;

  /// Creates a light. The default comes from above, front-left.
  const DirectionalLight({
    this.direction = const Point3(-0.45, 0.8, 0.5),
    this.ambient = 0.45,
    this.intensity = 0.6,
  });

  @override
  bool operator ==(Object other) =>
      other is DirectionalLight &&
      other.direction == direction &&
      other.ambient == ambient &&
      other.intensity == intensity;

  @override
  int get hashCode => Object.hash(direction, ambient, intensity);
}

/// What a pick in a [GeoScene] landed on.
@immutable
class SceneHit {
  /// The scene node that was hit.
  final GeoSolid node;

  /// Distance, point and normal of the hit.
  final RayHit hit;

  /// Creates a pick result.
  const SceneHit(this.node, this.hit);

  @override
  String toString() => 'SceneHit(${node.id ?? node.solid.runtimeType}, $hit)';
}

bool _pointsEqual(List<Point3> a, List<Point3> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
