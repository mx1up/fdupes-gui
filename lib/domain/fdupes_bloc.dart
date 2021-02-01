import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:process_run/which.dart';

part 'fdupes_event.dart';

part 'fdupes_state.dart';

class FdupesBloc extends Bloc<FdupesEvent, FdupesState> {
  List<List<String>> dupes = [];
  int selectedDupe;
  var fdupesFound;

  String dir;

  FdupesBloc() : super(FdupesStateInitial());

  @override
  Stream<FdupesState> mapEventToState(
    FdupesEvent event,
  ) async* {
    if (event is FdupesEventDirSelected) {
      if (fdupesFound == null) {
        var fdupesPath = await which('fdupes');
        print("fdupes = $fdupesPath");
        fdupesFound = fdupesPath != null;
      }
      if (!fdupesFound) {
        yield FdupesStateResult(event.dir, dupes);
        return;
      }

      dir = event.dir;
      dupes = await findDupes(event.dir);

      yield FdupesStateResult(dir, dupes);
    }
    if (event is FdupesEventDupeSelected) {
      selectedDupe = event.index;
      yield FdupesStateResult(dir, dupes, selectedDupe: event.index);
    }
    if (event is FdupesEventDeleteDupeInstance) {
      var file = File(event.filename);
      try {
        print("deleting $file");
        file.deleteSync();
        dupes.forEach((dupeList) { dupeList.remove(event.filename);});
        dupes.removeWhere((dupeList) => dupeList.length == 1);
        if (dupes.isEmpty) {
          selectedDupe = null;
        } else {
          selectedDupe %= dupes.length;
        }
        yield FdupesStateResult(dir, dupes, selectedDupe: selectedDupe);
      } catch (exc) {
        yield FdupesStateError(dir, "failed to delete file ${event.filename}: $exc");
      }
    }
    if (event is FdupesEventRenameDupeInstance) {
      print('rename ${event.filename} to ${event.newFilename}');
      try {
        var file = File(event.filename);
        if (await File(event.newFilename).exists()) {
          print('cancel rename, target already exists: ${event.newFilename}');
          return;
        }
        await file.rename(event.newFilename);
        //todo rename entries in cache instead of rededupe
        add(FdupesEventDirSelected(dir));
      } catch (exc) {
        yield FdupesStateError(dir, "failed to rename file ${event.filename}: $exc");
      }
    }
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
