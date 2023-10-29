import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:process_run/which.dart';

part 'fdupes_event.dart';

part 'fdupes_state.dart';

class FdupesBloc extends Bloc<FdupesEvent, FdupesState> {
  var dupes = [
    [
      'dupe1a',
      'dupe1b',
      'dupe1c',
      'dupe1d',
    ],
    [
      'dupe2a',
      'dupe2b',
      'dupe2c',
    ]
  ];
  var fdupesFound;

  FdupesBloc() : super(FdupesStateResult([]));

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
        yield FdupesStateResult(dupes);
        return;
      }

      dupes = await findDupes(event.dir);

      yield FdupesStateResult(dupes);
    }
    if (event is FdupesEventDupeSelected) {
      yield FdupesStateResult(dupes, selectedDupe: event.index);
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
