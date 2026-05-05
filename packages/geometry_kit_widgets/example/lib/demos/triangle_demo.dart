import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class TriangleDemo extends StatelessWidget {
  const TriangleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(240, 220);
    return ListView(
      children: [
        DemoCard(
          title: 'Free-form triangle',
          child: GeoTriangle(
            a: const Offset(120, 20),
            b: const Offset(220, 200),
            c: const Offset(20, 200),
            style: const ShapeStyle.stroked(Colors.deepOrange, width: 2),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Equilateral — fromGeometry',
          caption: 'Triangle.equilateral factory',
          child: GeoTriangle.fromGeometry(
            triangle: Triangle.equilateral(
              center: const Point(120, 110),
              radius: 90,
            ),
            style: const ShapeStyle.filled(Colors.deepOrange),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Dashed outline',
          child: GeoTriangle(
            a: const Offset(120, 20),
            b: const Offset(220, 200),
            c: const Offset(20, 200),
            style: const ShapeStyle(
              strokeColor: Colors.purple,
              strokeWidth: 3,
              dashPattern: DashPattern([12, 6]),
            ),
            size: size,
          ),
        ),
      ],
    );
  }
}
