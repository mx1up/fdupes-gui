import 'dart:io';

import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:fdupes_gui/presentation/about_dialog.dart';
import 'package:fdupes_gui/presentation/base_dirs.dart';
import 'package:fdupes_gui/presentation/select_folder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DupesTopBar extends StatelessWidget {
  final List<Directory> baseDirs;

  DupesTopBar({
    super.key,
    required this.baseDirs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Tooltip(
              message: 'Find duplicates',
              child: ElevatedButton(
                child: Icon(Icons.refresh),
                onPressed: () => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDirsSelected(baseDirs)),
              ),
            ),
            SizedBox(height: 8),
            Tooltip(
              message: 'Add input folder',
              child: ElevatedButton(
                child: Icon(Icons.add),
                onPressed: () => showSelectFolderDialog(context, initialDir: null, currentDirs: baseDirs),
              ),
            ),
          ],
        ),
        SizedBox(width: 8),
        Expanded(
          child: BaseDirs(baseDirs: baseDirs),
        ),
        Tooltip(
          message: 'Find duplicates',
          child: ElevatedButton(
            child: Icon(Icons.info_outline),
            onPressed: () => showAboutDialoog(context),
          ),
        ),
      ],
    );
  }
}
