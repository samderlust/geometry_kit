import 'package:flutter/material.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class QuadrilateralDemo extends StatelessWidget {
  const QuadrilateralDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(260, 200);
    return ListView(
      children: [
        DemoCard(
          title: 'Trapezoid',
          child: GeoQuadrilateral(
            a: const Offset(40, 30),
            b: const Offset(220, 30),
            c: const Offset(180, 170),
            d: const Offset(80, 170),
            style: const ShapeStyle.filled(Colors.green),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Rhombus',
          child: GeoQuadrilateral(
            a: const Offset(130, 20),
            b: const Offset(240, 100),
            c: const Offset(130, 180),
            d: const Offset(20, 100),
            style: const ShapeStyle(
              fillColor: Colors.green,
              strokeColor: Colors.white,
              strokeWidth: 2,
              opacity: 0.9,
            ),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Kite — dashed',
          child: GeoQuadrilateral(
            a: const Offset(130, 20),
            b: const Offset(220, 90),
            c: const Offset(130, 180),
            d: const Offset(40, 90),
            style: const ShapeStyle(
              strokeColor: Colors.green,
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
