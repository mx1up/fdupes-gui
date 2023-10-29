import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

class DupeInstance extends StatelessWidget {
  final String baseDir;
  final List<String> dupeGroup;
  final int index;

  const DupeInstance({
    required this.baseDir,
    required this.dupeGroup,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final showTrash = dupeGroup.length > 1;
    final showFullPath = dupeGroup.map((e) => path.dirname(e)).toSet().length != 1;
    final dupeFilepath = dupeGroup[index];
    return ListTile(
      minVerticalPadding: 0,
      leading: IconButton(
        icon: Icon(Icons.edit),
        padding: EdgeInsets.zero,
        onPressed: () => _onRenameDupeInstance(
          context: context,
          dupeFilepath: dupeFilepath,
        ),
      ),
      title: Tooltip(
        child: Text(showFullPath ? path.relative(dupeFilepath, from: baseDir) : path.basename(dupeFilepath)),
        message: dupeFilepath,
      ),
      trailing: showTrash
          ? IconButton(
              icon: Icon(Icons.delete),
              padding: EdgeInsets.zero,
              onPressed: () => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDeleteDupeInstance(dupeFilepath)),
            )
          : null,
      dense: true,
      onTap: () => _openFile(dupeFilepath),
    );
  }

  _openFile(String dup) async {
    OpenResult result = await OpenFile.open(dup);
    print(result);
  }

  void _onRenameDupeInstance({
    required BuildContext context,
    required String dupeFilepath,
  }) async {
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
  }
}
