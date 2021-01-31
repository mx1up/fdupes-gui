part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesEvent {}


class FdupesEventDeleteDupeInstance extends FdupesEvent {
  final String filename;

  FdupesEventDeleteDupeInstance(this.filename);
}

class FdupesEventDirSelected extends FdupesEvent {
  final String dir;

  FdupesEventDirSelected(this.dir);
}

class FdupesEventDupeSelected extends FdupesEvent {
  final int index;

  FdupesEventDupeSelected(this.index);
}
