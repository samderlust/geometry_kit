import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

import '../util/paint_helpers.dart';
import 'scene_node.dart';

/// Caches triangle meshes and their sharp edges per solid.
///
/// Solids are immutable, so a mesh built once for a solid instance stays
/// valid; the cache is keyed by identity and segment count.
class SceneMeshCache {
  final _cache = Expando<Map<int, SceneMesh>>('SceneMeshCache');

  /// Mesh for [node], built on first use.
  SceneMesh meshFor(GeoSolid node) {
    final byCount = _cache[node.solid] ??= <int, SceneMesh>{};
    return byCount[node.segments] ??= SceneMesh(
      node.solid.toMesh(segments: node.segments),
    );
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
    final w = size.width, h = size.height;
    final camPos = camera.position;
    final l = light.direction.normalized;
    final tris = <_Tri>[];

    for (final node in nodes) {
      if (node is GeoPath3 && !node.overlay) _drawPath(canvas, size, node);
    }

    for (final node in nodes) {
      if (node is! GeoSolid) continue;
      final sm = cache.meshFor(node);
      final mesh = sm.mesh;
      final base = node.style.fillColor ?? const Color(0xFF90A4AE);
      final alpha = base.a * node.style.opacity;
      if (alpha <= 0) continue;
      final translucent = alpha < 1;
      final edgeColor = node.style.strokeColor;
      final drawEdges = edgeColor != null && node.style.strokeWidth > 0;

      final view = [for (final p in mesh.positions) camera.toView(p)];
      final screen = List<Offset?>.filled(mesh.positions.length, null);
      for (var i = 0; i < view.length; i++) {
        final p = camera.project(mesh.positions[i], w, h);
        if (p != null) screen[i] = Offset(p.x, p.y);
      }

      final idx = mesh.indices;
      for (var t = 0; t < mesh.triangleCount; t++) {
        final ia = idx[t * 3], ib = idx[t * 3 + 1], ic = idx[t * 3 + 2];
        final sa = screen[ia], sb = screen[ib], sc = screen[ic];
        if (sa == null || sb == null || sc == null) continue;
        var n = sm.normals[t];
        final toCam = camPos - mesh.positions[ia];
        final facing = n.dot(toCam) > 0;
        if (!facing) {
          if (!translucent) continue;
          n = -n;
        }
        final diffuse = math.max(0.0, n.dot(l));
        final shade = light.ambient + light.intensity * diffuse;
        final depth = (view[ia].z + view[ib].z + view[ic].z) / 3;
        tris.add(
          _Tri(
            sa,
            sb,
            sc,
            _shade(base, shade, alpha),
            depth,
            drawEdges && sm.creases[t].isNotEmpty
                ? [for (final (a, b) in sm.creases[t]) (screen[a], screen[b])]
                : null,
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
          _drawPath(canvas, size, node);
        case GeoPath3():
          break;
        case GeoLabel3():
          _drawLabel(canvas, size, node);
        case GeoSolid():
          break;
      }
    }
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
      positions.addAll([t.a, t.b, t.c]);
      colors.addAll([t.color, t.color, t.color]);
      final edges = t.edges;
      if (edges == null) continue;
      // Edges must be painted in depth order too, so flush first.
      flush();
      final style = t.node!.style;
      final paint = Paint()
        ..color = style.strokeColor!.withValues(
          alpha: style.strokeColor!.a * style.opacity,
        )
        ..strokeWidth = style.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (final (a, b) in edges) {
        if (a != null && b != null) canvas.drawLine(a, b, paint);
      }
    }
    flush();
  }

  void _drawPath(Canvas canvas, Size size, GeoPath3 node) {
    final path = Path();
    var started = false;
    for (final p in node.points) {
      final s = camera.project(p, size.width, size.height);
      if (s == null) {
        started = false;
        continue;
      }
      if (started) {
        path.lineTo(s.x, s.y);
      } else {
        path.moveTo(s.x, s.y);
        started = true;
      }
    }
    if (node.closed) path.close();
    paintShapePath(canvas, path, node.style);
  }

  void _drawLabel(Canvas canvas, Size size, GeoLabel3 node) {
    final s = camera.project(node.position, size.width, size.height);
    if (s == null) return;
    final tp = TextPainter(
      text: TextSpan(text: node.text, style: node.style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = (node.alignment.x - 1) / 2 * tp.width;
    final dy = (node.alignment.y - 1) / 2 * tp.height;
    tp.paint(canvas, Offset(s.x + dx, s.y + dy));
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
  final Offset a, b, c;
  final Color color;
  final double depth;
  final List<(Offset?, Offset?)>? edges;
  final GeoSolid? node;
  const _Tri(
    this.a,
    this.b,
    this.c,
    this.color,
    this.depth,
    this.edges,
    this.node,
  );
}

bool _nodesEqual(List<SceneNode> a, List<SceneNode> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
