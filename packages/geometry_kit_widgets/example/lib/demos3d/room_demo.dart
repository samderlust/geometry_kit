import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_kit.dart';

/// Use 3 — CAD and measurement: extrude a floor plan into a room.
class RoomDemo extends StatefulWidget {
  const RoomDemo({super.key});

  @override
  State<RoomDemo> createState() => _RoomDemoState();
}

class _RoomDemoState extends State<RoomDemo> {
  double _height = 2.7;

  // L-shaped living room in metres, centred on the origin.
  static final _plan = Polygon(const [
    Point(0, 0),
    Point(6, 0),
    Point(6, 3),
    Point(3.5, 3),
    Point(3.5, 5),
    Point(0, 5),
  ]).translate(x: -3, y: -2.5);

  static const _openings = 0.9 * 2.1 + 2 * (1.2 * 1.2); // door + 2 windows

  static const _code = '''final plan = Polygon([
  Point(0, 0), Point(6, 0), Point(6, 3),
  Point(3.5, 3), Point(3.5, 5), Point(0, 5),
]);

final room = Prism.extrude(plan, height: 2.7);

const openings = 0.9 * 2.1 + 2 * (1.2 * 1.2); // door + 2 windows
final wallArea = room.lateralArea - openings;
final paintLitres = wallArea * 2 / 10;       // 2 coats, 10 m²/L

print(plan.area);   // 25.0 m²  (geometry_kit 2D)
print(room.volume); // 67.5 m³  (air volume for HVAC sizing)''';

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    final room = Prism.extrude(_plan, height: _height);
    final wall = room.lateralArea - _openings;
    const f = PlaneFrame.ground;
    final v = _plan.vertices;
    final corner = f.toWorld(v.first);

    // Dimension labels sit just outside each wall.
    final sign = _plan.isClockwise ? -1.0 : 1.0;
    final labels = <GeoLabel3>[];
    for (var i = 0; i < v.length; i++) {
      final a = v[i], b = v[(i + 1) % v.length];
      final edge = b - a;
      final out = Point(edge.y, -edge.x).normalized; // right of a CCW edge
      labels.add(
        GeoLabel3(
          f.toWorld(a.midPointTo(b) + out * (0.55 * sign)),
          '${a.distanceTo(b).toStringAsFixed(1)} m',
          style: p.label3(p.muted, weight: FontWeight.w500),
        ),
      );
    }

    return Demo3dPage(
      code: _code,
      demo: DemoPanel(
        label: 'Prism.extrude(plan)',
        hint: 'ceiling hidden · drag to orbit',
        scene: GeoScene(
          camera: const OrbitCamera(
            yaw: 32,
            pitch: 36,
            distance: 15,
            target: Point3(0, 1, 0),
          ),
          children: [
            ...p.grid3(extent: 4.5, step: 1),
            GeoPath3(
              [for (final q in v) f.toWorld(q)],
              closed: true,
              overlay: false,
              style: ShapeStyle(
                fillColor: p.muted.withValues(alpha: 0.18),
                strokeColor: null,
              ),
            ),
            GeoSolid(
              OpenTopPrism(room),
              pickable: false,
              style: ShapeStyle(
                fillColor: p.accent,
                opacity: 0.24,
                strokeColor: p.accent.withValues(alpha: 0.8),
              ),
            ),
            GeoPath3(
              [for (final q in v) f.toWorld(q)],
              closed: true,
              style: ShapeStyle.stroked(p.accent, width: 2),
            ),
            GeoPath3([
              corner,
              corner.translate(y: _height),
            ], style: ShapeStyle.stroked(p.amber, width: 2)),
            GeoLabel3(
              corner.translate(y: _height + 0.4),
              '${_height.toStringAsFixed(2)} m',
              style: p.label3(p.amber),
            ),
            ...labels,
          ],
        ),
        controls: [
          DemoSlider(
            label: 'Ceiling height',
            display: '${_height.toStringAsFixed(2)} m',
            value: _height,
            min: 2.4,
            max: 3.6,
            onChanged: (x) => setState(() => _height = x),
          ),
        ],
        readouts: [
          Readout('Floor area', '${_plan.area.toStringAsFixed(2)} m²'),
          Readout('Volume', '${room.volume.toStringAsFixed(2)} m³'),
          Readout('Net wall area', '${wall.toStringAsFixed(2)} m²'),
          Readout(
            'Paint, 2 coats',
            '${(wall * 2 / 10).toStringAsFixed(1)} L',
            highlight: true,
          ),
        ],
      ),
    );
  }
}

/// A [Prism] drawn as walls only (no floor or ceiling), so the inside shows.
///
/// Every geometric query goes to the prism; only [toMesh] drops the caps.
class OpenTopPrism implements Solid {
  final Prism prism;
  OpenTopPrism(this.prism);

  @override
  Mesh toMesh({int segments = 32}) {
    final full = prism.toMesh();
    final n = prism.frame.normal;
    final keep = <int>[];
    for (var t = 0; t < full.triangleCount; t++) {
      if (full.faceNormal(t).dot(n).abs() < 0.99) {
        keep.addAll(full.indices.sublist(t * 3, t * 3 + 3));
      }
    }
    return Mesh(full.positions, keep);
  }

  @override
  double get volume => prism.volume;
  @override
  double get surfaceArea => prism.surfaceArea;
  @override
  Aabb get bounds => prism.bounds;
  @override
  bool contains(Point3 point) => prism.contains(point);
  @override
  Point3 closestPoint(Point3 point) => prism.closestPoint(point);
  @override
  double distanceTo(Point3 point) => prism.distanceTo(point);
  @override
  RayHit? intersectRay(Ray3 ray) => prism.intersectRay(ray);
  @override
  Solid translate({double x = 0, double y = 0, double z = 0}) =>
      OpenTopPrism(prism.translate(x: x, y: y, z: z));
  @override
  Solid scale(double factor) => OpenTopPrism(prism.scale(factor));
  @override
  Solid rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) =>
      OpenTopPrism(prism.rotate(axis, deg, pivot: pivot));

  @override
  bool operator ==(Object other) =>
      other is OpenTopPrism && other.prism == prism;

  @override
  int get hashCode => prism.hashCode;
}
