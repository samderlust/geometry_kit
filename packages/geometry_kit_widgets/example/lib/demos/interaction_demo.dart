import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class InteractionDemo extends StatefulWidget {
  const InteractionDemo({super.key});

  @override
  State<InteractionDemo> createState() => _InteractionDemoState();
}

class _InteractionDemoState extends State<InteractionDemo> {
  final Set<String> _hovered = {};
  final Map<String, int> _taps = {};
  String? _canvasHovered;
  String? _lastCanvasTap;

  // Paint order for the canvas demo: last id = topmost.
  List<String> _canvasOrder = const ['blue', 'orange', 'green'];

  void _bringToTop(String id) {
    setState(() {
      _canvasOrder = [..._canvasOrder.where((e) => e != id), id];
      _lastCanvasTap = id;
    });
  }

  void _bumpTap(String id) {
    setState(() => _taps[id] = (_taps[id] ?? 0) + 1);
  }

  StyledShape _buildCanvasShape(String id) {
    const layout = {
      'blue': (Color(0xFF1E88E5), Point(110, 110)),
      'orange': (Color(0xFFE65100), Point(180, 110)),
      'green': (Color(0xFF2E7D32), Point(145, 70)),
    };
    final (color, center) = layout[id]!;
    final isHover = _canvasHovered == id;
    return StyledShape(
      Circle(center: center, radius: 55),
      id: id,
      style: ShapeStyle(
        fillColor: isHover ? color : color.withValues(alpha: 0.65),
        strokeColor: Colors.white,
        strokeWidth: isHover ? 3 : 1,
      ),
      onTap: () => _bringToTop(id),
      onHoverChanged: (v) => setState(() => _canvasHovered = v ? id : null),
    );
  }

  ShapeStyle _styleFor(Color base, String id) {
    final isHover = _hovered.contains(id);
    return ShapeStyle(
      fillColor: isHover
          ? base.withValues(alpha: 1)
          : base.withValues(alpha: 0.6),
      strokeColor: Colors.white,
      strokeWidth: isHover ? 4 : 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        DemoCard(
          title: 'Standalone widgets',
          caption:
              'Each Geo* widget exposes onTap and onHoverChanged. Hit-test is '
              'shape-precise — taps in the widget rect but outside the shape '
              'outline are ignored. Hover styling here uses setState; pair '
              'with AnimatedShapeStyle for smooth transitions.',
          child: Center(
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GeoCircle.fromGeometry(
                      circle: const Circle(center: Point(60, 60), radius: 50),
                      size: const Size(120, 120),
                      style: _styleFor(Colors.indigo, 'circle'),
                      onTap: () => _bumpTap('circle'),
                      onHoverChanged: (v) => setState(() {
                        v ? _hovered.add('circle') : _hovered.remove('circle');
                      }),
                    ),
                    Text('circle  taps: ${_taps['circle'] ?? 0}'),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GeoTriangle(
                      a: const Offset(60, 8),
                      b: const Offset(112, 112),
                      c: const Offset(8, 112),
                      size: const Size(120, 120),
                      style: _styleFor(Colors.deepOrange, 'triangle'),
                      onTap: () => _bumpTap('triangle'),
                      onHoverChanged: (v) => setState(() {
                        v
                            ? _hovered.add('triangle')
                            : _hovered.remove('triangle');
                      }),
                    ),
                    Text('triangle  taps: ${_taps['triangle'] ?? 0}'),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GeoRectangle(
                      x: 12,
                      y: 12,
                      width: 96,
                      height: 96,
                      cornerRadius: const Radius.circular(16),
                      size: const Size(120, 120),
                      style: _styleFor(Colors.teal, 'rect'),
                      onTap: () => _bumpTap('rect'),
                      onHoverChanged: (v) => setState(() {
                        v ? _hovered.add('rect') : _hovered.remove('rect');
                      }),
                    ),
                    Text('rectangle  taps: ${_taps['rect'] ?? 0}'),
                  ],
                ),
              ],
            ),
          ),
        ),
        DemoCard(
          title: 'GeometryCanvas — tap brings shape to top',
          caption:
              'Per-StyledShape onTap and onHoverChanged. Tapping a shape '
              'reorders the paint list so the tapped id moves to the end '
              '(visually on top). Hover and tap dispatch always pick the '
              'topmost shape under the pointer.',
          child: Center(
            child: SizedBox(
              width: 300,
              height: 220,
              child: GeometryCanvas(
                size: const Size(300, 220),
                backgroundColor: const Color(0xFFF5F5FA),
                shapes: _canvasOrder
                    .map((id) => _buildCanvasShape(id))
                    .toList(growable: false),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 16,
            children: [
              Text('canvas hover: ${_canvasHovered ?? '—'}'),
              Text('last tap: ${_lastCanvasTap ?? '—'}'),
              Text('paint order (bottom→top): ${_canvasOrder.join(' → ')}'),
            ],
          ),
        ),
      ],
    );
  }
}
