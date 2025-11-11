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
  /// use local state instead of directly accessing shared preferences since we write the settings asynchronously without waiting
  late bool skipEmpty;
  late bool useCache;
  late bool followSymlinks;

  @override
  void initState() {
    super.initState();
    skipEmpty = widget.sharedPreferences.getBool('noempty') ?? false;
    useCache = widget.sharedPreferences.getBool('usecache') ?? false;
    followSymlinks = widget.sharedPreferences.getBool('followsymlinks') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Preferences'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text(
              'Skip empty files',
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
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
              subtitle: const Text(
                'fdupes 2.3.0+',
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
              value: useCache,
              onChanged: (value) {
                setState(() {
                  useCache = value;
                  widget.sharedPreferences.setBool('usecache', value);
                });
              }),
          SwitchListTile(
              title: const Text('Follow symlinks'),
              value: followSymlinks,
              onChanged: (value) {
                setState(() {
                  followSymlinks = value;
                  widget.sharedPreferences.setBool('followsymlinks', value);
                });
              }),
        ],
      ),
    );
  }
}
