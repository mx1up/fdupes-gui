import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:fdupes_gui/presentation/dupe_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

class DupesBody extends StatelessWidget {
  final String baseDir;
  final List<List<String>> dupeGroups;
  final int? selectedDupeGroup;

  const DupesBody({
    required this.baseDir,
    required this.dupeGroups,
    this.selectedDupeGroup,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => ListTile(
                onTap: () => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDupeSelected(index)),
                selected: _isSelectedItem(dupeGroups, selectedDupeGroup, index),
                dense: true,
                visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity),
                minVerticalPadding: 0,
                title: Text(path.relative(dupeGroups[index][0], from: baseDir)),
              ),
              itemCount: dupeGroups.length,
            ),
          ),
          if (selectedDupeGroup != null) ...[
            VerticalDivider(thickness: 4),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => DupeInstance(
                  baseDir: baseDir,
                  dupeGroup: dupeGroups[selectedDupeGroup!],
                  index: index,
                ),
                itemCount: dupeGroups[selectedDupeGroup!].length,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isSelectedItem(List<List<String>> dupeGroups, int? selectedDupeGroup, int index) =>
      selectedDupeGroup != null && dupeGroups[index] == dupeGroups[selectedDupeGroup];
}
