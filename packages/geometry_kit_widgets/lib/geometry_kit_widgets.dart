/// Flutter widgets for [`geometry_kit`](https://pub.dev/packages/geometry_kit)
/// shapes.
///
/// Provides declarative `Geo*` widgets for circles, ellipses, rectangles,
/// triangles, quadrilaterals, polygons, lines, arcs, rings, capsules,
/// Bezier curves, splines, polylines and rays, plus a `GeometryCanvas` for
/// multi-shape scenes with a grid and axes. Every shape can be tapped,
/// hovered, dragged, and annotated with a `GeoDebugOverlay`. Styling flows through `ShapeStyle` / `ShapeStyleTheme`.
/// Coordinate transforms (Y-up, centered, …) flow through `CoordinateMapper`.
///
/// `GeoScene` draws `geometry_kit_3d` solids with an orbit camera, flat
/// shading, `SolidGradient` colouring and tap/hover picking.
library;

export 'src/coord/coordinate_mapper.dart';
export 'src/style/animated_shape_style.dart';
export 'src/style/dash_pattern.dart';
export 'src/style/shape_style.dart';
export 'src/style/shape_style_theme.dart';
export 'src/canvas/geo_grid.dart';
export 'src/canvas/geometry_canvas.dart';
export 'src/canvas/styled_shape.dart';
export 'src/debug/geo_debug_overlay.dart';
export 'src/scene/geo_scene.dart';
export 'src/scene/scene_interaction.dart';
export 'src/scene/scene_node.dart';
export 'src/scene/scene_painter.dart';
export 'src/scene/scene_viewport.dart';
export 'src/scene/solid_gradient.dart';
export 'src/util/arc_sector.dart';
export 'src/util/shape_path.dart';
export 'src/widgets/geo_arc.dart';
export 'src/widgets/geo_bezier_curve.dart';
export 'src/widgets/geo_capsule.dart';
export 'src/widgets/geo_circle.dart';
export 'src/widgets/geo_ellipse.dart';
export 'src/widgets/geo_line.dart';
export 'src/widgets/geo_polygon.dart';
export 'src/widgets/geo_polyline.dart';
export 'src/widgets/geo_quadrilateral.dart';
export 'src/widgets/geo_ray.dart';
export 'src/widgets/geo_rectangle.dart';
export 'src/widgets/geo_ring.dart';
export 'src/widgets/geo_spline.dart';
export 'src/widgets/geo_triangle.dart';
export 'src/widgets/shape_clipper.dart';
export 'src/widgets/shape_widget.dart';
