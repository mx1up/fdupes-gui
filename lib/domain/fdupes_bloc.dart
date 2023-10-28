import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:fdupes_gui/core/util.dart' as util;
import 'package:meta/meta.dart';
import 'package:process_run/which.dart';

part 'fdupes_event.dart';

part 'fdupes_state.dart';

class FdupesBloc extends Bloc<FdupesEvent, FdupesState> {
  List<List<String>> dupes = [];
  int? selectedDupe;
  var fdupesFound;

  String dir = '';

  FdupesBloc(String initialDir) : super(FdupesStateInitial(initialDir)) {
    on<FdupesEventDirSelected>((event, emit) async {
      if (fdupesFound == null) {
        var fdupesPath = await which('fdupes');
        print("fdupes = $fdupesPath");
        fdupesFound = fdupesPath != null;
      }
      if (!fdupesFound) {
        emit(FdupesStateError(event.dir, "fdupes not found"));
        return;
      }

      dir = event.dir;
      dupes = await findDupes(event.dir);

      emit(FdupesStateResult(dir, dupes));
    });
    on<FdupesEventDupeSelected>((event, emit) {
      selectedDupe = event.index;
      emit(FdupesStateResult(dir, dupes, selectedDupe: event.index));
    });
    on<FdupesEventDeleteDupeInstance>((event, emit) {
      var file = File(event.filename);
      try {
        print("deleting $file");
        file.deleteSync();
        dupes.forEach((dupeList) { dupeList.remove(event.filename);});
        dupes.removeWhere((dupeList) => dupeList.length == 1);
        if (dupes.isEmpty) {
          selectedDupe = null;
        } else if (selectedDupe != null) {
          //todo what's going on here
          selectedDupe = selectedDupe! % dupes.length;
        }
        emit(FdupesStateResult(dir, dupes, selectedDupe: selectedDupe));
      } catch (exc) {
        emit(FdupesStateError(dir, "failed to delete file ${event.filename}: $exc"));
      }

    },);
    on<FdupesEventRenameDupeInstance>((event, emit) async {
      print('rename ${event.filename} to ${event.newFilename}');
      try {
        var file = File(event.filename);
        if (await File(event.newFilename).exists()) {
      print('cancel rename, target already exists: ${event.newFilename}');
      return;
      }
      await file.rename(event.newFilename);
      var dupeGroup = dupes.firstWhere((element) => element.contains(event.filename));
      dupeGroup.remove(event.filename);
      dupeGroup.add(event.newFilename);

      emit(FdupesStateResult(dir, dupes, selectedDupe: selectedDupe));
      } catch (exc) {
      emit(FdupesStateError(dir, "failed to rename file ${event.filename}: $exc"));
      }
    },);
  }

  Future<List<List<String>>> findDupes(String dir) async {
    print("finding dupes in dir $dir");
    List<List<String>> dupes = [];
    Process process = await Process.start('fdupes', ['-r', dir]);
    // stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    List<String> lines = await process.stdout.transform(utf8.decoder).transform(const LineSplitter()).toList();
    lines.forEach((element) {print(element);});

    while (lines.isNotEmpty) {
      var newDupe = lines.takeWhile((value) => value.isNotEmpty);
      dupes.add(newDupe.toList());
      lines.removeRange(0, newDupe.length +1);
    }


    return dupes;
  }
}
