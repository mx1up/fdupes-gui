import 'dart:io';

import 'package:fdupes_gui/core/util.dart' as util;
import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:fdupes_gui/presentation/dupes_body.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DupeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FdupesBloc, FdupesState>(
      builder: (context, state) {
        if (state is FdupesStateInitial) {
          return Center(
            child: ElevatedButton(
              child: Text('Select folder'),
              onPressed: () => _showSelectFolderDialog(context, initialDir: null, currentDirs: []),
            ),
          );
        }
        if (state is FdupesStateFdupesNotFound) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Fdupes binary not found.'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _locateBinary(context),
                  child: Text('Locate'),
                ),
                if (state.statusMsg != null) ...[
                  SizedBox(height: 16),
                  Text(
                    state.statusMsg!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ]
              ],
            ),
          );
        }
        if (state is FdupesStateError) {
          return Center(child: Text(state.msg));
        }
        if (state is FdupesStateLoading) {
          return Center(
            child: CircularProgressIndicator(value: state.progress != null ? state.progress!.toDouble() / 100.0 : null),
          );
        }
        if (state is FdupesStateResult) {
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: state.dirs
                            .map((dir) => [
                                  Row(children: [
                                    ElevatedButton(
                                      child: Text('Change folder'),
                                      onPressed: () => _showSelectFolderDialog(
                                        context,
                                        initialDir: dir,
                                        currentDirs: state.dirs,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(dir.path),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle),
                                      visualDensity: VisualDensity.compact,
                                      iconSize: 14,
                                      onPressed: () => BlocProvider.of<FdupesBloc>(context)
                                          .add(FdupesEventDirsSelected(state.dirs..remove(dir))),
                                    ),
                                  ]),
                                  SizedBox(height: 8),
                                ])
                            .expand((e) => e)
                            .toList(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      children: [
                        Tooltip(
                          message: 'Find duplicates',
                          child: ElevatedButton(
                            child: Icon(Icons.refresh),
                            onPressed: () =>
                                BlocProvider.of<FdupesBloc>(context).add(FdupesEventDirsSelected(state.dirs)),
                          ),
                        ),
                        SizedBox(height: 8),
                        Tooltip(
                          message: 'Add input folder',
                          child: ElevatedButton(
                            child: Icon(Icons.add),
                            onPressed: () =>
                                _showSelectFolderDialog(context, initialDir: null, currentDirs: state.dirs),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (state.dupeGroups.isEmpty)
                  Text('no dupes found')
                else
                  DupesBody(
                    baseDirs: state.dirs,
                    dupeGroups: state.dupeGroups,
                    selectedDupeGroup: state.selectedDupeGroup,
                  ),
              ],
            ),
          );
        }
        throw StateError('unexpected state $state');
      },
    );
  }

  Future<void> _showSelectFolderDialog(
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

  Future<void> _locateBinary(BuildContext context) async {
    final fdupesBloc = context.read<FdupesBloc>();
    final fdupesLocation = await FileSelectorPlatform.instance.openFile(
      initialDirectory: util.userHome,
      confirmButtonText: 'Select',
    );
    if (fdupesLocation == null) return;
    fdupesBloc.add(FdupesEventSelectFdupesLocation(fdupesLocation.path));
  }
}
