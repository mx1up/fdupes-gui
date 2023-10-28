import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:process_run/which.dart';

part 'fdupes_event.dart';
part 'fdupes_state.dart';

class FdupesBloc extends Bloc<FdupesEvent, FdupesState> {
  final String? initialDir;

  FdupesBloc({this.initialDir}) : super(FdupesStateInitial(initialDir)) {
    on<FdupesEventCheckFdupesAvailability>(_onCheckFdupesAvailability);
    on<FdupesEventDirSelected>(_onDirSelected);
    on<FdupesEventDupeSelected>(_onDupeSelected);
    on<FdupesEventDeleteDupeInstance>(_onDeleteDupeInstance);
    on<FdupesEventRenameDupeInstance>(_onRenameDupeInstance);
    add(FdupesEventCheckFdupesAvailability());
  }

  FutureOr<void> _onCheckFdupesAvailability(FdupesEventCheckFdupesAvailability event, Emitter<FdupesState> emit) async {
    final fdupesPath = await which('fdupes');
    print('fdupes = $fdupesPath');
    final fdupesFound = fdupesPath != null;
    if (!fdupesFound) {
      emit(FdupesStateError('fdupes not found'));
      return;
    }
    if (initialDir != null) {
      add(FdupesEventDirSelected(initialDir!));
    } else {
      emit(FdupesStateInitial(initialDir));
    }
  }

  FutureOr<void> _onDirSelected(FdupesEventDirSelected event, Emitter<FdupesState> emit) async {
    final s = state;
    if (s is FdupesStateInitial) {
      emit(FdupesStateResult(dir: event.dir, dupes: [], loading: true));
    }
    if (s is FdupesStateResult) {
      emit(s.copyWith(loading: true));
    }
    final dupes = await findDupes(event.dir);

    emit(FdupesStateResult(dir: event.dir, dupes: dupes));
  }

  void _onDupeSelected(FdupesEventDupeSelected event, Emitter<FdupesState> emit) {
    final s = state;
    if (s is! FdupesStateResult) {
      print('wrong state');
      return;
    }
    emit(s.copyWith(selectedDupe: event.index));
  }

  FutureOr<void> _onDeleteDupeInstance(FdupesEventDeleteDupeInstance event, Emitter<FdupesState> emit) async {
    final s = state;
    if (s is! FdupesStateResult) {
      print('wrong state');
      return;
    }

    final file = File(event.filename);
    try {
      print("deleting $file");
      await file.delete();
      final newDupes = List.of(s.dupes)
          .map((dupeList) {
            return List.of(dupeList)..remove(event.filename);
          })
          .where((dupeList) => dupeList.length > 1)
          .toList();
      late final int? selectedDupe;
      if (newDupes.isEmpty) {
        selectedDupe = null;
      } else if (s.selectedDupe != null) {
        //todo what's going on here
        selectedDupe = s.selectedDupe! % newDupes.length;
      }
      emit(s.copyWith(dupes: newDupes, selectedDupe: selectedDupe));
    } catch (exc) {
      emit(FdupesStateError('failed to delete file ${event.filename}: $exc'));
    }
  }

  FutureOr<void> _onRenameDupeInstance(FdupesEventRenameDupeInstance event, Emitter<FdupesState> emit) async {
    print('rename ${event.filename} to ${event.newFilename}');
    final s = state;
    if (s is! FdupesStateResult) {
      print('wrong state');
      return;
    }
    try {
      final file = File(event.filename);
      if (await File(event.newFilename).exists()) {
        print('cancel rename, target already exists: ${event.newFilename}');
        return;
      }
      await file.rename(event.newFilename);
      final dupeGroup = s.dupes.firstWhere((element) => element.contains(event.filename));
      final updatedDupeGroup = List.of(dupeGroup)
        ..remove(event.filename)
        ..add(event.newFilename);
      final newDupes = List.of(s.dupes)
        ..remove(dupeGroup)
        ..add(updatedDupeGroup);

      emit(s.copyWith(dupes: newDupes));
    } catch (exc) {
      emit(FdupesStateError('failed to rename file ${event.filename}: $exc'));
    }
  }

  Future<List<List<String>>> findDupes(String dir) async {
    print("finding dupes in dir $dir");
    List<List<String>> dupes = [];
    Process process = await Process.start('fdupes', ['-r', dir]);
    // stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    List<String> lines = await process.stdout.transform(utf8.decoder).transform(const LineSplitter()).toList();
    lines.forEach((element) {
      print(element);
    });

    while (lines.isNotEmpty) {
      var newDupe = lines.takeWhile((value) => value.isNotEmpty);
      dupes.add(newDupe.toList());
      lines.removeRange(0, newDupe.length + 1);
    }

    return dupes;
  }
}
