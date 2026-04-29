import '../../geometry_kit.dart';

mixin TransformationsMixin<T> {
  T translate(double dx, double dy);
  T rotate(double angle, {Point? pivot});
  T scale(double factor, {Point? pivot});
}
