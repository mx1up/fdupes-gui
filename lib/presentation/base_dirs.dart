import 'dart:io';

import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:fdupes_gui/presentation/select_folder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseDirs extends StatelessWidget {
  final List<Directory> baseDirs;

  const BaseDirs({
    super.key,
    required this.baseDirs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: baseDirs
          .map((dir) => [
                Row(children: [
                  ElevatedButton(
                    child: Text('Change folder'),
                    onPressed: () => showSelectFolderDialog(
                      context,
                      initialDir: dir,
                      currentDirs: baseDirs,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(dir.path),
                  IconButton(
                    icon: Icon(Icons.remove_circle),
                    visualDensity: VisualDensity.compact,
                    iconSize: 14,
                    onPressed: () =>
                        BlocProvider.of<FdupesBloc>(context).add(FdupesEventDirsSelected(baseDirs..remove(dir))),
                  ),
                ]),
                SizedBox(height: 8),
              ])
          .expand((e) => e)
          .toList(),
    );
  }
}
