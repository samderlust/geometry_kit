import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_kit.dart';

/// Extra — draw a floor plan with the 2D widgets, see it extruded in 3D.
class DrawExtrudeDemo extends StatefulWidget {
  const DrawExtrudeDemo({super.key});

  @override
  State<DrawExtrudeDemo> createState() => _DrawExtrudeDemoState();
}

class _DrawExtrudeDemoState extends State<DrawExtrudeDemo> {
  /// Plan extent in metres: the 2D pad covers −4…4 on both axes.
  static const _half = 4.0;

  static const _sample = [
    Point(-3, -2),
    Point(1, -2),
    Point(1, -0.5),
    Point(3, -0.5),
    Point(3, 2.5),
    Point(-3, 2.5),
  ];

  List<Point> _points = List.of(_sample);
  double _height = 2.5;

  static const _code =
      '''// Taps on a GeometryCanvas become 2D Points (Y-up, metres).
final plan = Polygon(points);

GeometryCanvas(
  size: padSize,
  shapes: [StyledShape(plan, style: ShapeStyle(fillColor: tint))],
);

// The same Polygon goes straight into 3D.
final room = Prism.extrude(plan, height: 2.5);

GeoScene(children: [GeoSolid(room)]);

print(plan.area);        // m²   (2D)
print(plan.isConvex);    //      (2D)
print(room.volume);      // m³   (3D)''';

  Point _toPlan(Offset o, double side) => Point(
    o.dx / side * 2 * _half - _half,
    (1 - o.dy / side) * 2 * _half - _half,
  );

  Point _toPad(Point q, double side) => Point(
    (q.x + _half) / (2 * _half) * side,
    (1 - (q.y + _half) / (2 * _half)) * side,
  );

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    final plan = _points.length >= 3 ? Polygon(_points) : null;
    final room = plan == null ? null : Prism.extrude(plan, height: _height);

    return Demo3dPage(
      code: _code,
      demo: DemoPanel(
        label: room == null
            ? 'Add ${3 - _points.length} more corner(s)'
            : 'Prism.extrude(plan)',
        hint: 'drag to orbit',
        scene: GeoScene(
          camera: const OrbitCamera(yaw: 25, pitch: 38, distance: 15),
          children: [
            ...p.grid3(extent: _half, step: 1),
            for (final q in _points)
              GeoPath3([
                PlaneFrame.ground.toWorld(q),
                PlaneFrame.ground.toWorld(q).translate(y: 0.15),
              ], style: ShapeStyle.stroked(p.amber, width: 3)),
            if (room != null)
              GeoSolid(
                room,
                style: ShapeStyle(
                  fillColor: p.teal,
                  opacity: 0.85,
                  strokeColor: Color.lerp(p.teal, Colors.black, 0.5),
                ),
              ),
          ],
        ),
        controls: [
          LayoutBuilder(
            builder: (context, c) {
              final side = c.maxWidth.clamp(0.0, 320.0);
              return Column(
                children: [
                  GestureDetector(
                    onTapUp: (d) => setState(() {
                      _points = [..._points, _toPlan(d.localPosition, side)];
                    }),
                    child: Container(
                      width: side,
                      height: side,
                      decoration: BoxDecoration(
                        border: Border.all(color: p.line),
                        color: p.codeBg,
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(side, side),
                            painter: _PadGrid(p.line, 2 * _half),
                          ),
                          GeometryCanvas(
                            size: Size(side, side),
                            shapes: [
                              if (plan != null)
                                StyledShape(
                                  Polygon([
                                    for (final q in _points) _toPad(q, side),
                                  ]),
                                  style: ShapeStyle(
                                    fillColor: p.teal.withValues(alpha: 0.25),
                                    strokeColor: p.teal,
                                    strokeWidth: 2,
                                  ),
                                ),
                              for (final q in _points)
                                StyledShape(
                                  Circle(radius: 4, center: _toPad(q, side)),
                                  style: ShapeStyle.filled(p.amber),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _points.isEmpty
                            ? null
                            : () => setState(
                                () => _points = _points.sublist(
                                  0,
                                  _points.length - 1,
                                ),
                              ),
                        child: const Text('Undo'),
                      ),
                      OutlinedButton(
                        onPressed: () => setState(() => _points = []),
                        child: const Text('Clear'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            setState(() => _points = List.of(_sample)),
                        child: const Text('Sample plan'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          DemoSlider(
            label: 'Wall height',
            display: '${_height.toStringAsFixed(2)} m',
            value: _height,
            min: 0.5,
            max: 4,
            onChanged: (v) => setState(() => _height = v),
          ),
        ],
        readouts: [
          Readout('Corners', '${_points.length}'),
          Readout(
            'Floor area',
            plan == null ? '–' : '${plan.area.toStringAsFixed(2)} m²',
          ),
          Readout(
            'Volume',
            room == null ? '–' : '${room.volume.toStringAsFixed(2)} m³',
            highlight: true,
          ),
          Readout(
            'Convex',
            plan == null ? '–' : (plan.isConvex ? 'yes' : 'no'),
          ),
        ],
      ),
    );
  }
}

class _PadGrid extends CustomPainter {
  final Color color;
  final double cells;
  _PadGrid(this.color, this.cells);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var i = 1; i < cells; i++) {
      final t = size.width * i / cells;
      canvas.drawLine(Offset(t, 0), Offset(t, size.height), paint);
      canvas.drawLine(Offset(0, t), Offset(size.width, t), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PadGrid old) =>
      old.color != color || old.cells != cells;
}
