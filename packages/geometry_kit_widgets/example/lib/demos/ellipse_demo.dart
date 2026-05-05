import 'package:flutter/material.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class EllipseDemo extends StatelessWidget {
  const EllipseDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(280, 200);
    return ListView(
      children: [
        DemoCard(
          title: 'Wide ellipse',
          caption: 'radiusX > radiusY',
          child: GeoEllipse(
            radiusX: 120,
            radiusY: 60,
            center: const Offset(140, 100),
            style: const ShapeStyle.stroked(Colors.teal, width: 2),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Tall ellipse — filled',
          caption: 'radiusY > radiusX',
          child: GeoEllipse(
            radiusX: 60,
            radiusY: 90,
            center: const Offset(140, 100),
            style: const ShapeStyle.filled(Colors.teal),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Dashed ellipse',
          caption: 'Dash works on any path',
          child: GeoEllipse(
            radiusX: 110,
            radiusY: 70,
            center: const Offset(140, 100),
            style: const ShapeStyle(
              strokeColor: Colors.deepOrange,
              strokeWidth: 3,
              dashPattern: DashPattern([10, 5]),
            ),
            size: size,
          ),
        ),
      ],
    );
  }
}
