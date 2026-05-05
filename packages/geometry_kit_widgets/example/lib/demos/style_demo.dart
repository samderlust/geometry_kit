import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class StyleDemo extends StatefulWidget {
  const StyleDemo({super.key});

  @override
  State<StyleDemo> createState() => _StyleDemoState();
}

class _StyleDemoState extends State<StyleDemo> {
  Color _color = Colors.deepPurple;
  bool _dashed = false;
  bool _isFilled = false;

  static const _palette = [
    Colors.deepPurple,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.green,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShapeStyle(
      strokeColor: _color,
      strokeWidth: 3,
      dashPattern: _dashed ? const DashPattern([8, 4]) : null,
      fillColor: _isFilled ? _color.withValues(alpha: 0.3) : null,
    );

    return ListView(
      children: [
        DemoCard(
          title: 'ShapeStyleTheme',
          caption: 'All four shapes inherit the theme; one overrides locally',
          child: ShapeStyleTheme(
            data: theme,
            child: SizedBox(
              width: 320,
              height: 280,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  GeoCircle(
                    radius: 50,
                    center: const Offset(60, 60),
                    size: const Size(120, 120),
                  ),
                  GeoTriangle(
                    a: const Offset(60, 10),
                    b: const Offset(110, 110),
                    c: const Offset(10, 110),
                    size: const Size(120, 120),
                  ),
                  GeoRectangle(
                    x: 10,
                    y: 10,
                    width: 100,
                    height: 100,
                    cornerRadius: const Radius.circular(12),
                    size: const Size(120, 120),
                  ),
                  GeoPolygon.fromGeometry(
                    polygon: Polygon.regular(
                      sides: 5,
                      radius: 50,
                      center: const Point(60, 60),
                    ),
                    // style: ShapeStyle.filled(_color),
                    size: const Size(120, 120),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Theme color'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in _palette)
                    GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: c == _color
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dashed stroke'),
                value: _dashed,
                onChanged: (v) => setState(() => _dashed = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Filled'),
                value: _isFilled,
                onChanged: (v) => setState(() => _isFilled = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
