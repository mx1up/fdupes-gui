import 'package:fdupes_gui/core/util.dart' as util;
import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:fdupes_gui/presentation/dupes_body.dart';
import 'package:fdupes_gui/presentation/dupes_top_bar.dart';
import 'package:fdupes_gui/presentation/select_folder_dialog.dart';
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
              onPressed: () => showSelectFolderDialog(context, initialDir: null, currentDirs: []),
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
                DupesTopBar(baseDirs: state.dirs),
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
