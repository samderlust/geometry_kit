import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Whether a shape with these drag callbacks is draggable: any one set.
///
/// The single definition behind `StyledShape.isDraggable`,
/// `ShapePointerRegion.draggable` and `GeoShapeContainer`, so a new drag
/// callback only needs adding here. Not part of the public API.
bool hasDragCallbacks(
  VoidCallback? onDragStart,
  ValueChanged<Offset>? onDragUpdate,
  ValueChanged<Offset>? onDragEnd,
) => onDragStart != null || onDragUpdate != null || onDragEnd != null;
