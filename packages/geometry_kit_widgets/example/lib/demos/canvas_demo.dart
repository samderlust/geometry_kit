import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class CanvasDemo extends StatelessWidget {
  const CanvasDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const size = Size(360, 280);
    return ListView(
      children: [
        DemoCard(
          title: 'Mixed shapes',
          caption: 'GeometryCanvas paints in list order',
          child: GeometryCanvas(
            size: size,
            backgroundColor: Colors.white,
            shapes: [
              StyledShape(
                Rectangle(x: 20, y: 20, width: 320, height: 240),
                style: const ShapeStyle.stroked(Colors.grey, width: 1),
              ),
              StyledShape(
                Polygon.regular(
                  sides: 6,
                  radius: 70,
                  center: const Point(110, 140),
                ),
                style: const ShapeStyle(
                  fillColor: Colors.indigo,
                  opacity: 0.6,
                ),
              ),
              StyledShape(
                const Circle(
                  center: Point(220, 100),
                  radius: 60,
                ),
                style: const ShapeStyle(
                  fillColor: Colors.amber,
                  strokeColor: Colors.deepOrange,
                  strokeWidth: 3,
                  opacity: 0.85,
                ),
              ),
              StyledShape(
                Triangle(
                  const Point(220, 170),
                  const Point(310, 240),
                  const Point(160, 240),
                ),
                style: const ShapeStyle.stroked(Colors.teal, width: 3),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'Stacked transparency',
          caption: 'Opacity blends overlapping fills',
          child: GeometryCanvas(
            size: size,
            backgroundColor: Colors.white,
            shapes: [
              StyledShape(
                const Circle(center: Point(140, 140), radius: 80),
                style: const ShapeStyle(
                  fillColor: Colors.red,
                  opacity: 0.5,
                ),
              ),
              StyledShape(
                const Circle(center: Point(220, 140), radius: 80),
                style: const ShapeStyle(
                  fillColor: Colors.blue,
                  opacity: 0.5,
                ),
              ),
              StyledShape(
                const Circle(center: Point(180, 200), radius: 80),
                style: const ShapeStyle(
                  fillColor: Colors.green,
                  opacity: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
