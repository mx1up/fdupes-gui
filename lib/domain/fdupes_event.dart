part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesEvent {}


class FdupesEventCheckFdupesAvailability extends FdupesEvent {
  FdupesEventCheckFdupesAvailability();
}

class FdupesEventDeleteDupeInstance extends FdupesEvent {
  final String filename;

  FdupesEventDeleteDupeInstance(this.filename);
}

class FdupesEventRenameDupeInstance extends FdupesEvent {
  final String filename;
  final String newFilename;

  FdupesEventRenameDupeInstance(this.filename, this.newFilename);
}

class FdupesEventDirSelected extends FdupesEvent {
  final String dir;

  FdupesEventDirSelected(this.dir);
}

class FdupesEventDupeSelected extends FdupesEvent {
  final int index;

  FdupesEventDupeSelected(this.index);
}
