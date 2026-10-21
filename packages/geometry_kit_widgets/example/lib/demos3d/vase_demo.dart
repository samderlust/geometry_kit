import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_kit.dart';

/// Use 5 — meshes from code: revolve a 2D spline into a vase.
class VaseDemo extends StatefulWidget {
  const VaseDemo({super.key});

  @override
  State<VaseDemo> createState() => _VaseDemoState();
}

class _VaseDemoState extends State<VaseDemo> {
  double _belly = 0.85;
  double _neck = 0.32;
  double _lip = 0.5;
  double _segments = 32;

  static const _code = '''final profile = Spline([
  Point(0.55, 0),
  Point(belly, 0.7),
  Point(neck, 1.5),
  Point(lip, 1.9),
]);

final vase = SolidOfRevolution(profile.sample(48));

print(vase.volume); // dm³, so litres

final mesh = vase.toMesh(segments: 32);
// mesh.positionsFloat32 / mesh.indicesUint32 → flutter_gpu buffers,
// or export for Blender and slicers:
File('vase.stl').writeAsStringSync(mesh.toStl(name: 'vase'));''';

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    // Units are decimetres, so volume reads in litres.
    final controls = [
      const Point(0.55, 0),
      Point(_belly, 0.7),
      Point(_neck, 1.5),
      Point(_lip, 1.9),
    ];
    final profile = Spline(controls).sample(48);
    final vase = SolidOfRevolution(profile, origin: const Point3(0, -0.95, 0));
    final mesh = vase.toMesh(segments: _segments.round());

    Future<void> copy(String label, String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied ${mesh.triangleCount} triangles as $label'),
        ),
      );
    }

    return Demo3dPage(
      code: _code,
      demo: DemoPanel(
        label: 'SolidOfRevolution',
        hint: 'drag to orbit',
        scene: Stack(
          children: [
            Positioned.fill(
              child: GeoScene(
                camera: const OrbitCamera(yaw: 25, pitch: 22, distance: 5.6),
                children: [
                  ...p.grid3(extent: 1.5, step: 0.5, y: -0.95),
                  GeoSolid(
                    vase,
                    segments: _segments.round(),
                    style: ShapeStyle(fillColor: p.teal, strokeColor: null),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              width: 96,
              height: 128,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ProfileInset(profile, controls, p),
                ),
              ),
            ),
          ],
        ),
        controls: [
          DemoSlider(
            label: 'Belly radius',
            display: _belly.toStringAsFixed(2),
            value: _belly,
            min: 0.5,
            max: 1.1,
            onChanged: (v) => setState(() => _belly = v),
          ),
          DemoSlider(
            label: 'Neck radius',
            display: _neck.toStringAsFixed(2),
            value: _neck,
            min: 0.18,
            max: 0.6,
            onChanged: (v) => setState(() => _neck = v),
          ),
          DemoSlider(
            label: 'Lip radius',
            display: _lip.toStringAsFixed(2),
            value: _lip,
            min: 0.25,
            max: 0.8,
            onChanged: (v) => setState(() => _lip = v),
          ),
          DemoSlider(
            label: 'Segments',
            display: '${_segments.round()}',
            value: _segments,
            min: 6,
            max: 64,
            divisions: 58,
            onChanged: (v) => setState(() => _segments = v),
          ),
        ],
        readouts: [
          Readout(
            'Volume',
            '${vase.volume.toStringAsFixed(2)} L',
            highlight: true,
          ),
          Readout('Surface', '${vase.surfaceArea.toStringAsFixed(2)} dm²'),
          Readout('Vertices', '${mesh.vertexCount}'),
          Readout('Triangles', '${mesh.triangleCount}'),
        ],
        footer: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy STL'),
                onPressed: () => copy('STL', mesh.toStl(name: 'vase')),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy OBJ'),
                onPressed: () => copy('OBJ', mesh.toObj(name: 'vase')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small 2D panel showing the spline profile and its control points.
class _ProfileInset extends CustomPainter {
  final List<Point> profile;
  final List<Point> controls;
  final DemoPalette p;
  _ProfileInset(this.profile, this.controls, this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = p.surface.withValues(alpha: 0.92));
    canvas.drawRect(
      r,
      Paint()
        ..color = p.line
        ..style = PaintingStyle.stroke,
    );
    final sc = (size.height - 20) / 2.0;
    Offset map(Point q) => Offset(12 + q.x * sc, size.height - 10 - q.y * sc);

    final axis = Paint()
      ..color = p.muted
      ..strokeWidth = 1;
    for (var y = 6.0; y < size.height - 6; y += 6) {
      canvas.drawLine(Offset(12, y), Offset(12, y + 3), axis);
    }
    final path = Path()
      ..moveTo(map(const Point(0, 0)).dx, map(const Point(0, 0)).dy);
    for (final q in profile) {
      final o = map(q);
      path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = p.teal
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    for (final c in controls) {
      canvas.drawCircle(map(c), 3, Paint()..color = p.amber);
    }
    final tp = TextPainter(
      text: TextSpan(
        text: '2D SPLINE',
        style: p.mono(9, color: p.muted),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(6, 4));
  }

  @override
  bool shouldRepaint(covariant _ProfileInset old) =>
      old.profile != profile || old.p != p;
}
