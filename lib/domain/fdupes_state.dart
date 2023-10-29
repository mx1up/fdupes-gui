part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesState extends Equatable {}

class FdupesStateInitial extends FdupesState {
  final String? initialDir;

  FdupesStateInitial(this.initialDir);

  @override
  List<Object?> get props => [initialDir];
}

class FdupesStateError extends FdupesState {
  final String msg;

  FdupesStateError(this.msg);

  @override
  List<Object?> get props => [msg];
}

class FdupesStateLoading extends FdupesState {
  final String? msg;
  final int? progress;

  FdupesStateLoading({this.msg, this.progress});

  @override
  List<Object?> get props => [msg, progress];
}

class FdupesStateResult extends FdupesState {
  final String dir;
  final List<List<String>> dupeGroups;
  //todo review nullability
  final int? selectedDupeGroup;
  final bool loading;

  @override
  List<Object?> get props => [
        dir,
        dupeGroups,
        selectedDupeGroup,
        loading,
      ];

  FdupesStateResult({
    required this.dir,
    required this.dupeGroups,
    this.selectedDupeGroup,
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
      dupeGroups: dupes ?? this.dupeGroups,
      selectedDupeGroup: selectedDupe ?? this.selectedDupeGroup,
      loading: loading ?? this.loading,
    );
  }
}
