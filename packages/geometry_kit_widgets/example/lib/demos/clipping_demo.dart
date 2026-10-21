import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

class ClippingDemo extends StatelessWidget {
  const ClippingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionTitle('clipBehavior: Clip.hardEdge vs Clip.none'),
        SizedBox(height: 8),
        Text(
          'Both widgets are 100×100. Each draws a circle of radius 90 centered '
          'at (50, 50) — the circle naturally extends past the widget rect.',
        ),
        SizedBox(height: 16),
        _ClipComparison(),
        SizedBox(height: 32),
        _SectionTitle('Standalone Geo* widget in a Stack'),
        SizedBox(height: 8),
        Text(
          'Geo* widgets are normal Flutter widgets — drop them in any layout. '
          'They stack with other content; transparent regions let the layer '
          'below show through.',
        ),
        SizedBox(height: 16),
        _StackDemo(),
        SizedBox(height: 32),
        _SectionTitle('GeometryCanvas with transparent background'),
        SizedBox(height: 8),
        Text(
          'backgroundColor: null (default) keeps the canvas transparent so '
          'widgets stacked underneath remain visible.',
        ),
        SizedBox(height: 16),
        _TransparentCanvas(),
        SizedBox(height: 32),
        _SectionTitle('ShapeWidget — clip arbitrary widgets to shape'),
        SizedBox(height: 8),
        Text(
          'ShapeWidget hosts any child widget clipped to a geometry shape, '
          'with an optional ShapeStyle overlay for outline / fill on top.',
        ),
        SizedBox(height: 16),
        _ShapeWidgetDemo(),
        SizedBox(height: 32),
        _SectionTitle('Image clipped to a live polygon'),
        SizedBox(height: 8),
        Text(
          'Slider rebuilds the polygon vertex count; ShapeWidget reclips '
          'the image content on each frame. Reset via the rotation slider '
          'to see how vertex placement around the perimeter feels.',
        ),
        SizedBox(height: 16),
        _ImageClipPlayground(),
      ],
    );
  }
}

