import 'package:flutter/material.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_kit.dart';

/// Use 1 — teaching: slice a cone with a plane and name the conic.
class ConeSliceDemo extends StatefulWidget {
  const ConeSliceDemo({super.key});

  @override
  State<ConeSliceDemo> createState() => _ConeSliceDemoState();
}

class _ConeSliceDemoState extends State<ConeSliceDemo> {
  double _tilt = 30;
  double _offset = 0;

  final _cone = Cone(baseCenter: const Point3(0, -1, 0), radius: 1, height: 2);

  static const _code = '''final cone = Cone(
  baseCenter: Point3(0, -1, 0),
  radius: 1,
  height: 2,
);

// Tilt the cutting plane 30° away from horizontal.
final plane = Plane.fromPointNormal(
  Point3.zero,
  Point3.unitY.rotate(Point3.unitZ, 30),
);

final section = cone.slice(plane); // sealed CrossSection

final label = switch (section) {
  CircleSection(:final circle) => 'Circle, r = \${circle.radius}',
  EllipseSection(:final ellipse) =>
    'Ellipse \${ellipse.radiusX} × \${ellipse.radiusY}',
  ParabolaSection() => 'Parabola',
  HyperbolaSection() => 'Hyperbola',
  EmptySection() => 'No intersection',
};

print(cone.volume);               // 2.0943951023931953
print(section.toPolygon().area);  // geometry_kit 2D Polygon''';

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    final plane = Plane.fromPointNormal(
      Point3(0, _offset, 0),
      Point3.unitY.rotate(Point3.unitZ, _tilt),
    );
    final section = _cone.slice(plane);
    final frame = plane.frame(uHint: Point3.unitX);
    const s = 1.55;
    final quad = [
      frame.origin + frame.u * s + frame.v * s,
      frame.origin - frame.u * s + frame.v * s,
      frame.origin - frame.u * s - frame.v * s,
      frame.origin + frame.u * s - frame.v * s,
    ];
    final type = switch (section) {
      CircleSection() => 'Circle',
      EllipseSection(:final clipped) =>
        clipped ? 'Ellipse, clipped by base' : 'Ellipse',
      ParabolaSection() => 'Parabola',
      HyperbolaSection() => 'Hyperbola',
      EmptySection() => 'No intersection',
    };

    return Demo3dPage(
      code: _code,
      demo: DemoPanel(
        label: 'Cone ∩ plane',
        hint: 'drag to orbit',
        scene: GeoScene(
          camera: const OrbitCamera(
            yaw: -40,
            pitch: 22,
            distance: 5.6,
            target: Point3(0, -0.05, 0),
          ),
          children: [
            ...p.grid3(extent: 2, step: 0.5, y: -1),
            GeoPath3(
              const [Point3(0, 1.5, 0), Point3(0, -1, 0)],
              style: ShapeStyle(
                strokeColor: p.muted,
                dashPattern: const DashPattern([3, 4]),
              ),
              overlay: false,
            ),
            GeoSolid(
              _cone,
              segments: 48,
              pickable: false,
              style: ShapeStyle(fillColor: p.accent, opacity: 0.22),
            ),
            GeoPath3(
              quad,
              closed: true,
              style: ShapeStyle(
                fillColor: p.fg.withValues(alpha: 0.05),
                strokeColor: p.fg.withValues(alpha: 0.4),
                dashPattern: const DashPattern([5, 4]),
              ),
            ),
            if (!section.isEmpty)
              GeoPath3(
                section.toPoints3(),
                closed: true,
                style: ShapeStyle(
                  fillColor: p.amber.withValues(alpha: 0.55),
                  strokeColor: p.amber,
                  strokeWidth: 2.2,
                ),
              ),
          ],
        ),
        controls: [
          DemoSlider(
            label: 'Plane tilt',
            display: '${_tilt.toStringAsFixed(1)}°',
            value: _tilt,
            min: 0,
            max: 85,
            onChanged: (v) => setState(() => _tilt = v),
          ),
          DemoSlider(
            label: 'Plane height',
            display: _offset.toStringAsFixed(2),
            value: _offset,
            min: -0.9,
            max: 0.9,
            onChanged: (v) => setState(() => _offset = v),
          ),
        ],
        readouts: [
          Readout('Section', type, highlight: true),
          Readout(
            'Section area',
            section.isEmpty ? '–' : '${section.area.toStringAsFixed(3)} u²',
          ),
          Readout('Cone volume', '${_cone.volume.toStringAsFixed(3)} u³'),
        ],
      ),
    );
  }
}
