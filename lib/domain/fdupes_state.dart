part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesState {
  final String dir;

  FdupesState(this.dir);
}

class FdupesStateInitial extends FdupesState {

  FdupesStateInitial() : super(util.userHome + '/Music');
}

class FdupesStateError extends FdupesState {
  final String msg;

  FdupesStateError(String dir, this.msg) : super(dir);
}
class FdupesStateResult extends FdupesState {
  List<List<String>> dupes;
  int selectedDupe;

  FdupesStateResult(String dir, this.dupes, {this.selectedDupe}) : super(dir);
}
