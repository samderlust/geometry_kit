import 'package:flutter/material.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class CircleDemo extends StatelessWidget {
  const CircleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(200, 200);
    return ListView(
      children: [
        DemoCard(
          title: 'Stroked',
          caption: 'Default 1px stroke',
          child: GeoCircle(
            radius: 80,
            center: const Offset(100, 100),
            style: const ShapeStyle.stroked(Colors.indigo, width: 2),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Filled',
          caption: 'Solid color',
          child: GeoCircle(
            radius: 80,
            center: const Offset(100, 100),
            style: const ShapeStyle.filled(Colors.indigo),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Fill + stroke + opacity',
          caption: 'Combined paint passes',
          child: GeoCircle(
            radius: 80,
            center: const Offset(100, 100),
            style: const ShapeStyle(
              fillColor: Colors.indigo,
              strokeColor: Colors.amber,
              strokeWidth: 4,
              opacity: 0.7,
            ),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Dashed',
          caption: 'DashPattern([8, 4])',
          child: GeoCircle(
            radius: 80,
            center: const Offset(100, 100),
            style: const ShapeStyle(
              strokeColor: Colors.deepPurple,
              strokeWidth: 3,
              dashPattern: DashPattern([8, 4]),
            ),
            size: size,
          ),
        ),
      ],
    );
  }
}
