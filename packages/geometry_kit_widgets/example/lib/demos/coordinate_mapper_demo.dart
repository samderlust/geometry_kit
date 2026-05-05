import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class CoordinateMapperDemo extends StatelessWidget {
  const CoordinateMapperDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(280, 200);

    final shapes = [
      StyledShape(
        const Circle(center: Point(40, 40), radius: 25),
        style: const ShapeStyle.filled(Colors.indigo),
      ),
      StyledShape(
        Triangle(
          const Point(140, 100),
          const Point(220, 160),
          const Point(80, 160),
        ),
        style: const ShapeStyle.stroked(Colors.deepOrange, width: 3),
      ),
    ];

    return ListView(
      children: [
        DemoCard(
          title: 'identity (default)',
          caption: 'Top-left origin, Y-down (Flutter native)',
          child: GeometryCanvas(
            size: size,
            backgroundColor: Colors.white,
            shapes: shapes,
          ),
        ),
        DemoCard(
          title: 'yUp',
          caption: 'Bottom-left origin, Y-up (math convention)',
          child: GeometryCanvas(
            size: size,
            backgroundColor: Colors.white,
            mapper: CoordinateMapper.yUp(size),
            shapes: shapes,
          ),
        ),
        DemoCard(
          title: 'centered (Y-up)',
          caption: 'Origin at canvas center',
          child: GeometryCanvas(
            size: size,
            backgroundColor: Colors.white,
            mapper: CoordinateMapper.centered(size),
            shapes: [
              StyledShape(
                const Circle(center: Point(0, 0), radius: 30),
                style: const ShapeStyle.filled(Colors.indigo),
              ),
              StyledShape(
                const Circle(center: Point(60, 40), radius: 20),
                style: const ShapeStyle.filled(Colors.amber),
              ),
              StyledShape(
                const Circle(center: Point(-60, -40), radius: 20),
                style: const ShapeStyle.filled(Colors.teal),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
