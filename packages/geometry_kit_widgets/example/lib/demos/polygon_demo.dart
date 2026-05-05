import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class PolygonDemo extends StatelessWidget {
  const PolygonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(240, 240);
    return ListView(
      children: [
        DemoCard(
          title: 'Regular hexagon',
          caption: 'Polygon.regular(sides: 6)',
          child: GeoPolygon.fromGeometry(
            polygon: Polygon.regular(
              sides: 6,
              radius: 90,
              center: const Point(120, 120),
            ),
            style: const ShapeStyle.filled(Colors.pink),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Pentagon — stroked',
          child: GeoPolygon.fromGeometry(
            polygon: Polygon.regular(
              sides: 5,
              radius: 90,
              center: const Point(120, 120),
            ),
            style: const ShapeStyle.stroked(Colors.pink, width: 3),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Free-form polygon',
          child: GeoPolygon(
            vertices: const [
              Offset(30, 30),
              Offset(210, 60),
              Offset(180, 200),
              Offset(120, 150),
              Offset(50, 180),
            ],
            style: const ShapeStyle(
              fillColor: Colors.pink,
              strokeColor: Colors.purple,
              strokeWidth: 2,
              opacity: 0.7,
            ),
            size: size,
          ),
        ),
      ],
    );
  }
}
