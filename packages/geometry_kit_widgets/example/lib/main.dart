import 'package:flutter/material.dart';

import 'demos/canvas_demo.dart';
import 'demos/circle_demo.dart';
import 'demos/clipping_demo.dart';
import 'demos/coordinate_mapper_demo.dart';
import 'demos/ellipse_demo.dart';
import 'demos/line_demo.dart';
import 'demos/polygon_demo.dart';
import 'demos/properties_demo.dart';
import 'demos/quadrilateral_demo.dart';
import 'demos/rectangle_demo.dart';
import 'demos/style_demo.dart';
import 'demos/transforms_demo.dart';
import 'demos/triangle_demo.dart';
import 'demos3d/bar_chart_demo.dart';
import 'demos3d/cone_slice_demo.dart';
import 'demos3d/draw_extrude_demo.dart';
import 'demos3d/editor_demo.dart';
import 'demos3d/picking_demo.dart';
import 'demos3d/room_demo.dart';
import 'demos3d/solids_gallery_demo.dart';
import 'demos3d/vase_demo.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'geometry_kit_widgets',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
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
  _Demo(
    'GeoCircle',
    'Stroked, filled, dashed circles',
    (_) => const CircleDemo(),
  ),
  _Demo('GeoEllipse', 'Axis-aligned ellipses', (_) => const EllipseDemo()),
  _Demo(
    'GeoRectangle',
    'Rectangles with rounded corners',
    (_) => const RectangleDemo(),
  ),
  _Demo('GeoTriangle', 'Triangle from 3 vertices', (_) => const TriangleDemo()),
  _Demo(
    'GeoQuadrilateral',
    'Trapezoid / kite / rhombus',
    (_) => const QuadrilateralDemo(),
  ),
  _Demo(
    'GeoPolygon',
    'Regular and free-form polygons',
    (_) => const PolygonDemo(),
  ),
  _Demo('GeoLine', 'Line segments + dashes', (_) => const LineDemo()),
  _Demo('GeometryCanvas', 'Multi-shape rendering', (_) => const CanvasDemo()),
  _Demo('ShapeStyleTheme', 'Inherited default style', (_) => const StyleDemo()),
  _Demo(
    'CoordinateMapper',
    'Y-up + centered origins',
    (_) => const CoordinateMapperDemo(),
  ),
  _Demo(
    'Clipping & layering',
    'clipBehavior + Stack composition',
    (_) => const ClippingDemo(),
  ),
  _Demo(
    'Transforms',
    'rotate / scale / translate (interactive)',
    (_) => const TransformsDemo(),
  ),
  _Demo(
    'Properties & contains',
    'area / perimeter / centroid / contains',
    (_) => const PropertiesDemo(),
  ),
];

final _demos3d = <_Demo>[
  _Demo(
    'Solids',
    'Every Solid: transforms, bounds, mesh accuracy',
    (_) => const SolidsGalleryDemo(),
  ),
  _Demo(
    'Cone slice',
    'Cone.slice(plane) → conic section',
    (_) => const ConeSliceDemo(),
  ),
  _Demo(
    'Bar chart',
    'GeoScene with hover and tap picking',
    (_) => const BarChartDemo(),
  ),
  _Demo(
    'Room',
    'Prism.extrude(floor plan) + measurements',
    (_) => const RoomDemo(),
  ),
  _Demo(
    'Draw and extrude',
    'GeometryCanvas plan → Prism in GeoScene',
    (_) => const DrawExtrudeDemo(),
  ),
  _Demo(
    'Picking & contact',
    'Ray picking, drag to move, Sphere.intersects',
    (_) => const PickingDemo(),
  ),
  _Demo(
    'Vase',
    'SolidOfRevolution(spline) + STL / OBJ export',
    (_) => const VaseDemo(),
  ),
  _Demo(
    'Editor',
    'Select, move, undo with geometry_kit_editor',
    (_) => const EditorDemo(),
  ),
];

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('geometry_kit_widgets'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '2D'),
              Tab(text: '3D'),
            ],
          ),
        ),
        body: TabBarView(children: [_DemoList(_demos), _DemoList(_demos3d)]),
      ),
    );
  }
}

class _DemoList extends StatelessWidget {
  final List<_Demo> demos;
  const _DemoList(this.demos);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: demos.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (context, i) {
        final d = demos[i];
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
    );
  }
}
