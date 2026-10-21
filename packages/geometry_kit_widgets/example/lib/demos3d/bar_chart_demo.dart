import 'package:flutter/material.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_kit.dart';

/// Use 2 — lightweight 3D views: a 3D bar chart with hover/tap values.
class BarChartDemo extends StatefulWidget {
  const BarChartDemo({super.key});

  @override
  State<BarChartDemo> createState() => _BarChartDemoState();
}

class _Bar {
  final int series;
  final String month;
  final int value;
  final Box box;
  const _Bar(this.series, this.month, this.value, this.box);
  String get id => '$series-$month';
}

class _BarChartDemoState extends State<BarChartDemo> {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const _names = ['iOS', 'Android', 'Web'];
  // Sample data: monthly active users, thousands.
  static const _values = [
    [42, 48, 55, 61, 66, 74],
    [58, 61, 63, 70, 78, 85],
    [21, 24, 22, 27, 31, 30],
  ];
  static const _max = 85;

  static final _bars = [
    for (var si = 0; si < 3; si++)
      for (var mi = 0; mi < 6; mi++)
        _Bar(
          si,
          _months[mi],
          _values[si][mi],
          Box.fromBase(
            center: Point3(mi * 0.9 - 2.25, -1, si * 0.9 - 0.9),
            width: 0.55,
            depth: 0.55,
            height: _values[si][mi] / _max * 2.2,
          ),
        ),
  ];

  String? _hovered;

  static const _code = '''GeoScene(
  camera: const OrbitCamera(yaw: -35, pitch: 26, distance: 8),
  onHover: (hit) => setState(() => hovered = hit?.node.id),
  onTap: (hit) => setState(() => hovered = hit?.node.id),
  children: [
    ...GeoPath3.grid(extent: 3, step: 0.45, y: -1),
    for (final (m, _) in months.indexed)
      for (final (s, series) in data.indexed)
        GeoSolid(
          Box.fromBase(
            center: Point3(m * 0.9 - 2.25, -1, s * 0.9 - 0.9),
            width: 0.55,
            depth: 0.55,
            height: series.values[m] / maxValue * 2.2,
          ),
          style: ShapeStyle(fillColor: series.color),
          id: '\$s-\$m',
        ),
  ],
)''';

  @override
  Widget build(BuildContext context) {
    final p = DemoPalette.of(context);
    final colors = [p.accent, p.amber, p.teal];
    final hovered = _bars.where((b) => b.id == _hovered).firstOrNull;
    void pick(SceneHit? h) => setState(() => _hovered = h?.node.id);

    return Demo3dPage(
      code: _code,
      demo: DemoPanel(
        label: 'GeoScene · ${_bars.length} boxes',
        hint: 'tap a bar · drag to orbit',
        scene: GeoScene(
          camera: const OrbitCamera(
            yaw: -35,
            pitch: 26,
            distance: 8.2,
            target: Point3(0, -0.2, 0),
          ),
          onHover: pick,
          onTap: pick,
          children: [
            ...p.grid3(extent: 2.7, step: 0.45, y: -1),
            for (final b in _bars)
              GeoSolid(
                b.box,
                id: b.id,
                style: ShapeStyle(
                  fillColor: b == hovered
                      ? Color.lerp(colors[b.series], Colors.white, 0.4)
                      : colors[b.series],
                  strokeColor: null,
                ),
              ),
            for (final (i, m) in _months.indexed)
              GeoLabel3(
                Point3(i * 0.9 - 2.25, -1, 1.75),
                m,
                style: p.label3(p.muted, weight: FontWeight.w500),
              ),
            for (final (i, n) in _names.indexed)
              GeoLabel3(
                Point3(-3.0, -1, i * 0.9 - 0.9),
                n,
                alignment: Alignment.centerLeft,
                style: p.label3(colors[i]),
              ),
            if (hovered != null)
              GeoLabel3(
                hovered.box.bounds.center.translate(
                  y: hovered.box.height / 2 + 0.25,
                ),
                '${hovered.value}k',
                style: p.label3(p.fg, size: 13, weight: FontWeight.w700),
              ),
          ],
        ),
        readouts: [
          Readout(
            'Hovered',
            hovered == null
                ? '–'
                : '${_names[hovered.series]} · ${hovered.month} · ${hovered.value}k',
            highlight: true,
          ),
          Readout('Triangles', '${_bars.length * 12}'),
        ],
        footer: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 14,
                children: [
                  for (final (i, n) in _names.indexed) LegendDot(colors[i], n),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Sample data: monthly active users in thousands.',
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
