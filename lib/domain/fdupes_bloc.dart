import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:process_run/which.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'fdupes_event.dart';
part 'fdupes_state.dart';

class FdupesBloc extends Bloc<FdupesEvent, FdupesState> {
  final List<Directory>? initialDirs;
  String? fdupesLocation;

  FdupesBloc({this.initialDirs}) : super(FdupesStateInitial(initialDirs)) {
    on<FdupesEventCheckFdupesAvailability>(_onCheckFdupesAvailability);
    on<FdupesEventSelectFdupesLocation>(_onSelectFdupesLocation);
    on<FdupesEventDirsSelected>(_onDirsSelected);
    on<FdupesEventDupeSelected>(_onDupeSelected);
    on<FdupesEventDeleteDupeInstance>(_onDeleteDupeInstance);
    on<FdupesEventRenameDupeInstance>(_onRenameDupeInstance);
    add(FdupesEventCheckFdupesAvailability());
  }

  FutureOr<void> _onCheckFdupesAvailability(FdupesEventCheckFdupesAvailability event, Emitter<FdupesState> emit) async {
    emit(FdupesStateLoading(msg: 'Locating fdupes binary..'));
    fdupesLocation = await which('fdupes');
    print('which(fdupes) = $fdupesLocation');
    if (fdupesLocation == null) {
      print('fdupes not found, check custom location');
      final sharedPrefs = await SharedPreferences.getInstance();
      final customFdupesLocation = sharedPrefs.getString('fdupes_location');
      print('customFdupesLocation = $customFdupesLocation');
      if (customFdupesLocation != null && await validFdupesLocation(customFdupesLocation)) {
        fdupesLocation = customFdupesLocation;
      }
    }
    final fdupesFound = fdupesLocation != null;
    if (!fdupesFound) {
      emit(FdupesStateFdupesNotFound());
      return;
    }
    if (initialDirs != null) {
      add(FdupesEventDirsSelected(initialDirs!));
    } else {
      emit(FdupesStateInitial(initialDirs));
    }
  }

  FutureOr<void> _onSelectFdupesLocation(FdupesEventSelectFdupesLocation event, Emitter<FdupesState> emit) async {
    emit(FdupesStateLoading(msg: 'Checking for valid fdupes binary..'));
    final validLocation = await validFdupesLocation(event.fdupesLocation);

    if (validLocation) {
      final sharedPrefs = await SharedPreferences.getInstance();
      final saved = await sharedPrefs.setString('fdupes_location', event.fdupesLocation);
      if (!saved) {
        emit(FdupesStateFdupesNotFound(statusMsg: 'Failed to save custom fdupes location preference.'));
        return;
      }
      add(FdupesEventCheckFdupesAvailability());
    }
    else emit(FdupesStateFdupesNotFound(statusMsg: 'Not a valid fdupes binary.'));
  }

  Future<bool> validFdupesLocation(String path) async {
    try {
      ProcessResult result = await Process.run(path, ['--version']);
      return result.exitCode == 0 && (result.stdout as String).split(' ')[0] == 'fdupes';
    } catch (e) {
      print(e);
      return false;
    }
  }

  FutureOr<void> _onDirsSelected(FdupesEventDirsSelected event, Emitter<FdupesState> emit) async {
    final s = state;
    if (s is FdupesStateInitial) {
      emit(FdupesStateResult(dirs: event.dirs, dupeGroups: [], loading: true));
    }
    if (s is FdupesStateResult) {
      emit(s.copyWith(loading: true));
    }
    final dupes = await findDupes(event.dirs, emit: emit);

    emit(FdupesStateResult(dirs: event.dirs, dupeGroups: dupes));
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
      final newDupes = List.of(s.dupeGroups)
          .map((dupeList) {
            return List.of(dupeList)..remove(event.filename);
          })
          .where((dupeList) => dupeList.length > 1)
          .toList();
      late final int? selectedDupe;
      if (newDupes.isEmpty) {
        selectedDupe = null;
      } else if (s.selectedDupeGroup != null) {
        //todo what's going on here
        selectedDupe = s.selectedDupeGroup! % newDupes.length;
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
      final dupeGroup = s.dupeGroups.firstWhere((element) => element.contains(event.filename));
      final updatedDupeGroup = List.of(dupeGroup)
        ..remove(event.filename)
        ..add(event.newFilename);
      final newDupes = List.of(s.dupeGroups)
        ..remove(dupeGroup)
        ..add(updatedDupeGroup);

      emit(s.copyWith(dupes: newDupes));
    } catch (exc) {
      emit(FdupesStateError('failed to rename file ${event.filename}: $exc'));
    }
  }

  Future<List<List<String>>> findDupes(List<Directory> dirs, {required Emitter<FdupesState> emit}) async {
    print("finding dupes in dirs $dirs");
    List<List<String>> dupes = [];
    Process process = await Process.start(fdupesLocation!, ['-r', ...dirs.map((d) => d.path)]);
    // stdout.addStream(process.stdout);
    final regex = RegExp(r'\[(\d+)/(\d+)\]');
    final stderrBC = process.stderr.asBroadcastStream();
    stderrBC.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final currentString = match.group(1);
        final totalString = match.group(2);
        if (currentString != null && totalString != null) {
          final current = int.tryParse(currentString);
          final total = int.tryParse(totalString);
          if (current != null && total != null) {
            final progress = 100.0 * current / total;
            emit(FdupesStateLoading(progress: progress.toInt()));
          }
        }
      }
    });
    stderr.addStream(stderrBC);
    // each line contains the absolute path of a duplicate file
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
