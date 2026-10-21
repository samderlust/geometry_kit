/// Immutable 3D solids built on [`geometry_kit`](https://pub.dev/packages/geometry_kit).
///
/// Solids report volume, surface area and bounds, answer ray and
/// containment queries, slice into 2D cross-sections, and export triangle
/// meshes. Prisms and solids of revolution are built straight from
/// geometry_kit 2D shapes.
///
/// Coordinates are right-handed with Y up. Angles at the API are degrees.
library;

export 'src/bridge/cross_section.dart';
export 'src/bridge/prism.dart';
export 'src/bridge/solid_of_revolution.dart';
export 'src/camera/orbit_camera.dart';
export 'src/math/aabb.dart';
export 'src/math/plane.dart';
export 'src/math/point3.dart';
export 'src/math/quaternion.dart';
export 'src/math/ray3.dart';
export 'src/math/segment3.dart';
export 'src/mesh/mesh.dart';
export 'src/solid/box.dart';
export 'src/solid/cone.dart';
export 'src/solid/cylinder.dart';
export 'src/solid/revolved_solid.dart';
export 'src/solid/solid.dart';
export 'src/solid/sphere.dart';
