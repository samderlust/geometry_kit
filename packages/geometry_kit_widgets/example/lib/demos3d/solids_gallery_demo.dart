import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_kit.dart';

/// Extra — a tour of every solid with transforms, bounds and mesh accuracy.
class SolidsGalleryDemo extends StatefulWidget {
  const SolidsGalleryDemo({super.key});

  @override
  State<SolidsGalleryDemo> createState() => _SolidsGalleryDemoState();
}

class _SolidsGalleryDemoState extends State<SolidsGalleryDemo> {
  static final Map<String, Solid> _solids = {
    'Sphere': const Sphere(center: Point3.zero, radius: 1),
    'Box': const Box(center: Point3.zero, width: 1.6, height: 1.1, depth: 1.2),
    'Cylinder': Cylinder(
      baseCenter: const Point3(0, -0.9, 0),
      radius: 0.75,
      height: 1.8,
    ),
    'Cone': Cone(
      baseCenter: const Point3(0, -0.9, 0),
      radius: 0.9,
      height: 1.9,
    ),
    'Prism': Prism.extrude(
      Polygon.regular(sides: 6, radius: 0.9, center: const Point(0, 0)),
      height: 1.4,
      frame: const PlaneFrame(
        Point3(0, -0.7, 0),
        Point3.unitX,
        Point3(0, 0, -1),
      ),
    ),
    'Goblet': SolidOfRevolution(
      Spline(const [
        Point(0.7, 0),
        Point(0.15, 0.25),
        Point(0.12, 0.9),
        Point(0.8, 1.4),
        Point(0.9, 1.9),
      ]).sample(40),
      origin: const Point3(0, -0.95, 0),
    ),
  };

  String _name = 'Cone';
  double _turn = 0;
  double _tilt = 20;
  double _scale = 1;
  double _segments = 24;
  bool _bounds = true;
  bool _edges = true;

  static const _code =
      '''Solid solid = Cone(baseCenter: Point3(0, -0.9, 0), radius: 0.9, height: 1.9);

// Immutable transforms return new solids.
solid = solid
    .rotate(Point3.unitX, 20)
    .rotate(Point3.unitY, 45)
    .scale(1.2);

print(solid.volume);        // exact
print(solid.surfaceArea);   // exact
print(solid.bounds);        // Aabb for broad-phase checks

final mesh = solid.toMesh(segments: 24);
print(mesh.volume);         // approaches solid.volume as segments grow
print(mesh.triangleCount);''';

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    final solid = _solids[_name]!
        .rotate(Point3.unitX, _tilt)
        .rotate(Point3.unitY, _turn)
        .scale(_scale);
    final seg = _segments.round();
    final mesh = solid.toMesh(segments: seg);
    final error = (mesh.volume - solid.volume) / solid.volume * 100;

    return Demo3dPage(
      code: _code,
      demo: DemoPanel(
        label: '$_name · ${mesh.triangleCount} triangles',
        hint: 'drag to orbit',
        scene: ZoomScene(
          camera: const OrbitCamera(yaw: 30, pitch: 22, distance: 6.5),
          builder: (camera, onCameraChanged) => GeoScene(
            camera: camera,
            onCameraChanged: onCameraChanged,
            children: [
              ...p.grid3(extent: 2, step: 0.5, y: -1.6),
              GeoSolid(
                solid,
                segments: seg,
                style: ShapeStyle(
                  fillColor: p.accent,
                  strokeColor: _edges
                      ? Color.lerp(p.accent, Colors.black, 0.5)
                      : null,
                ),
              ),
              if (_bounds) ...aabbEdges(solid.bounds, p.amber),
            ],
          ),
        ),
        controls: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final n in _solids.keys)
                  ChoiceChip(
                    label: Text(n),
                    selected: n == _name,
                    selectedColor: p.accent.withValues(alpha: 0.18),
                    onSelected: (_) => setState(() => _name = n),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DemoSlider(
            label: 'Turn around Y',
            display: '${_turn.round()}°',
            value: _turn,
            min: 0,
            max: 360,
            onChanged: (v) => setState(() => _turn = v),
          ),
          DemoSlider(
            label: 'Tilt around X',
            display: '${_tilt.round()}°',
            value: _tilt,
            min: -90,
            max: 90,
            onChanged: (v) => setState(() => _tilt = v),
          ),
          DemoSlider(
            label: 'Scale',
            display: '×${_scale.toStringAsFixed(2)}',
            value: _scale,
            min: 0.5,
            max: 1.4,
            onChanged: (v) => setState(() => _scale = v),
          ),
          DemoSlider(
            label: 'Mesh segments',
            display: '$seg',
            value: _segments,
            min: 4,
            max: 64,
            divisions: 60,
            onChanged: (v) => setState(() => _segments = v),
          ),
          Row(
            children: [
              Expanded(
                child: DemoToggle(
                  label: 'Bounding box',
                  value: _bounds,
                  onChanged: (v) => setState(() => _bounds = v),
                ),
              ),
              Expanded(
                child: DemoToggle(
                  label: 'Sharp edges',
                  value: _edges,
                  onChanged: (v) => setState(() => _edges = v),
                ),
              ),
            ],
          ),
        ],
        readouts: [
          Readout('Volume', solid.volume.toStringAsFixed(3), highlight: true),
          Readout('Mesh volume', mesh.volume.toStringAsFixed(3)),
          Readout('Mesh error', '${error.toStringAsFixed(2)} %'),
          Readout('Surface', solid.surfaceArea.toStringAsFixed(3)),
        ],
      ),
    );
  }
}
