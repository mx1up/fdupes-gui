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
              onPressed: () => _showSelectFolderDialog(context, null),
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
                Row(children: [
                  ElevatedButton(
                    child: Text('Change folder'),
                    onPressed: () => _showSelectFolderDialog(context, state.dir),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Text(state.dir)),
                  SizedBox(width: 8),
                  ElevatedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDirSelected(state.dir)),
                  ),
                ]),
                SizedBox(height: 8),
                if (state.dupeGroups.isEmpty)
                  Text('no dupes found')
                else
                  DupesBody(
                    baseDir: state.dir,
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

  Future<void> _showSelectFolderDialog(BuildContext context, String? initialDir) async {
    final dir = await FileSelectorPlatform.instance
        .getDirectoryPath(initialDirectory: initialDir ?? util.userHome, confirmButtonText: 'Select');
    if (dir != null) {
      BlocProvider.of<FdupesBloc>(context).add(FdupesEventDirSelected(dir));
    }
  }
}