class _ShapeWidgetDemo extends StatelessWidget {
  const _ShapeWidgetDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        // Gradient inside a circle, with a white stroke ring.
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShapeWidget(
              shape: const Circle(center: Point(60, 60), radius: 60),
              size: const Size(120, 120),
              style: const ShapeStyle.stroked(Colors.white, width: 3),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.indigo, Colors.cyan, Colors.amber],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Gradient + stroke'),
          ],
        ),
        // Text clipped to a triangle.
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShapeWidget(
              shape: Triangle(
                const Point(60, 5),
                const Point(115, 115),
                const Point(5, 115),
              ),
              size: const Size(120, 120),
              style: const ShapeStyle.stroked(Colors.deepOrange, width: 2),
              child: Container(
                color: Colors.amber.shade200,
                alignment: Alignment.center,
                child: const Text(
                  'LAB',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Text in triangle'),
          ],
        ),
        // Polygon clip over a colored grid.
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShapeWidget(
              shape: Polygon(const [
                Point(60, 5),
                Point(115, 40),
                Point(95, 110),
                Point(25, 110),
                Point(5, 40),
              ]),
              size: const Size(120, 120),
              style: const ShapeStyle(
                fillColor: null,
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
              child: GridPaper(
                color: Colors.white24,
                interval: 12,
                divisions: 1,
                subdivisions: 1,
                child: Container(color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Pentagon over grid'),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _ClipComparison extends StatelessWidget {
  const _ClipComparison();

  @override
  Widget build(BuildContext context) {
    const widgetSize = Size(100, 100);

    Widget framed(Widget child, String label) {
      return Column(
        children: [
          // Generous padding around widget so Clip.none overflow is visible.
          Container(
            padding: const EdgeInsets.all(60),
            color: Colors.amber.shade50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: child,
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: framed(
            GeoCircle(
              radius: 90,
              center: const Offset(50, 50),
              style: const ShapeStyle.filled(Colors.indigo),
              size: widgetSize,
              // default Clip.hardEdge
            ),
            'Clip.hardEdge (default)\nstays inside red box',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: framed(
            GeoCircle(
              radius: 90,
              center: const Offset(50, 50),
              style: const ShapeStyle.filled(Colors.indigo),
              size: widgetSize,
              clipBehavior: Clip.none,
            ),
            'Clip.none\nbleeds past red box',
          ),
        ),
      ],
    );
  }
}

class _StackDemo extends StatelessWidget {
  const _StackDemo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 200,
      color: Colors.amber.shade100,
      child: Stack(
        children: [
          const Positioned(
            left: 8,
            bottom: 8,
            child: Text('amber background widget'),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: GeoCircle(
              radius: 50,
              center: const Offset(60, 60),
              style: const ShapeStyle.filled(Colors.indigo),
              size: const Size(120, 120),
            ),
          ),
          Positioned(
            right: 20,
            top: 30,
            child: GeoTriangle(
              a: const Offset(60, 10),
              b: const Offset(110, 110),
              c: const Offset(10, 110),
              style: const ShapeStyle.filled(Colors.deepOrange),
              size: const Size(120, 120),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransparentCanvas extends StatelessWidget {
  const _TransparentCanvas();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 200,
      child: Stack(
        children: [
          Container(
            color: Colors.amber.shade100,
            alignment: Alignment.center,
            child: const Text('layer below the canvas'),
          ),
          GeometryCanvas(
            size: const Size(280, 200),
            shapes: [
              StyledShape(
                const Circle(center: Point(80, 100), radius: 50),
                style: const ShapeStyle(
                  fillColor: Colors.indigo,
                  opacity: 0.6,
                ),
              ),
              StyledShape(
                const Circle(center: Point(200, 100), radius: 50),
                style: const ShapeStyle(
                  fillColor: Colors.deepOrange,
                  opacity: 0.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageClipPlayground extends StatefulWidget {
  const _ImageClipPlayground();

  @override
  State<_ImageClipPlayground> createState() => _ImageClipPlaygroundState();
}

class _ImageClipPlaygroundState extends State<_ImageClipPlayground> {
  static const _size = Size(240, 240);

  int _vertices = 6;
  double _rotationDeg = 0;
  bool _showStroke = true;
  _ImageSource _source = _ImageSource.network;

  Polygon _regularPolygon() {
    final cx = _size.width / 2;
    final cy = _size.height / 2;
    final r = math.min(cx, cy) - 4;
    final start = _rotationDeg * math.pi / 180 - math.pi / 2;
    return Polygon(
      List<Point>.generate(_vertices, (i) {
        final a = start + (2 * math.pi * i) / _vertices;
        return Point(cx + r * math.cos(a), cy + r * math.sin(a));
      }),
    );
  }

  Widget _imageWidget() {
    switch (_source) {
      case _ImageSource.flutterLogo:
        return Container(
          color: Colors.indigo.shade50,
          alignment: Alignment.center,
          child: const FlutterLogo(size: 220),
        );
      case _ImageSource.gradient:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple,
                Colors.pink,
                Colors.amber,
                Colors.cyan,
              ],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'GRADIENT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        );
      case _ImageSource.network:
        return Image.network(
          'https://picsum.photos/seed/geometry_kit/480/480',
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.black12,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          },
          errorBuilder: (ctx, err, stack) => Container(
            color: Colors.red.shade100,
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Image failed to load.\nPick another source.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final polygon = _regularPolygon();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
            ),
            child: ShapeWidget(
              shape: polygon,
              size: _size,
              style: _showStroke
                  ? const ShapeStyle(
                      fillColor: null,
                      strokeColor: Colors.white,
                      strokeWidth: 3,
                    )
                  : null,
              child: _imageWidget(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(width: 80, child: Text('Vertices')),
            Expanded(
              child: Slider(
                value: _vertices.toDouble(),
                min: 3,
                max: 24,
                divisions: 21,
                label: '$_vertices',
                onChanged: (v) => setState(() => _vertices = v.round()),
              ),
            ),
            SizedBox(width: 32, child: Text('$_vertices')),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 80, child: Text('Rotation')),
            Expanded(
              child: Slider(
                value: _rotationDeg,
                min: 0,
                max: 360,
                divisions: 72,
                label: '${_rotationDeg.round()}°',
                onChanged: (v) => setState(() => _rotationDeg = v),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text('${_rotationDeg.round()}°'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Source'),
            for (final s in _ImageSource.values)
              ChoiceChip(
                label: Text(s.label),
                selected: _source == s,
                onSelected: (_) => setState(() => _source = s),
              ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Stroke'),
              selected: _showStroke,
              onSelected: (v) => setState(() => _showStroke = v),
            ),
          ],
        ),
      ],
    );
  }
}

enum _ImageSource {
  network('Network photo'),
  flutterLogo('Flutter logo'),
  gradient('Gradient');

  const _ImageSource(this.label);
  final String label;
}
