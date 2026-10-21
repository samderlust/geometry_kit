import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart' show Point;
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import 'scene_node.dart';

/// Caches triangle meshes and their sharp edges per solid.
///
/// Keyed by the solid's value (`==` / `hashCode`) and segment count, so a
/// solid rebuilt with the same parameters in every `build()` still hits the
/// cache. The least recently used entries are dropped beyond [capacity].
class SceneMeshCache {
  /// Creates a cache holding up to [capacity] meshes.
  SceneMeshCache({this.capacity = 256}) : assert(capacity > 0);

  /// Maximum number of meshes kept.
  final int capacity;

  // A LinkedHashMap: iteration order is least to most recently used.
  final _entries = <(Solid, int), SceneMesh>{};

  /// Number of meshes currently cached.
  int get length => _entries.length;

  /// Mesh for [node], built on first use.
  SceneMesh meshFor(GeoSolid node) {
    final key = (node.solid, node.segments);
    final hit = _entries.remove(key);
    if (hit != null) {
      _entries[key] = hit; // move to most recently used
      return hit;
    }
    final built = SceneMesh(node.solid.toMesh(segments: node.segments));
    _entries[key] = built;
    if (_entries.length > capacity) _entries.remove(_entries.keys.first);
    return built;
  }
}

/// A mesh plus, per triangle, the sharp edges it borders.
class SceneMesh {
  /// The triangle mesh.
  final Mesh mesh;

  /// Unit face normals, one per triangle.
  final List<Point3> normals;

  /// For each triangle, vertex index pairs of its sharp edges.
  final List<List<(int, int)>> creases;

  /// Builds normals and crease edges for [mesh]. An edge is sharp when its
  /// two faces meet at more than [creaseAngle] degrees, or it has only one.
  factory SceneMesh(Mesh mesh, {double creaseAngle = 25}) {
    final normals = [
      for (var i = 0; i < mesh.triangleCount; i++) mesh.faceNormal(i),
    ];
    final owners = <(int, int), List<int>>{};
    final idx = mesh.indices;
    for (var t = 0; t < mesh.triangleCount; t++) {
      for (var k = 0; k < 3; k++) {
        final a = idx[t * 3 + k], b = idx[t * 3 + (k + 1) % 3];
        (owners[a < b ? (a, b) : (b, a)] ??= []).add(t);
      }
    }
    final cosLimit = math.cos(creaseAngle * math.pi / 180);
    final creases = List.generate(mesh.triangleCount, (_) => <(int, int)>[]);
    owners.forEach((edge, tris) {
      final sharp =
          tris.length != 2 || normals[tris[0]].dot(normals[tris[1]]) < cosLimit;
      if (!sharp) return;
      for (final t in tris) {
        creases[t].add(edge);
      }
    });
    return SceneMesh._(mesh, normals, creases);
  }

  SceneMesh._(this.mesh, this.normals, this.creases);
}

/// Paints [GeoScene] content: solids depth-sorted back to front (painter's
/// algorithm), then paths and labels on top.
class ScenePainter extends CustomPainter {
  /// Nodes to draw.
  final List<SceneNode> nodes;

  /// Viewpoint.
  final OrbitCamera camera;

  /// Lighting.
  final DirectionalLight light;

  /// Optional background fill.
  final Color? backgroundColor;

  /// Mesh cache shared across frames.
  final SceneMeshCache cache;

  /// Creates a scene painter.
  ScenePainter({
    required this.nodes,
    required this.camera,
    required this.cache,
    this.light = const DirectionalLight(),
    this.backgroundColor,
  });

