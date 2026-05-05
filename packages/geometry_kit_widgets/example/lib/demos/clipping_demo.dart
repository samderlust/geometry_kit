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
