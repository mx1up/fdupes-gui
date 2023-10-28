import 'package:fdupes_gui/core/util.dart' as util;
import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

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
        if (state is FdupesStateResult) {
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
                if (state.dupes.isEmpty) Text('no dupes found') else showFileTree(context, state),
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

  showFileTree(BuildContext context, FdupesStateResult state) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => InkWell(
                onTap: () => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDupeSelected(index)),
                child: Container(
                  color: isSelectedItem(state, index) ? Colors.black26 : null,
                  child: Text(path.relative(state.dupes[index][0], from: state.dir)),
                ),
              ),
              itemCount: state.dupes.length,
            ),
          ),
          if (state.selectedDupe != null)
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => createDupeInstanceWidget(
                    context: context,
                    baseDir: state.dir,
                    dupeFilepath: state.dupes[state.selectedDupe!][index],
                    showTrash: state.dupes[state.selectedDupe!].length > 1,
                    showFullPath: state.dupes[state.selectedDupe!].map((e) => path.dirname(e)).toSet().length != 1),
                itemCount: state.dupes[state.selectedDupe!].length,
              ),
            ),
        ],
      ),
    );
  }

  bool isSelectedItem(FdupesStateResult state, int index) =>
      state.selectedDupe != null && state.dupes[index] == state.dupes[state.selectedDupe!];

  Widget createDupeInstanceWidget({
    required BuildContext context,
    required String baseDir,
    required String dupeFilepath,
    required bool showTrash,
    required bool showFullPath,
  }) {
    return Row(
      children: [
        InkWell(
          child: Icon(Icons.edit),
          onTap: () async {
            final newFileSaveLocation = await FileSelectorPlatform.instance.getSaveLocation(
              options: SaveDialogOptions(
                initialDirectory: path.dirname(dupeFilepath),
                suggestedName: path.basename(dupeFilepath),
                confirmButtonText: "Rename",
              ),
            );
            if (newFileSaveLocation != null) {
              final newFilePath = newFileSaveLocation.path;
              if (newFilePath != dupeFilepath) {
                BlocProvider.of<FdupesBloc>(context).add(FdupesEventRenameDupeInstance(dupeFilepath, newFilePath));
              }
            }
          },
        ),
        Expanded(
          child: InkWell(
            onTap: () => openFile(dupeFilepath),
            child: Tooltip(
              child: Text(showFullPath ? path.relative(dupeFilepath, from: baseDir) : path.basename(dupeFilepath)),
              message: dupeFilepath,
            ),
          ),
        ),
        if (showTrash)
          InkWell(
            child: Icon(Icons.delete),
            onTap: () => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDeleteDupeInstance(dupeFilepath)),
          )
      ],
    );
  }

  openFile(String dup) async {
    OpenResult result = await OpenFile.open(dup);
    print(result);
  }
}

class AddTaskDialog extends StatefulWidget {
  final String filename;

  AddTaskDialog(this.filename);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late final TextEditingController _filenameController;

  @override
  void initState() {
    super.initState();
    _filenameController = TextEditingController(text: widget.filename);
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit filename'),
      content: Row(
        children: [
          Text('new filename:'),
          Expanded(
              child: TextField(
            controller: _filenameController,
          )),
        ],
      ),
      actions: <Widget>[
        TextButton(
            child: Text('Rename'),
            onPressed: () {
              Navigator.pop(context, _filenameController.text);
            }),
      ],
    );
  }
}
