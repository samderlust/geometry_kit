import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_kit.dart';

/// Use 4 — collision and picking: tap to inspect, drag to move, and watch a
/// drone report contact.
class PickingDemo extends StatefulWidget {
  const PickingDemo({super.key});

  @override
  State<PickingDemo> createState() => _PickingDemoState();
}

class _PickingDemoState extends State<PickingDemo>
    with SingleTickerProviderStateMixin {
  final Map<String, Solid> _objects = {
    'Crate A': Box.fromMinMax(
      const Point3(-1.6, -1, -0.4),
      const Point3(-0.6, 0, 0.6),
    ),
    'Crate B': Box.fromMinMax(
      const Point3(0.4, -1, -1.2),
      const Point3(1.4, -0.2, -0.4),
    ),
    'Pillar': Cylinder(
      baseCenter: const Point3(1.1, -1, 0.8),
      radius: 0.22,
      height: 1.8,
    ),
    'Ball': const Sphere(center: Point3(-0.3, -0.55, 1.15), radius: 0.45),
    'Buoy': const Sphere(center: Point3(-1.2, -0.7, -1.3), radius: 0.3),
  };
  static const _round = {'Ball', 'Buoy'};

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  SceneHit? _hit;
  bool _bounds = false;

  static const _code = '''final ray = camera.rayThrough(
  Point(details.localPosition.dx, details.localPosition.dy),
  size.width,
  size.height,
);

final hit = nearestHit(ray, scene); // RayHit? — distance, point, normal

// Broad phase first, exact test only when bounds overlap.
for (final other in scene) {
  if (drone.bounds.overlaps(other.bounds) && drone.intersects(other)) {
    onContact(drone, other);
  }
}

// In Flutter, GeoScene does the ray part for you:
GeoScene(
  onTap: (hit) => print(hit?.node.id),
  onDragSolid: (node, delta) => move(node, delta),
  children: [...],
)''';

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    return AnimatedBuilder(
      animation: _clock,
      builder: (context, _) {
        final drone = Sphere(
          center: Point3(2.2 * sin(_clock.value * 2 * pi), -0.5, -0.8),
          radius: 0.28,
        );
        final touching = [
          for (final e in _objects.entries)
            if (drone.intersects(e.value)) e.key,
        ];
        final hit = _hit?.hit;
        void pick(SceneHit? h) => setState(() => _hit = h);

        return Demo3dPage(
          code: _code,
          demo: DemoPanel(
            label: 'Ray3 · Aabb',
            hint: 'tap · drag objects · orbit',
            scene: ZoomScene(
              camera: const OrbitCamera(
                yaw: 30,
                pitch: 32,
                distance: 7.8,
                target: Point3(0, -0.4, 0),
              ),
              builder: (camera, onCameraChanged) => GeoScene(
                camera: camera,
                onCameraChanged: onCameraChanged,
                onTap: pick,
                onHover: pick,
                onDragSolid: (node, delta) => setState(() {
                  _objects[node.id!] = _objects[node.id!]!.translate(
                    x: delta.x,
                    z: delta.z,
                  );
                }),
                children: [
                  ...p.grid3(extent: 2.5, step: 0.5, y: -1),
                  GeoPath3(
                    const [Point3(-2.5, -0.5, -0.8), Point3(2.5, -0.5, -0.8)],
                    overlay: false,
                    style: ShapeStyle(
                      strokeColor: p.accent.withValues(alpha: 0.5),
                      dashPattern: const DashPattern([2, 4]),
                    ),
                  ),
                  for (final e in _objects.entries)
                    GeoSolid(
                      e.value,
                      id: e.key,
                      segments: 24,
                      style: ShapeStyle(
                        fillColor: _hit?.node.id == e.key
                            ? p.amber
                            : (_round.contains(e.key) ? p.teal : p.muted),
                        strokeColor: _round.contains(e.key)
                            ? null
                            : Color.lerp(p.muted, Colors.black, 0.4),
                      ),
                    ),
                  GeoSolid(
                    drone,
                    pickable: false,
                    segments: 20,
                    style: ShapeStyle(
                      fillColor: touching.isEmpty ? p.accent : p.danger,
                      strokeColor: null,
                    ),
                  ),
                  if (_bounds)
                    for (final s in [..._objects.values, drone])
                      ...aabbEdges(s.bounds, p.fg.withValues(alpha: 0.45)),
                  if (hit != null) ..._crosshair(hit, p.fg),
                ],
              ),
            ),
            controls: [
              DemoToggle(
                label: 'Show bounding boxes',
                value: _bounds,
                onChanged: (v) => setState(() => _bounds = v),
              ),
            ],
            readouts: [
              Readout(
                'Ray hit',
                hit == null
                    ? 'Point at an object'
                    : '${_hit!.node.id} at (${hit.point.x.toStringAsFixed(1)}, '
                          '${hit.point.y.toStringAsFixed(1)}, '
                          '${hit.point.z.toStringAsFixed(1)})',
                highlight: true,
              ),
              Readout(
                'Distance',
                hit == null ? '–' : '${hit.distance.toStringAsFixed(2)} u',
              ),
              Readout(
                'Drone contact',
                touching.isEmpty ? 'Clear' : 'Touching ${touching.join(', ')}',
              ),
            ],
          ),
        );
      },
    );
  }

  /// A small cross on the surface plus the outward normal.
  List<GeoPath3> _crosshair(RayHit hit, Color color) {
    final t1 = hit.normal.anyPerpendicular * 0.15;
    final t2 = hit.normal.cross(t1);
    final style = ShapeStyle.stroked(color, width: 1.5);
    return [
      GeoPath3([hit.point - t1, hit.point + t1], style: style),
      GeoPath3([hit.point - t2, hit.point + t2], style: style),
      GeoPath3([hit.point, hit.point + hit.normal * 0.5], style: style),
    ];
  }
}
