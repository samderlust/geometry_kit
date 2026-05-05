import 'package:flutter/material.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class LineDemo extends StatelessWidget {
  const LineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(280, 160);
    return ListView(
      children: [
        DemoCard(
          title: 'Solid line',
          child: GeoLine(
            a: const Offset(20, 80),
            b: const Offset(260, 80),
            style: const ShapeStyle.stroked(Colors.indigo, width: 2),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Diagonal',
          child: GeoLine(
            a: const Offset(20, 20),
            b: const Offset(260, 140),
            style: const ShapeStyle.stroked(Colors.indigo, width: 4),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Dashed line',
          caption: 'DashPattern([10, 5])',
          child: GeoLine(
            a: const Offset(20, 80),
            b: const Offset(260, 80),
            style: const ShapeStyle(
              strokeColor: Colors.indigo,
              strokeWidth: 3,
              dashPattern: DashPattern([10, 5]),
            ),
            size: size,
          ),
        ),
        DemoCard(
          title: 'Round caps',
          child: GeoLine(
            a: const Offset(40, 80),
            b: const Offset(240, 80),
            style: const ShapeStyle(
              strokeColor: Colors.indigo,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
            ),
            size: size,
          ),
        ),
      ],
    );
  }
}
