import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

/// A point in a solid's local bounding box, like [Alignment] in 3D.
///
/// Each axis runs from -1 to 1 across the box: `x` from left to right,
/// `y` from bottom to top, `z` from back to front. `Anchor3(0, 0, 0)` is the
/// centre of the box; values outside [-1, 1] lie outside it.
///
/// Anchors are relative to the solid's *local* bounds, so a gradient set
/// with them turns and scales with the solid's transform.
@immutable
class Anchor3 {
  /// Left (-1) to right (1).
  final double x;

  /// Bottom (-1) to top (1).
  final double y;

  /// Back (-1) to front (1).
  final double z;

  /// Creates an anchor.
  const Anchor3(this.x, this.y, this.z);

  /// Centre of the box.
  static const center = Anchor3(0, 0, 0);

  /// Centre of the top face.
  static const top = Anchor3(0, 1, 0);

  /// Centre of the bottom face.
  static const bottom = Anchor3(0, -1, 0);

  /// Centre of the left face.
  static const left = Anchor3(-1, 0, 0);

  /// Centre of the right face.
  static const right = Anchor3(1, 0, 0);

  /// Centre of the front face.
  static const front = Anchor3(0, 0, 1);

  /// Centre of the back face.
  static const back = Anchor3(0, 0, -1);

  /// Top, left, front corner.
  static const topLeftFront = Anchor3(-1, 1, 1);

  /// Bottom, right, back corner.
  static const bottomRightBack = Anchor3(1, -1, -1);

  /// The anchor mirrored through the centre.
  Anchor3 operator -() => Anchor3(-x, -y, -z);

  /// The point this anchor names in [bounds].
  Point3 resolve(Aabb bounds) {
    final lo = bounds.min, hi = bounds.max;
    return Point3(
      lo.x + (x + 1) / 2 * (hi.x - lo.x),
      lo.y + (y + 1) / 2 * (hi.y - lo.y),
      lo.z + (z + 1) / 2 * (hi.z - lo.z),
    );
  }

