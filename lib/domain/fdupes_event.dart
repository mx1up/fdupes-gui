part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesEvent {}


class FdupesEventCheckFdupesAvailability extends FdupesEvent {
  FdupesEventCheckFdupesAvailability();
}

class FdupesEventSelectFdupesLocation extends FdupesEvent {
  final String fdupesLocation;

  FdupesEventSelectFdupesLocation(this.fdupesLocation);
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

class FdupesEventDirsSelected extends FdupesEvent {
  final List<String> dirs;

  FdupesEventDirsSelected(this.dirs);
}

class FdupesEventDupeSelected extends FdupesEvent {
  final int index;

  FdupesEventDupeSelected(this.index);
}
