import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

/// Showcases geometry_kit's transform methods (rotate / scale / translate)
/// and computed properties (area, perimeter, classification, centroid).
///
/// All transforms in geometry_kit rotate/scale around the origin (0, 0).
/// To pivot around an arbitrary point, compose
/// `translate(-pivot)` → `rotate(deg)` → `translate(+pivot)`.
class TransformsDemo extends StatefulWidget {
  const TransformsDemo({super.key});

  @override
  State<TransformsDemo> createState() => _TransformsDemoState();
}

class _TransformsDemoState extends State<TransformsDemo> {
  double _rotation = 0;
  double _scale = 1.0;
  double _tx = 0;
  double _ty = 0;

  static final _baseTriangle = Triangle(
    const Point(0, -60),
    const Point(52, 30),
    const Point(-52, 30),
  );

  static const _canvasSize = Size(280, 280);
  static const _centerPoint = Point(140, 140);

  Triangle get _transformedTriangle {
    // Pivot rotate + scale around centroid (origin in base coords),
    // then translate into widget center, then apply user translation.
    final t = _baseTriangle
        .rotate(_rotation)
        .scale(_scale)
        .translate(x: _centerPoint.x + _tx, y: _centerPoint.y + _ty);
    return t;
  }

  Polygon get _transformedHex {
    final base = Polygon.regular(
      sides: 6,
      radius: 60,
      center: const Point(0, 0),
    );
    return base
        .rotate(_rotation)
        .scale(_scale)
        .translate(x: _centerPoint.x + _tx, y: _centerPoint.y + _ty);
  }

  @override
  Widget build(BuildContext context) {
    final tri = _transformedTriangle;
    final hex = _transformedHex;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        DemoCard(
          title: 'Triangle.rotate / scale / translate',
          caption: 'Composed via translate→rotate→translate to pivot in place',
          child: GeoTriangle.fromGeometry(
            triangle: tri,
            style: const ShapeStyle(
              fillColor: Colors.deepOrange,
              strokeColor: Colors.black,
              strokeWidth: 2,
              opacity: 0.85,
            ),
            size: _canvasSize,
          ),
        ),
        _PropertyRow('area', tri.area.toStringAsFixed(1)),
        _PropertyRow('perimeter', tri.perimeter.toStringAsFixed(1)),
        _PropertyRow(
            'centroid', '(${tri.centroid.x.toStringAsFixed(1)}, ${tri.centroid.y.toStringAsFixed(1)})'),
        _PropertyRow('isAcute', '${tri.isAcute}'),
        _PropertyRow('isRight', '${tri.isRightTriangle}'),
        _PropertyRow('isObtuse', '${tri.isObtuse}'),
        const SizedBox(height: 16),
        DemoCard(
          title: 'Polygon.regular(6).rotate(deg)',
          caption: 'Same transforms applied to a regular hexagon',
          child: GeoPolygon.fromGeometry(
            polygon: hex,
            style: const ShapeStyle(
              fillColor: Colors.indigo,
              strokeColor: Colors.black,
              strokeWidth: 2,
              opacity: 0.85,
            ),
            size: _canvasSize,
          ),
        ),
        _PropertyRow('area', hex.area.toStringAsFixed(1)),
        _PropertyRow('perimeter', hex.perimeter.toStringAsFixed(1)),
        _PropertyRow('isConvex', '${hex.isConvex}'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Slider(
                label: 'rotate (deg)',
                value: _rotation,
                min: 0,
                max: 360,
                display: _rotation.toStringAsFixed(0),
                onChanged: (v) => setState(() => _rotation = v),
              ),
              _Slider(
                label: 'scale',
                value: _scale,
                min: 0.3,
                max: 2.0,
                display: _scale.toStringAsFixed(2),
                onChanged: (v) => setState(() => _scale = v),
              ),
              _Slider(
                label: 'translate x',
                value: _tx,
                min: -80,
                max: 80,
                display: _tx.toStringAsFixed(0),
                onChanged: (v) => setState(() => _tx = v),
              ),
              _Slider(
                label: 'translate y',
                value: _ty,
                min: -80,
                max: 80,
                display: _ty.toStringAsFixed(0),
                onChanged: (v) => setState(() => _ty = v),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _rotation = 0;
                    _scale = 1;
                    _tx = 0;
                    _ty = 0;
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('reset'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final String value;

  const _PropertyRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  final String label;
  final String display;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _Slider({
    required this.label,
    required this.display,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(display, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