  /// Triangles drawn in the last paint, after back-face culling.
  int lastTriangleCount = 0;

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor!);
    }
    final cv = camera.view(size.width, size.height);
    final l = light.direction.normalized;
    final tris = <_Tri>[];

    for (final node in nodes) {
      if (node is GeoPath3 && !node.overlay) _drawPath(canvas, cv, node);
    }

    for (final node in nodes) {
      if (node is! GeoSolid) continue;
      final sm = cache.meshFor(node);
      final mesh = sm.mesh;
      final base = node.style.fillColor ?? const Color(0xFF90A4AE);
      final alpha = base.a * (node.style.opacity ?? 1.0);
      if (alpha <= 0) continue;
      final translucent = alpha < 1;
      final edgeColor = node.style.strokeColor;
      final drawEdges =
          edgeColor != null && (node.style.strokeWidth ?? 1.0) > 0;

      // Place the cached local mesh, then one camera transform per vertex;
      // screen positions derive from it.
      final xf = node.transform;
      final local = xf == Transform3.identity;
      final world = local
          ? mesh.positions
          : [for (final p in mesh.positions) xf.apply(p)];
      final view = [for (final p in world) cv.toView(p)];
      final screen = [for (final v in view) _offset(cv.projectView(v))];

      final idx = mesh.indices;
      for (var t = 0; t < mesh.triangleCount; t++) {
        final ia = idx[t * 3], ib = idx[t * 3 + 1], ic = idx[t * 3 + 2];
        final va = view[ia], vb = view[ib], vc = view[ic];
        final near = cv.near;
        if (va.z < near && vb.z < near && vc.z < near) continue;

        var n = local ? sm.normals[t] : xf.applyDirection(sm.normals[t]);
        final facing = n.dot(cv.position - world[ia]) > 0;
        if (!facing) {
          if (!translucent) continue;
          n = -n;
        }
        final diffuse = math.max(0.0, n.dot(l));
        final shade = light.ambient + light.intensity * diffuse;
        final depth = (va.z + vb.z + vc.z) / 3;

        final List<Offset> points;
        List<(Offset, Offset)>? edges;
        if (screen[ia] != null && screen[ib] != null && screen[ic] != null) {
          points = [screen[ia]!, screen[ib]!, screen[ic]!];
          if (drawEdges && sm.creases[t].isNotEmpty) {
            edges = [
              for (final (a, b) in sm.creases[t]) (screen[a]!, screen[b]!),
            ];
          }
        } else {
          // Part of the triangle is behind the near plane: cut it there
          // instead of dropping it.
          points = [
            for (final v in _clipToNear([va, vb, vc], near)) _onScreen(cv, v),
          ];
          if (drawEdges && sm.creases[t].isNotEmpty) {
            edges = [
              for (final (a, b) in sm.creases[t])
                if (_clipSegment(view[a], view[b], near) case (
                  final p,
                  final q,
                ))
                  (_onScreen(cv, p), _onScreen(cv, q)),
            ];
          }
        }
        tris.add(
          _Tri(
            points,
            _shade(base, shade, alpha),
            depth,
            edges,
            drawEdges ? node : null,
          ),
        );
      }
    }

    tris.sort((a, b) => b.depth.compareTo(a.depth));
    lastTriangleCount = tris.length;
    _drawTriangles(canvas, tris);

    for (final node in nodes) {
      switch (node) {
        case GeoPath3(overlay: true):
          _drawPath(canvas, cv, node);
        case GeoPath3():
          break;
        case GeoLabel3():
          _drawLabel(canvas, cv, node);
        case GeoSolid() || GeoHandle():
          break;
      }
    }

    // Handles go on top of everything, labels included.
    for (final node in nodes) {
      if (node is GeoHandle) _drawHandle(canvas, cv, node);
    }
  }

  void _drawHandle(Canvas canvas, CameraView cv, GeoHandle node) {
    final s = cv.project(node.position);
    if (s == null) return;
    final c = Offset(s.x, s.y);
    final path = switch (node.shape) {
      HandleShape.circle =>
        Path()..addOval(Rect.fromCircle(center: c, radius: node.radius)),
      HandleShape.square =>
        Path()..addRect(Rect.fromCircle(center: c, radius: node.radius)),
    };
    paintShapePath(canvas, path, node.style);
  }

  void _drawTriangles(Canvas canvas, List<_Tri> tris) {
    final positions = <Offset>[];
    final colors = <Color>[];
    void flush() {
      if (positions.isEmpty) return;
      canvas.drawVertices(
        ui.Vertices(ui.VertexMode.triangles, positions, colors: colors),
        BlendMode.dst,
        Paint(),
      );
      positions.clear();
      colors.clear();
    }

    for (final t in tris) {
      final p = t.points;
      for (var i = 1; i < p.length - 1; i++) {
        positions.addAll([p[0], p[i], p[i + 1]]);
        colors.addAll([t.color, t.color, t.color]);
      }
      final edges = t.edges;
      if (edges == null) continue;
      // Edges must be painted in depth order too, so flush first.
      flush();
      final style = t.node!.style;
      final paint = Paint()
        ..color = style.strokeColor!.withValues(
          alpha: style.strokeColor!.a * (style.opacity ?? 1.0),
        )
        ..strokeWidth = style.strokeWidth ?? 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (final (a, b) in edges) {
        canvas.drawLine(a, b, paint);
      }
    }
    flush();
  }

  void _drawPath(Canvas canvas, CameraView cv, GeoPath3 node) {
    final pts = node.points;
    if (pts.length < 2) return;
    final path = Path();
    final view = [for (final p in pts) cv.toView(p)];
    final count = node.closed ? pts.length : pts.length - 1;
    Offset? pen;
    var allVisible = true;
    for (var i = 0; i < count; i++) {
      final seg = _clipSegment(view[i], view[(i + 1) % pts.length], cv.near);
      if (seg == null) {
        allVisible = false;
        pen = null;
        continue;
      }
      final a = _onScreen(cv, seg.$1);
      final b = _onScreen(cv, seg.$2);
      if (seg.$1 != view[i] || seg.$2 != view[(i + 1) % pts.length]) {
        allVisible = false;
      }
      if (pen != a) path.moveTo(a.dx, a.dy);
      path.lineTo(b.dx, b.dy);
      pen = b;
    }
    // Only fill a closed outline that is fully in front of the camera.
    final s = node.style;
    final style = node.closed && !allVisible
        ? ShapeStyle(
            strokeColor: s.strokeColor,
            strokeGradient: s.strokeGradient,
            strokePaintBuilder: s.strokePaintBuilder,
            strokeWidth: s.strokeWidth,
            opacity: s.opacity,
            dashPattern: s.dashPattern,
            strokeCap: s.strokeCap,
            strokeJoin: s.strokeJoin,
          )
        : s;
    if (node.closed && allVisible) path.close();
    paintShapePath(canvas, path, style);
  }

  void _drawLabel(Canvas canvas, CameraView cv, GeoLabel3 node) {
    final s = cv.project(node.position);
    if (s == null) return;
    final tp = TextPainter(
      text: TextSpan(text: node.text, style: node.style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = (node.alignment.x - 1) / 2 * tp.width;
    final dy = (node.alignment.y - 1) / 2 * tp.height;
    tp.paint(canvas, Offset(s.x + dx, s.y + dy));
  }

  static Offset? _offset(Point? p) => p == null ? null : Offset(p.x, p.y);

  /// Projects a camera-space point already clipped to the near plane.
  /// Clipped points can sit a rounding error behind it, so no near check.
  static Offset _onScreen(CameraView cv, Point3 v) {
    final z = math.max(v.z, cv.near);
    return Offset(
      cv.width / 2 + cv.focalLength * v.x / z,
      cv.height / 2 - cv.focalLength * v.y / z,
    );
  }

  /// Clips a camera-space polygon to the region `z >= near`
  /// (Sutherland–Hodgman against one plane).
  static List<Point3> _clipToNear(List<Point3> poly, double near) {
    final out = <Point3>[];
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i], b = poly[(i + 1) % poly.length];
      final aIn = a.z >= near, bIn = b.z >= near;
      if (aIn) out.add(a);
      if (aIn != bIn) out.add(a.lerp(b, (near - a.z) / (b.z - a.z)));
    }
    return out;
  }

  /// The part of camera-space segment [a]–[b] with `z >= near`, or `null`.
  static (Point3, Point3)? _clipSegment(Point3 a, Point3 b, double near) {
    final aIn = a.z >= near, bIn = b.z >= near;
    if (aIn && bIn) return (a, b);
    if (!aIn && !bIn) return null;
    final cut = a.lerp(b, (near - a.z) / (b.z - a.z));
    return aIn ? (a, cut) : (cut, b);
  }

  static Color _shade(Color c, double k, double alpha) {
    double ch(double v) => k <= 1 ? v * k : v + (1 - v) * (k - 1);
    return Color.from(
      alpha: alpha.clamp(0.0, 1.0),
      red: ch(c.r).clamp(0.0, 1.0),
      green: ch(c.g).clamp(0.0, 1.0),
      blue: ch(c.b).clamp(0.0, 1.0),
    );
  }

  @override
  bool shouldRepaint(covariant ScenePainter old) =>
      old.camera != camera ||
      old.light != light ||
      old.backgroundColor != backgroundColor ||
      !_nodesEqual(old.nodes, nodes);
}

class _Tri {
  /// Screen polygon: a triangle, or a quad when cut by the near plane.
  final List<Offset> points;
  final Color color;
  final double depth;
  final List<(Offset, Offset)>? edges;
  final GeoSolid? node;
  const _Tri(this.points, this.color, this.depth, this.edges, this.node);
}

bool _nodesEqual(List<SceneNode> a, List<SceneNode> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
