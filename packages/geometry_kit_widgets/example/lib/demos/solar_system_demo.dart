import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

import '_demo_card.dart';

class SolarSystemDemo extends StatefulWidget {
  const SolarSystemDemo({super.key});

  @override
  State<SolarSystemDemo> createState() => _SolarSystemDemoState();
}

class _SolarSystemDemoState extends State<SolarSystemDemo>
    with SingleTickerProviderStateMixin {
  static const _canvasSize = Size(360, 360);

  late final AnimationController _ctrl;
  double _speed = 1.0;
  double _planetScale = 1.0;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _running = !_running;
      if (_running) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapper = CoordinateMapper.centered(_canvasSize);

    return ListView(
      children: [
        DemoCard(
          title: 'Solar system',
          caption:
              'AnimationController drives orbit angles, sun pulse, and per-planet '
              'day/night shading. CoordinateMapper.centered puts the sun at (0, 0); '
              'GeometryCanvas paints sun + planets.',
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = _ctrl.value * _speed;
              // Pulse: 0..1..0 twice per orbit cycle.
              final pulse =
                  0.5 + 0.5 * math.sin(_ctrl.value * 2 * math.pi * 2);
              return GeometryCanvas(
                size: _canvasSize,
                backgroundColor: const Color(0xFF0B1020),
                mapper: mapper,
                shapes: [
                  ..._orbitRings(),
                  ..._sunHalo(pulse),
                  _sun(pulse),
                  ..._planets(t, _planetScale),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _togglePlay,
                    icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                    tooltip: _running ? 'Pause' : 'Play',
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(width: 56, child: Text('Speed')),
                  Expanded(
                    child: Slider(
                      value: _speed,
                      min: 0.0,
                      max: 4.0,
                      divisions: 40,
                      label: '${_speed.toStringAsFixed(1)}×',
                      onChanged: (v) => setState(() => _speed = v),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 56),
                  const SizedBox(width: 56, child: Text('Planet')),
                  Expanded(
                    child: Slider(
                      value: _planetScale,
                      min: 0.3,
                      max: 4.0,
                      divisions: 37,
                      label: '${_planetScale.toStringAsFixed(1)}×',
                      onChanged: (v) => setState(() => _planetScale = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  StyledShape _sun(double pulse) {
    // Sun radius breathes 14 → 16 with the pulse.
    final radius = 14 + pulse * 2;
    return StyledShape(
      Circle(center: const Point(0, 0), radius: radius),
      style: const ShapeStyle(
        fillGradient: RadialGradient(
          colors: [
            Color(0xFFFFF6C8),
            Color(0xFFFFD15C),
            Color(0xFFE08A1F),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        strokeColor: null,
        strokeWidth: 0,
      ),
    );
  }

  // Outer halo uses the PaintBuilder escape hatch to attach a MaskFilter.blur,
  // demonstrating how callers reach Skia features that ShapeStyle does not
  // expose directly. Halo radius and alpha pulse with the sun.
  Iterable<StyledShape> _sunHalo(double pulse) {
    final outerRadius = 32.0 + pulse * 6;
    final outerAlpha = 0.25 + pulse * 0.20;
    final innerRadius = 22.0 + pulse * 3;
    final innerAlpha = 0.30 + pulse * 0.20;
    return [
      StyledShape(
        Circle(center: const Point(0, 0), radius: outerRadius),
        style: ShapeStyle(
          fillColor: const Color(0xFFFFD15C).withValues(alpha: outerAlpha),
          strokeColor: null,
          strokeWidth: 0,
          fillPaintBuilder: _sunGlowPaintBuilder,
        ),
      ),
      StyledShape(
        Circle(center: const Point(0, 0), radius: innerRadius),
        style: ShapeStyle(
          fillGradient: RadialGradient(
            colors: [
              const Color(0xFFFFE39A).withValues(alpha: innerAlpha),
              const Color(0x00FFE39A),
            ],
          ),
          strokeColor: null,
          strokeWidth: 0,
        ),
      ),
    ];
  }

  Iterable<StyledShape> _orbitRings() => _orbits.map(
        (o) => StyledShape(
          Circle(center: const Point(0, 0), radius: o.radius),
          style: const ShapeStyle(
            strokeColor: Color(0x33FFFFFF),
            strokeWidth: 1,
            dashPattern: DashPattern([4, 4]),
          ),
        ),
      );

  Iterable<StyledShape> _planets(double t, double scale) => _orbits.map((o) {
        final angle = (t * 2 * math.pi) / o.period;
        final cosA = math.cos(angle);
        final sinA = math.sin(angle);
        final pos = Point(o.radius * cosA, o.radius * sinA);

        // Day/night shading: highlight follows direction from planet back
        // toward the sun. Planet at math (cosA, sinA)·r; sun at origin, so
        // the sun-ward unit vector in math space is (-cosA, -sinA). The
        // mapper here is `centered(yUp: true)`, so canvas Y is flipped
        // relative to math Y — the alignment Y component flips sign too,
        // landing on (-cosA, +sinA). Push the highlight close to the lit
        // rim (0.85) so the dark side dominates the disc.
        final highlight = Color.lerp(Colors.white, o.color, 0.30)!;
        final terminator = Color.lerp(Colors.black, o.color, 0.45)!;
        const shadow = Color(0xFF050810);
        return StyledShape(
          Circle(center: pos, radius: o.size * scale),
          style: ShapeStyle(
            fillGradient: RadialGradient(
              center: Alignment(-cosA * 0.85, sinA * 0.85),
              radius: 1.1,
              colors: [highlight, o.color, terminator, shadow],
              stops: const [0.0, 0.25, 0.55, 1.0],
            ),
            strokeColor: null,
            strokeWidth: 0,
          ),
        );
      });
}

class _Orbit {
  final String name;
  final double radius;
  final double size;
  final double period;
  final Color color;

  const _Orbit(
    this.name, {
    required this.radius,
    required this.size,
    required this.period,
    required this.color,
  });
}

// Top-level so its identity is stable across rebuilds — `ShapeStyle` equality
// compares PaintBuilder by reference, and a fresh closure each build would
// thrash the painter's `shouldRepaint` check.
Paint _sunGlowPaintBuilder(Paint base, Rect bounds) =>
    base..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

const _orbits = <_Orbit>[
  _Orbit('Mercury',
      radius: 35, size: 3, period: 0.24, color: Color(0xFFB0B0B0)),
  _Orbit('Venus',
      radius: 60, size: 5, period: 0.62, color: Color(0xFFE8C16A)),
  _Orbit('Earth',
      radius: 90, size: 6, period: 1.0, color: Color(0xFF4FA3E3)),
  _Orbit('Mars',
      radius: 120, size: 4, period: 1.88, color: Color(0xFFE0613A)),
  _Orbit('Jupiter',
      radius: 160, size: 10, period: 4.0, color: Color(0xFFD9A066)),
];
