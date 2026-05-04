import 'package:flutter/material.dart';

import 'demos/canvas_demo.dart';
import 'demos/circle_demo.dart';
import 'demos/coordinate_mapper_demo.dart';
import 'demos/ellipse_demo.dart';
import 'demos/line_demo.dart';
import 'demos/polygon_demo.dart';
import 'demos/quadrilateral_demo.dart';
import 'demos/rectangle_demo.dart';
import 'demos/style_demo.dart';
import 'demos/triangle_demo.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'geometry_kit_widgets',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const _Home(),
    );
  }
}

class _Demo {
  final String title;
  final String subtitle;
  final WidgetBuilder builder;
  const _Demo(this.title, this.subtitle, this.builder);
}

final _demos = <_Demo>[
  _Demo('GeoCircle', 'Stroked, filled, dashed circles', (_) => const CircleDemo()),
  _Demo('GeoEllipse', 'Axis-aligned ellipses', (_) => const EllipseDemo()),
  _Demo('GeoRectangle', 'Rectangles with rounded corners', (_) => const RectangleDemo()),
  _Demo('GeoTriangle', 'Triangle from 3 vertices', (_) => const TriangleDemo()),
  _Demo('GeoQuadrilateral', 'Trapezoid / kite / rhombus', (_) => const QuadrilateralDemo()),
  _Demo('GeoPolygon', 'Regular and free-form polygons', (_) => const PolygonDemo()),
  _Demo('GeoLine', 'Line segments + dashes', (_) => const LineDemo()),
  _Demo('GeometryCanvas', 'Multi-shape rendering', (_) => const CanvasDemo()),
  _Demo('ShapeStyleTheme', 'Inherited default style', (_) => const StyleDemo()),
  _Demo('CoordinateMapper', 'Y-up + centered origins', (_) => const CoordinateMapperDemo()),
];

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('geometry_kit_widgets')),
      body: ListView.separated(
        itemCount: _demos.length,
        separatorBuilder: (_, _) => const Divider(height: 0),
        itemBuilder: (context, i) {
          final d = _demos[i];
          return ListTile(
            title: Text(d.title),
            subtitle: Text(d.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => Scaffold(
                    appBar: AppBar(title: Text(d.title)),
                    body: SafeArea(child: d.builder(ctx)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
