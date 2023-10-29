part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesState {}

class FdupesStateInitial extends FdupesState {}
class FdupesStateError extends FdupesState {
  final String msg;

  FdupesStateError(this.msg);
}
class FdupesStateResult extends FdupesState {
  List<List<String>> dupes;
  int selectedDupe;

  FdupesStateResult(this.dupes, {this.selectedDupe});
}
