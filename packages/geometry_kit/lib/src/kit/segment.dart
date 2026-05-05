import 'line.dart';

/// A segment is a finite portion of a line between two endpoints.
///
/// This is an alias for [Line], which represents a line segment
/// (not an infinite line). Use whichever name fits your domain:
/// - `Line` for general use
/// - `Segment` when you want to emphasize finiteness
typedef Segment = Line;
