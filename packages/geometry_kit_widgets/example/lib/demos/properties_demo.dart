import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

/// Showcases computed geometry properties — `contains`, `area`, `perimeter`,
/// `centroid`, `circumscribedCircle`, etc. Tap the canvas to set a probe
/// point and see which shapes contain it.
class PropertiesDemo extends StatefulWidget {
  const PropertiesDemo({super.key});

  @override
  State<PropertiesDemo> createState() => _PropertiesDemoState();
}

class _PropertiesDemoState extends State<PropertiesDemo> {
  Offset _probe = const Offset(160, 140);

  static const _size = Size(320, 280);

  static const _circle = Circle(center: Point(80, 100), radius: 60);

  static final _triangle = Triangle(
    const Point(180, 50),
    const Point(280, 220),
    const Point(140, 220),
  );

  static final _hex = Polygon.regular(
    sides: 6,
    radius: 60,
    center: const Point(80, 100),
  );

  @override
  Widget build(BuildContext context) {
    final probe = Point(_probe.dx, _probe.dy);
    final inCircle = _circle.contains(probe);
    final inTriangle = _triangle.contains(probe);
    final inHex = _hex.contains(probe);

    final probeColor = (inCircle || inTriangle || inHex)
        ? Colors.green
        : Colors.red;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Tap inside the canvas to probe shape containment.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTapDown: (d) {
            final dx = d.localPosition.dx.clamp(0.0, _size.width);
            final dy = d.localPosition.dy.clamp(0.0, _size.height);
            setState(() => _probe = Offset(dx, dy));
          },
          child: Stack(
            children: [
              GeometryCanvas(
                size: _size,
                backgroundColor: Colors.white,
                shapes: [
                  StyledShape(
                    _circle,
                    style: ShapeStyle(
                      fillColor: Colors.indigo.withValues(alpha: 0.4),
                      strokeColor: Colors.indigo,
                      strokeWidth: 2,
                    ),
                  ),
                  StyledShape(
                    _triangle,
                    style: ShapeStyle(
                      fillColor: Colors.deepOrange.withValues(alpha: 0.4),
                      strokeColor: Colors.deepOrange,
                      strokeWidth: 2,
                    ),
                  ),
                  StyledShape(
                    _hex,
                    style: const ShapeStyle.stroked(Colors.purple, width: 2),
                  ),
                ],
              ),
              Positioned(
                left: _probe.dx - 6,
                top: _probe.dy - 6,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: probeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section('Probe @ (${_probe.dx.toStringAsFixed(0)}, ${_probe.dy.toStringAsFixed(0)})'),
        _Row('circle.contains', '$inCircle'),
        _Row('triangle.contains', '$inTriangle'),
        _Row('hex.contains', '$inHex'),
        const SizedBox(height: 16),
        _Section('Circle'),
        _Row('area', _circle.area.toStringAsFixed(2)),
        _Row('perimeter', _circle.perimeter.toStringAsFixed(2)),
        _Row('diameter', _circle.diameter.toStringAsFixed(2)),
        _Row('circumference', _circle.circumference.toStringAsFixed(2)),
        const SizedBox(height: 16),
        _Section('Triangle'),
        _Row('area', _triangle.area.toStringAsFixed(2)),
        _Row('perimeter', _triangle.perimeter.toStringAsFixed(2)),
        _Row('centroid',
            '(${_triangle.centroid.x.toStringAsFixed(1)}, ${_triangle.centroid.y.toStringAsFixed(1)})'),
        _Row('isAcute', '${_triangle.isAcute}'),
        _Row('isObtuse', '${_triangle.isObtuse}'),
        _Row('isEquilateral', '${_triangle.isEquilateral}'),
        _Row('isIsosceles', '${_triangle.isIsosceles}'),
        const SizedBox(height: 16),
        _Section('Hexagon (Polygon.regular)'),
        _Row('area', _hex.area.toStringAsFixed(2)),
        _Row('perimeter', _hex.perimeter.toStringAsFixed(2)),
        _Row('isConvex', '${_hex.isConvex}'),
        _Row('vertices', '${_hex.vertices.length}'),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
