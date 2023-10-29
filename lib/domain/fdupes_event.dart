part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesEvent {}


class FdupesEventDirSelected extends FdupesEvent {
  final String dir;

  FdupesEventDirSelected(this.dir);
}

class FdupesEventDupeSelected extends FdupesEvent {
  final int index;

  FdupesEventDupeSelected(this.index);
}