  /// Where [p] sits in [bounds], in anchor units. Flat axes map to 0.
  static Anchor3 of(Point3 p, Aabb bounds) {
    double axis(double v, double lo, double hi) =>
        hi - lo == 0 ? 0 : (v - lo) / (hi - lo) * 2 - 1;
    final lo = bounds.min, hi = bounds.max;
    return Anchor3(
      axis(p.x, lo.x, hi.x),
      axis(p.y, lo.y, hi.y),
      axis(p.z, lo.z, hi.z),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Anchor3 && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'Anchor3($x, $y, $z)';
}

/// A colour gradient across a 3D solid.
///
/// The colour is worked out at each mesh vertex from its position in the
/// solid's local bounding box, then shaded by the scene light. It is fixed
/// to the solid: moving, turning or scaling the solid carries it along.
///
/// ```dart
/// GeoSolid(
///   Box.cube(center: Point3.zero, size: 1),
///   gradient: const SolidGradient.linear(
///     start: Anchor3.top,
///     end: Anchor3.bottom,
///     colors: [Colors.indigo, Colors.orange],
///   ),
/// )
/// ```
@immutable
sealed class SolidGradient {
  /// Colours along the gradient. At least two.
  final List<Color> colors;

  /// Positions of [colors] from 0 to 1, ascending. When null the colours
  /// are spread evenly.
  final List<double>? stops;

  const SolidGradient._(this.colors, this.stops);

  /// A gradient along the line from [start] to [end].
  ///
  /// Points level with [start] get the first colour, points level with
  /// [end] the last. Points beyond either end keep the end colour.
  const factory SolidGradient.linear({
    Anchor3 start,
    Anchor3 end,
    required List<Color> colors,
    List<double>? stops,
  }) = LinearSolidGradient;

  /// A gradient outward from [center]; the last colour is reached at
  /// [radius], in anchor units (1 reaches the face centres from the middle
  /// of a cube-shaped box). Leave [radius] out to reach right across the
  /// solid; see [RadialSolidGradient.effectiveRadius].
  ///
  /// [center] defaults to the top of the box. A centre in the middle
  /// of a sphere colours it evenly, since every surface point is the same
  /// distance away; put the centre on or near the surface instead.
  const factory SolidGradient.radial({
    Anchor3 center,
    double? radius,
    required List<Color> colors,
    List<double>? stops,
  }) = RadialSolidGradient;

  /// Position along the gradient, 0 to 1, of local point [p] on a solid
  /// with local [bounds].
  double t(Point3 p, Aabb bounds);

  /// The same gradient running the other way: a linear one swaps [start]
  /// and [end], a radial one runs its colours from the rim inward.
  SolidGradient get reversed;

  /// Colour at position [t] (clamped to 0..1).
  Color colorAt(double t) {
    assert(colors.length >= 2, 'A SolidGradient needs at least two colours');
    assert(stops == null || stops!.length == colors.length);
    final s = stops;
    final n = colors.length;
    double stop(int i) => s == null ? i / (n - 1) : s[i];
    t = t.clamp(0.0, 1.0);
    if (t <= stop(0)) return colors.first;
    for (var i = 1; i < n; i++) {
      final b = stop(i);
      if (t <= b) {
        final a = stop(i - 1);
        final f = b - a == 0 ? 1.0 : (t - a) / (b - a);
        return Color.lerp(colors[i - 1], colors[i], f)!;
      }
    }
    return colors.last;
  }

  /// Colour of local point [p] on a solid with local [bounds].
  Color colorOf(Point3 p, Aabb bounds) => colorAt(t(p, bounds));

  /// Whether any colour is see-through.
  bool get isTranslucent => colors.any((c) => c.a < 1);

  /// Whether a mesh needs its big faces split to show this gradient.
  ///
  /// Colours are blended straight between a triangle's corners, which is
  /// exact for a two-colour linear gradient that spans the whole box
  /// without clamping. Everything else (radial, more colours, an end
  /// inside the box) bends within a face, so the painter splits big faces
  /// first.
  bool get needsRefinement => true;

  /// Stops mirrored, for a reversed colour list.
  List<double>? get _reversedStops =>
      stops == null ? null : [for (final s in stops!.reversed) 1 - s];
}

/// A [SolidGradient] along a line. See [SolidGradient.linear].
class LinearSolidGradient extends SolidGradient {
  /// Where the first colour sits.
  final Anchor3 start;

  /// Where the last colour sits.
  final Anchor3 end;

  /// Creates a linear gradient; top to bottom unless told otherwise.
  const LinearSolidGradient({
    this.start = Anchor3.top,
    this.end = Anchor3.bottom,
    required List<Color> colors,
    List<double>? stops,
  }) : super._(colors, stops);

  @override
  double t(Point3 p, Aabb bounds) {
    // Measured in anchor space so the gradient spans the box the same way
    // whatever its proportions.
    final a = Anchor3.of(p, bounds);
    final dx = end.x - start.x, dy = end.y - start.y, dz = end.z - start.z;
    final len2 = dx * dx + dy * dy + dz * dz;
    if (len2 == 0) return 0;
    return ((a.x - start.x) * dx +
            (a.y - start.y) * dy +
            (a.z - start.z) * dz) /
        len2;
  }

  @override
  bool get needsRefinement {
    if (colors.length != 2) return true;
    final lo = stops?.first ?? 0, hi = stops?.last ?? 1;
    // t is linear in anchor space, so its range over the box is set by
    // the corners.
    var tMin = double.infinity, tMax = double.negativeInfinity;
    for (final x in const [-1.0, 1.0]) {
      for (final y in const [-1.0, 1.0]) {
        for (final z in const [-1.0, 1.0]) {
          final dx = end.x - start.x, dy = end.y - start.y;
          final dz = end.z - start.z;
          final len2 = dx * dx + dy * dy + dz * dz;
          if (len2 == 0) return false; // one flat colour
          final t =
              ((x - start.x) * dx + (y - start.y) * dy + (z - start.z) * dz) /
              len2;
          tMin = math.min(tMin, t);
          tMax = math.max(tMax, t);
        }
      }
    }
    const eps = 1e-9;
    return tMin < lo - eps || tMax > hi + eps;
  }

  @override
  LinearSolidGradient get reversed =>
      LinearSolidGradient(start: end, end: start, colors: colors, stops: stops);

  /// Copy with the given fields replaced.
  LinearSolidGradient copyWith({
    Anchor3? start,
    Anchor3? end,
    List<Color>? colors,
    List<double>? stops,
  }) => LinearSolidGradient(
    start: start ?? this.start,
    end: end ?? this.end,
    colors: colors ?? this.colors,
    stops: stops ?? this.stops,
  );

  @override
  bool operator ==(Object other) =>
      other is LinearSolidGradient &&
      other.start == start &&
      other.end == end &&
      listEquals(other.colors, colors) &&
      listEquals(other.stops, stops);

  @override
  int get hashCode => Object.hash(
    start,
    end,
    Object.hashAll(colors),
    stops == null ? null : Object.hashAll(stops!),
  );
}

/// A [SolidGradient] outward from a point. See [SolidGradient.radial].
class RadialSolidGradient extends SolidGradient {
  /// Where the first colour sits.
  final Anchor3 center;

  /// Distance, in anchor units, at which the last colour is reached; null
  /// reaches right across the solid (see [effectiveRadius]).
  final double? radius;

  /// Creates a radial gradient; from the top across the whole solid unless
  /// told otherwise.
  const RadialSolidGradient({
    this.center = Anchor3.top,
    this.radius,
    required List<Color> colors,
    List<double>? stops,
  }) : super._(colors, stops);

  @override
  double t(Point3 p, Aabb bounds) {
    final r = effectiveRadius;
    if (r <= 0) return 1;
    final a = Anchor3.of(p, bounds);
    final dx = a.x - center.x, dy = a.y - center.y, dz = a.z - center.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz) / r;
  }

  /// [radius], or when null the distance from [center], through the
  /// middle of the box, to the far side of the sphere that fits inside it:
  /// `|center| + 1`. From [Anchor3.top] that is the bottom face centre; on
  /// a ball it is the opposite pole. Box corners beyond it keep the last
  /// colour.
  double get effectiveRadius {
    if (radius case final r?) return r;
    final c = center;
    return math.sqrt(c.x * c.x + c.y * c.y + c.z * c.z) + 1;
  }

  @override
  RadialSolidGradient get reversed => RadialSolidGradient(
    center: center,
    radius: radius,
    colors: colors.reversed.toList(),
    stops: _reversedStops,
  );

  /// Copy with the given fields replaced.
  /// Pass `radius: null` to go back to [effectiveRadius]'s automatic
  /// radius; leave it out to keep the current one.
  RadialSolidGradient copyWith({
    Anchor3? center,
    Object? radius = _keep,
    List<Color>? colors,
    List<double>? stops,
  }) => RadialSolidGradient(
    center: center ?? this.center,
    radius: identical(radius, _keep) ? this.radius : radius as double?,
    colors: colors ?? this.colors,
    stops: stops ?? this.stops,
  );

  @override
  bool operator ==(Object other) =>
      other is RadialSolidGradient &&
      other.center == center &&
      other.radius == radius &&
      listEquals(other.colors, colors) &&
      listEquals(other.stops, stops);

  @override
  int get hashCode => Object.hash(
    center,
    radius,
    Object.hashAll(colors),
    stops == null ? null : Object.hashAll(stops!),
  );
}

/// Marks a `copyWith` argument that was left out.
const Object _keep = Object();
