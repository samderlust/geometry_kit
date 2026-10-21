import 'dart:typed_data';

import '../math/aabb.dart';
import '../math/point3.dart';

/// An immutable triangle mesh.
///
/// Triangles are stored as index triples into [positions]. Every solid in
/// this package produces meshes whose triangles wind counter-clockwise when
/// seen from outside, so face normals point outward.
///
/// Feed [positionsFloat32] / [indicesUint32] to a GPU renderer, or export
/// with [toObj] / [toStl] for Blender, slicers and 3D printers.
class Mesh {
  /// Vertex positions.
  final List<Point3> positions;

  /// Triangle vertex indices, three per triangle.
  final List<int> indices;

  /// Creates a mesh. [indices] length must be a multiple of 3.
  Mesh(this.positions, this.indices)
      : assert(indices.length % 3 == 0, 'indices must come in triples');

  /// A mesh with no triangles.
  static final empty = Mesh(const [], const []);

  /// Merges several meshes into one.
  factory Mesh.merge(Iterable<Mesh> meshes) {
    final pos = <Point3>[];
    final idx = <int>[];
    for (final m in meshes) {
      final base = pos.length;
      pos.addAll(m.positions);
      idx.addAll(m.indices.map((i) => i + base));
    }
    return Mesh(pos, idx);
  }

  /// Number of triangles.
  int get triangleCount => indices.length ~/ 3;

  /// Number of vertices.
  int get vertexCount => positions.length;

  /// The three corners of triangle [i].
  (Point3, Point3, Point3) triangle(int i) => (
        positions[indices[i * 3]],
        positions[indices[i * 3 + 1]],
        positions[indices[i * 3 + 2]],
      );

  /// Outward unit normal of triangle [i] (zero for degenerate triangles).
  Point3 faceNormal(int i) {
    final (a, b, c) = triangle(i);
    return (b - a).cross(c - a).normalized;
  }

  /// Total surface area.
  double get surfaceArea {
    var sum = 0.0;
    for (var i = 0; i < triangleCount; i++) {
      final (a, b, c) = triangle(i);
      sum += (b - a).cross(c - a).magnitude / 2;
    }
    return sum;
  }

  /// Enclosed volume, assuming a closed mesh with outward-facing triangles.
  ///
  /// Negative when the triangles face inward.
  double get volume {
    var sum = 0.0;
    for (var i = 0; i < triangleCount; i++) {
      final (a, b, c) = triangle(i);
      sum += a.dot(b.cross(c));
    }
    return sum / 6;
  }

  /// Bounding box of all vertices.
  Aabb get bounds => Aabb.fromPoints(positions);

  /// Mesh with every vertex moved by [x], [y], [z].
  Mesh translate({double x = 0, double y = 0, double z = 0}) =>
      Mesh([for (final p in positions) p.translate(x: x, y: y, z: z)], indices);

  /// Mesh rotated by [deg] degrees around [axis] through [pivot].
  Mesh rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) => Mesh(
        [for (final p in positions) p.rotate(axis, deg, pivot: pivot)],
        indices,
      );

  /// Mesh scaled about the origin. A negative [factor] also flips winding
  /// so normals keep pointing outward.
  Mesh scale(double factor) {
    final pos = [for (final p in positions) p * factor];
    if (factor >= 0) return Mesh(pos, indices);
    final flipped = <int>[];
    for (var i = 0; i < indices.length; i += 3) {
      flipped.addAll([indices[i], indices[i + 2], indices[i + 1]]);
    }
    return Mesh(pos, flipped);
  }

  /// Positions packed as `x, y, z, x, y, z, …` for GPU vertex buffers.
  Float32List get positionsFloat32 {
    final out = Float32List(positions.length * 3);
    for (var i = 0; i < positions.length; i++) {
      out[i * 3] = positions[i].x;
      out[i * 3 + 1] = positions[i].y;
      out[i * 3 + 2] = positions[i].z;
    }
    return out;
  }

  /// Indices packed for GPU index buffers.
  Uint32List get indicesUint32 => Uint32List.fromList(indices);

  /// Wavefront OBJ text (positions and faces, 1-based indices).
  String toObj({String name = 'mesh'}) {
    final b = StringBuffer('# geometry_kit_3d\no $name\n');
    for (final p in positions) {
      b.writeln('v ${_num(p.x)} ${_num(p.y)} ${_num(p.z)}');
    }
    for (var i = 0; i < indices.length; i += 3) {
      b.writeln(
          'f ${indices[i] + 1} ${indices[i + 1] + 1} ${indices[i + 2] + 1}');
    }
    return b.toString();
  }

  /// ASCII STL text, the common input format for 3D-printing slicers.
  String toStl({String name = 'mesh'}) {
    final b = StringBuffer('solid $name\n');
    for (var i = 0; i < triangleCount; i++) {
      final (p0, p1, p2) = triangle(i);
      final n = faceNormal(i);
      b
        ..writeln('  facet normal ${_num(n.x)} ${_num(n.y)} ${_num(n.z)}')
        ..writeln('    outer loop');
      for (final p in [p0, p1, p2]) {
        b.writeln('      vertex ${_num(p.x)} ${_num(p.y)} ${_num(p.z)}');
      }
      b
        ..writeln('    endloop')
        ..writeln('  endfacet');
    }
    b.writeln('endsolid $name');
    return b.toString();
  }

  static String _num(double v) {
    final s = v.toStringAsFixed(6);
    // Trim trailing zeros for compact output: 1.500000 → 1.5, 2.000000 → 2
    final trimmed = s.contains('.')
        ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
        : s;
    return trimmed == '-0' ? '0' : trimmed;
  }

  @override
  String toString() => 'Mesh($vertexCount vertices, $triangleCount triangles)';
}

/// Incremental mesh construction used by the solids in this package.
class MeshBuilder {
  final _positions = <Point3>[];
  final _indices = <int>[];

  /// Adds a vertex and returns its index.
  int vertex(Point3 p) {
    _positions.add(p);
    return _positions.length - 1;
  }

  /// Adds a triangle; skipped when two indices repeat.
  void triangle(int a, int b, int c) {
    if (a == b || b == c || a == c) return;
    _indices.addAll([a, b, c]);
  }

  /// Adds a quad `a b c d` (counter-clockwise from outside) as two triangles.
  void quad(int a, int b, int c, int d) {
    triangle(a, b, c);
    triangle(a, c, d);
  }

  /// Adds a convex polygon as a triangle fan.
  void fan(List<int> ring) {
    for (var i = 1; i < ring.length - 1; i++) {
      triangle(ring[0], ring[i], ring[i + 1]);
    }
  }

  /// Adds raw triangle [indices] (already offset).
  void triangles(Iterable<int> indices) => _indices.addAll(indices);

  /// The finished mesh.
  Mesh build() =>
      Mesh(List.unmodifiable(_positions), List.unmodifiable(_indices));
}
