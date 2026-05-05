/// Flutter widgets for [`geometry_kit`](https://pub.dev/packages/geometry_kit)
/// shapes.
///
/// Provides declarative `Geo*` widgets for circles, ellipses, rectangles,
/// triangles, quadrilaterals, polygons, and lines, plus a `GeometryCanvas`
/// for multi-shape scenes. Styling flows through `ShapeStyle` / `ShapeStyleTheme`.
/// Coordinate transforms (Y-up, centered, …) flow through `CoordinateMapper`.
library;

export 'src/coord/coordinate_mapper.dart';
export 'src/style/dash_pattern.dart';
export 'src/style/shape_style.dart';
export 'src/style/shape_style_theme.dart';
export 'src/canvas/geometry_canvas.dart';
export 'src/canvas/styled_shape.dart';
export 'src/widgets/geo_circle.dart';
export 'src/widgets/geo_ellipse.dart';
export 'src/widgets/geo_line.dart';
export 'src/widgets/geo_polygon.dart';
export 'src/widgets/geo_quadrilateral.dart';
export 'src/widgets/geo_rectangle.dart';
export 'src/widgets/geo_triangle.dart';
