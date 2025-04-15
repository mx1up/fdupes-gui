import 'dart:io';

import 'package:fdupes_gui/core/util.dart' as util;
import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showSelectFolderDialog(
    BuildContext context, {
      Directory? initialDir,
      required List<Directory> currentDirs,
    }) async {
  final dir = await FileSelectorPlatform.instance
      .getDirectoryPath(initialDirectory: initialDir?.path ?? util.userHome, confirmButtonText: 'Select');
  if (dir != null) {
    if (initialDir != null) {
      currentDirs.remove(initialDir);
    }
    currentDirs.add(Directory(dir));
    BlocProvider.of<FdupesBloc>(context).add(FdupesEventDirsSelected(currentDirs));
  }
}
