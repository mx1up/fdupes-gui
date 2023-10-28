part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesState {}

class FdupesStateInitial extends FdupesState {
  final String? initialDir;

  FdupesStateInitial(this.initialDir);
}

class FdupesStateError extends FdupesState {
  final String msg;

  FdupesStateError(this.msg);
}

class FdupesStateResult extends FdupesState {
  final String dir;
  final List<List<String>> dupes;
  //todo review nullability
  final int? selectedDupe;
  final bool loading;

  FdupesStateResult({
    required this.dir,
    required this.dupes,
    this.selectedDupe,
    this.loading = false,
  });

  FdupesStateResult copyWith({
    bool? loading,
    String? dir,
    List<List<String>>? dupes,
    int? selectedDupe,
  }) {
    return FdupesStateResult(
      dir: dir ?? this.dir,
      dupes: dupes ?? this.dupes,
      selectedDupe: selectedDupe ?? this.selectedDupe,
      loading: loading ?? this.loading,
    );
  }
}
