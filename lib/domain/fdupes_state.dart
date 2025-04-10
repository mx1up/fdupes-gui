part of 'fdupes_bloc.dart';

@immutable
abstract class FdupesState extends Equatable {}

class FdupesStateInitial extends FdupesState {
  final List<Directory>? initialDirs;

  FdupesStateInitial(this.initialDirs);

  @override
  List<Object?> get props => [initialDirs];
}

class FdupesStateError extends FdupesState {
  final String msg;

  FdupesStateError(this.msg);

  @override
  List<Object?> get props => [msg];
}

class FdupesStateFdupesNotFound extends FdupesState {
  final String? statusMsg;

  FdupesStateFdupesNotFound({this.statusMsg});

  @override
  List<Object?> get props => [statusMsg];
}

class FdupesStateLoading extends FdupesState {
  final String? msg;
  final int? progress;

  FdupesStateLoading({this.msg, this.progress});

  @override
  List<Object?> get props => [msg, progress];
}

class FdupesStateResult extends FdupesState {
  final List<Directory> dirs;
  final List<List<String>> dupeGroups;
  //todo review nullability
  final int? selectedDupeGroup;
  final bool loading;

  @override
  List<Object?> get props => [
        dirs,
        dupeGroups,
        selectedDupeGroup,
        loading,
      ];

  FdupesStateResult({
    required this.dirs,
    required this.dupeGroups,
    this.selectedDupeGroup,
    this.loading = false,
  });

  FdupesStateResult copyWith({
    bool? loading,
    List<Directory>? dirs,
    List<List<String>>? dupes,
    int? selectedDupe,
  }) {
    return FdupesStateResult(
      dirs: dirs ?? this.dirs,
      dupeGroups: dupes ?? this.dupeGroups,
      selectedDupeGroup: selectedDupe ?? this.selectedDupeGroup,
      loading: loading ?? this.loading,
    );
  }
}
