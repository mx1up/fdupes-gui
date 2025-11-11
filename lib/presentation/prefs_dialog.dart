import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showPreferencesDialog(
  BuildContext context,
  SharedPreferences sharedPreferences,
) async {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => PreferencesDialog(sharedPreferences),
  );
}

class PreferencesDialog extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  PreferencesDialog(this.sharedPreferences);

  @override
  State<PreferencesDialog> createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<PreferencesDialog> {
  late bool skipEmpty;
  late bool useCache;

  @override
  void initState() {
    super.initState();
    skipEmpty = widget.sharedPreferences.getBool('noempty') ?? false;
    useCache = widget.sharedPreferences.getBool('usecache') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Preferences'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Skip empty files', softWrap: false),
            value: skipEmpty,
            onChanged: (value) {
              setState(() {
                skipEmpty = value;
                widget.sharedPreferences.setBool('noempty', value);
              });
            },
          ),
          SwitchListTile(
              title: const Text('Use cache'),
              subtitle: const Text('fdupes 2.3.0+', softWrap: false),
              value: widget.sharedPreferences.getBool('usecache') ?? false,
              onChanged: (value) {
                setState(() {
                  useCache = value;
                  widget.sharedPreferences.setBool('usecache', value);
                });
              }),
        ],
      ),
    );
  }
}
