import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

/// Curve widgets, drag, `GeoGrid` and `GeoDebugOverlay`.
class CurvesDemo extends StatefulWidget {
  const CurvesDemo({super.key});

  @override
  State<CurvesDemo> createState() => _CurvesDemoState();
}

enum _Layer { bounds, center, vertices, dimensions }

class _CurvesDemoState extends State<CurvesDemo> {
  // Gallery.
  final Set<_Layer> _layers = {_Layer.vertices};
  bool _sector = false;

  // Standalone drag.
  Circle _circle = const Circle(center: Point(60, 70), radius: 30);
  Capsule _capsule = const Capsule(
    medialAxis: Line(Point(140, 40), Point(220, 100)),
    radius: 18,
  );
  CubicBezier _wave = const CubicBezier(
    start: Point(250, 110),
    control1: Point(270, 10),
    control2: Point(320, 130),
    end: Point(340, 40),
  );
  Offset _live = Offset.zero;
  String _lastDrop = '—';

  // Canvas.
  bool _grid = true;
  bool _major = true;
  String? _selected;
  late Map<String, Object> _canvasShapes = {
    'sector': ArcSector(
      Arc.fromDegrees(
        center: const Point(-90, 40),
        radius: 55,
        startDeg: 10,
        endDeg: 120,
      ),
    ),
    'ring': const Ring(center: Point(70, 50), innerRadius: 18, outerRadius: 36),
    'spline': Spline(const [
      Point(-140, -70),
      Point(-90, -20),
      Point(-40, -90),
      Point(10, -40),
    ]),
    'bezier': const QuadraticBezier(
      start: Point(40, -90),
      control: Point(90, 10),
      end: Point(140, -90),
    ),
    'ray': Ray.fromAngle(const Point(-20, 10), 30),
  };

  static const _canvasColors = {
    'sector': Color(0xFFEF6C00),
    'ring': Color(0xFF00897B),
    'spline': Color(0xFF3949AB),
    'bezier': Color(0xFFD81B60),
    'ray': Color(0xFF6D4C41),
  };

  GeoDebugOverlay? get _overlay => _layers.isEmpty
      ? null
      : GeoDebugOverlay(
          showBoundingBox: _layers.contains(_Layer.bounds),
          showCenter: _layers.contains(_Layer.center),
          showVertices: _layers.contains(_Layer.vertices),
          showDimensions: _layers.contains(_Layer.dimensions),
        );

  /// Translates any of the demo's geometry types. `Spline` has no
  /// `translate`, so its control points move one by one.
  static Object _moved(Object shape, Offset d) => switch (shape) {
    ArcSector s => ArcSector(s.arc.translate(x: d.dx, y: d.dy)),
    Ring r => r.translate(x: d.dx, y: d.dy),
    Spline s => Spline([
      for (final p in s.controlPoints) p.translate(d.dx, d.dy),
    ], alpha: s.alpha),
    QuadraticBezier b => b.translate(x: d.dx, y: d.dy),
    Ray r => r.translate(x: d.dx, y: d.dy),
    _ => shape,
  };

  String _fmt(Offset o) =>
      '(${o.dx.toStringAsFixed(0)}, ${o.dy.toStringAsFixed(0)})';

  void _onLive(Offset delta) => setState(() => _live += delta);

  void _drop(String what, Offset total) {
    _live = Offset.zero;
    _lastDrop = '$what by ${_fmt(total)}';
  }

