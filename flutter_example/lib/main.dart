import 'package:flutter/material.dart';

import 'demos/shape_drawing_demo.dart';
import 'demos/hit_testing_demo.dart';
import 'demos/animated_transform_demo.dart';
import 'demos/measurement_demo.dart';
import 'demos/raycasting_demo.dart';
import 'demos/circle_intersection_demo.dart';
import 'demos/rectangle_demo.dart';
import 'demos/ellipse_demo.dart';
import 'demos/line_tools_demo.dart';
import 'demos/polygon_info_demo.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'geometry_kit Examples',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DemoList(),
    );
  }
}

class DemoList extends StatelessWidget {
  const DemoList({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <(String, String, Widget)>[
      ('Shape Drawing', 'Hexagon, circle, arc, pentagon, triangle on Canvas', const ShapeDrawingDemo()),
      ('Hit Testing', 'Tap to check point-in-shape', const HitTestingDemo()),
      ('Animated Transforms', 'Rotating & scaling polygon', const AnimatedTransformDemo()),
      ('Measurements', 'Line length & angle annotations', const MeasurementDemo()),
      ('Raycasting', 'Ray-wall & ray-circle intersection', const RaycastingDemo()),
      ('Circle Intersections', 'Drag circles, see intersection points & tangent', const CircleIntersectionDemo()),
      ('Rectangle', 'Contains, overlaps, diagonal, isSquare', const RectangleDemo()),
      ('Ellipse', 'Foci, eccentricity, pointAt trace, contains', const EllipseDemo()),
      ('Line Tools', 'Lerp, extend, projectPoint, parallel/perp', const LineToolsDemo()),
      ('Polygon Info', 'Convex, winding, centroid, closest vertex, bbox', const PolygonInfoDemo()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('geometry_kit demos')),
      body: ListView.separated(
        itemCount: demos.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final (title, subtitle, page) = demos[i];
          return ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            ),
          );
        },
      ),
    );
  }
}
