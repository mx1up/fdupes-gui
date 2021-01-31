import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class DupeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FdupesBloc, FdupesState>(
      builder: (context, state) {
          return Container(
            child: Column(
              children: <Widget>[
                Row(children: [
              RaisedButton(
                child: Icon(Icons.refresh),
                onPressed: () => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDirSelected(state.dir)),
              ),
              Expanded(child: Text(state.dir)),
                  RaisedButton(
                    child: Text('Select folder'),
                    onPressed: () async => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDirSelected(await FileSelectorPlatform.instance
                        .getDirectoryPath(initialDirectory: '/home/matthias', confirmButtonText: 'Select'))),
                  ),
                ]),
                if (state is FdupesStateResult)
                  if (state.dupes.isEmpty)
                    Text('Select dir')
                  else
                    showFileTree(context, state),
                if (state is FdupesStateError)
                    Text(state.msg),
              ],
            ),
          );
        }
    );
  }

  showFileTree(BuildContext context, FdupesStateResult state) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => InkWell(
                onTap: () =>  BlocProvider.of<FdupesBloc>(context).add(FdupesEventDupeSelected(index)),
                  child: Text(state.dupes[index][0])),
              itemCount: state.dupes.length,
            ),
          ),
          if (state.selectedDupe != null ) Expanded(
            child: ListView.builder(
                itemBuilder: (context, index) => createDupeInstanceWidget(
                    context, state.dupes[state.selectedDupe][index], state.dupes[state.selectedDupe].length > 1),
                itemCount: state.dupes[state.selectedDupe].length,
            ),
          ),
        ],
      ),
    );
  }

  Widget createDupeInstanceWidget(BuildContext context, String dupeFilename, bool showTrash) {
    return InkWell(
      child: Row(
        children: [
          Text(dupeFilename),
          if (showTrash)
            InkWell(
              child: Icon(Icons.delete),
              onTap: () => BlocProvider.of<FdupesBloc>(context).add(FdupesEventDeleteDupeInstance(dupeFilename)),
            )
        ],
      ),
      onTap: () => openFile(dupeFilename),
    );
  }

  _launchURL(String url) async {
    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  openFile(String dup) async {
    OpenResult result = await OpenFile.open(dup);
    print(result);
  }
}