  @override
  Widget build(BuildContext context) {
    const stroke = ShapeStyle.stroked(Color(0xFF3949AB), width: 3);
    final overlay = _overlay;

    Widget tile(String label, Widget child) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        DemoCard(
          title: 'Curve widgets',
          caption:
              'GeoArc, GeoRing, GeoCapsule, GeoBezierCurve, GeoSpline, '
              'GeoPolyline and GeoRay. Open curves are stroked only. Toggle '
              'debug overlay layers below.',
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final layer in _Layer.values)
                      FilterChip(
                        label: Text(layer.name),
                        selected: _layers.contains(layer),
                        onSelected: (on) => setState(
                          () => on ? _layers.add(layer) : _layers.remove(layer),
                        ),
                      ),
                    FilterChip(
                      label: const Text('arc sector'),
                      selected: _sector,
                      onSelected: (on) => setState(() => _sector = on),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    tile(
                      _sector ? 'GeoArc (sector)' : 'GeoArc',
                      GeoArc(
                        radius: 45,
                        center: const Offset(65, 60),
                        startDeg: -30,
                        endDeg: 210,
                        sector: _sector,
                        size: const Size(130, 130),
                        style: _sector
                            ? const ShapeStyle(
                                fillColor: Color(0xFFFFB74D),
                                strokeColor: Color(0xFFEF6C00),
                                strokeWidth: 2,
                              )
                            : stroke,
                        debugOverlay: overlay,
                      ),
                    ),
                    tile(
                      'GeoRing',
                      GeoRing(
                        innerRadius: 22,
                        outerRadius: 45,
                        center: const Offset(65, 60),
                        size: const Size(130, 130),
                        style: const ShapeStyle(
                          fillColor: Color(0xFF4DB6AC),
                          strokeColor: Color(0xFF00695C),
                        ),
                        debugOverlay: overlay,
                      ),
                    ),
                    tile(
                      'GeoCapsule',
                      GeoCapsule(
                        a: const Offset(35, 40),
                        b: const Offset(95, 85),
                        radius: 18,
                        size: const Size(130, 130),
                        style: const ShapeStyle.filled(Color(0xFFF06292)),
                        debugOverlay: overlay,
                      ),
                    ),
                    tile(
                      'GeoBezierCurve.cubic',
                      GeoBezierCurve.cubic(
                        start: const Offset(10, 100),
                        control1: const Offset(30, 10),
                        control2: const Offset(100, 10),
                        end: const Offset(120, 100),
                        size: const Size(130, 130),
                        style: stroke,
                        debugOverlay: overlay,
                      ),
                    ),
                    tile(
                      'GeoBezierCurve.quadratic',
                      GeoBezierCurve.quadratic(
                        start: const Offset(10, 100),
                        control: const Offset(65, 10),
                        end: const Offset(120, 100),
                        size: const Size(130, 130),
                        style: stroke.copyWith(
                          dashPattern: const DashPattern([8, 5]),
                        ),
                        debugOverlay: overlay,
                      ),
                    ),
                    tile(
                      'GeoSpline',
                      GeoSpline(
                        points: const [
                          Offset(10, 95),
                          Offset(45, 25),
                          Offset(85, 85),
                          Offset(120, 30),
                        ],
                        size: const Size(130, 130),
                        style: stroke,
                        debugOverlay: overlay,
                      ),
                    ),
                    tile(
                      'GeoPolyline',
                      GeoPolyline(
                        points: const [
                          Offset(10, 95),
                          Offset(45, 25),
                          Offset(85, 85),
                          Offset(120, 30),
                        ],
                        size: const Size(130, 130),
                        style: stroke.copyWith(strokeJoin: StrokeJoin.round),
                        debugOverlay: overlay,
                      ),
                    ),
                    tile(
                      'GeoRay',
                      GeoRay(
                        origin: const Offset(15, 105),
                        angleDeg: -40,
                        size: const Size(130, 130),
                        style: stroke,
                        debugOverlay: overlay,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        DemoCard(
          title: 'Drag',
          caption:
              'Any onDrag* callback makes a shape draggable. The widget draws '
              'the drag; onDragEnd reports the total and the demo commits it '
              'with translate(). Curves grab within a few pixels of the stroke.',
          child: LayoutBuilder(
            builder: (context, c) {
              final w = math.min(c.maxWidth, 360.0);
              final size = Size(w, 150);
              return Stack(
                children: [
                  SizedBox.fromSize(size: size),
                  GeoCircle.fromGeometry(
                    circle: _circle,
                    size: size,
                    style: const ShapeStyle(
                      fillColor: Color(0xFF7986CB),
                      strokeColor: Color(0xFF283593),
                      strokeWidth: 2,
                    ),
                    onDragUpdate: _onLive,
                    onDragEnd: (d) => setState(() {
                      _circle = _circle.translate(x: d.dx, y: d.dy);
                      _drop('circle', d);
                    }),
                  ),
                  GeoCapsule.fromGeometry(
                    capsule: _capsule,
                    size: size,
                    style: const ShapeStyle.filled(Color(0xFFF06292)),
                    onDragUpdate: _onLive,
                    onDragEnd: (d) => setState(() {
                      _capsule = _capsule.translate(x: d.dx, y: d.dy);
                      _drop('capsule', d);
                    }),
                  ),
                  GeoBezierCurve.fromGeometry(
                    curve: _wave,
                    size: size,
                    style: const ShapeStyle.stroked(
                      Color(0xFF00897B),
                      width: 4,
                    ),
                    debugOverlay: const GeoDebugOverlay(
                      showBoundingBox: false,
                      showCenter: false,
                    ),
                    onDragUpdate: _onLive,
                    onDragEnd: (d) => setState(() {
                      _wave = _wave.translate(x: d.dx, y: d.dy);
                      _drop('curve', d);
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 16,
            children: [
              Text('dragging Δ ${_fmt(_live)}'),
              Text('last drop: $_lastDrop'),
            ],
          ),
        ),
        DemoCard(
          title: 'GeometryCanvas: grid, drag, select',
          caption:
              'Centered, Y-up mapper with a GeoGrid. Tap a shape to select it '
              '(GeoDebugOverlay.all), drag any shape to move it. Drag deltas '
              'come back in geometry space, so up is +Y.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  FilterChip(
                    label: const Text('grid'),
                    selected: _grid,
                    onSelected: (on) => setState(() => _grid = on),
                  ),
                  FilterChip(
                    label: const Text('major lines'),
                    selected: _major,
                    onSelected: _grid
                        ? (on) => setState(() => _major = on)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, c) {
                  final size = Size(math.min(c.maxWidth, 360.0), 260);
                  return GeometryCanvas(
                    size: size,
                    mapper: CoordinateMapper.centered(size),
                    backgroundColor: Colors.white,
                    grid: _grid
                        ? GeoGrid(spacing: 10, majorEvery: _major ? 5 : null)
                        : null,
                    shapes: [
                      for (final MapEntry(key: id, value: shape)
                          in _canvasShapes.entries)
                        StyledShape(
                          shape,
                          id: id,
                          style: shape is ArcSector || shape is Ring
                              ? ShapeStyle(
                                  fillColor: _canvasColors[id]!.withValues(
                                    alpha: 0.55,
                                  ),
                                  strokeColor: _canvasColors[id],
                                  strokeWidth: _selected == id ? 3 : 1.5,
                                )
                              : ShapeStyle.stroked(
                                  _canvasColors[id]!,
                                  width: _selected == id ? 4 : 2.5,
                                ),
                          debugOverlay: _selected == id
                              ? GeoDebugOverlay.all
                              : null,
                          onTap: () => setState(
                            () => _selected = _selected == id ? null : id,
                          ),
                          onDragEnd: (d) => setState(() {
                            _canvasShapes = {
                              ..._canvasShapes,
                              id: _moved(shape, d),
                            };
                            _selected = id;
                          }),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('selected: ${_selected ?? '—'}'),
        ),
      ],
    );
  }
}
