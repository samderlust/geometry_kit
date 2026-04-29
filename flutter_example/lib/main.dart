import 'package:flutter/material.dart';

import 'demos/shape_drawing_demo.dart';
import 'demos/hit_testing_demo.dart';
import 'demos/animated_transform_demo.dart';
import 'demos/measurement_demo.dart';

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
      ('Shape Drawing', 'Hexagon, circle, and arc on Canvas', const ShapeDrawingDemo()),
      ('Hit Testing', 'Tap to check point-in-shape', const HitTestingDemo()),
      ('Animated Transforms', 'Rotating & scaling polygon', const AnimatedTransformDemo()),
      ('Measurements', 'Line length & angle annotations', const MeasurementDemo()),
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
