import 'package:flutter/material.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class RectangleDemo extends StatelessWidget {
  const RectangleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(260, 200);
    return ListView(
      children: [
        DemoCard(
          title: 'Sharp corners',
          child: GeoRectangle(
            x: 30,
            y: 40,
            width: 200,
            height: 120,
            style: const ShapeStyle.stroked(Colors.blueGrey, width: 2),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Rounded corners',
          caption: 'cornerRadius: 24',
          child: GeoRectangle(
            x: 30,
            y: 40,
            width: 200,
            height: 120,
            cornerRadius: const Radius.circular(24),
            style: const ShapeStyle.filled(Colors.blueGrey),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Fill + stroke',
          child: GeoRectangle(
            x: 30,
            y: 40,
            width: 200,
            height: 120,
            cornerRadius: const Radius.circular(12),
            style: const ShapeStyle(
              fillColor: Colors.blue,
              strokeColor: Colors.indigo,
              strokeWidth: 3,
              opacity: 0.85,
            ),
            size: size,
          ),
        ),
      ],
    );
  }
}
