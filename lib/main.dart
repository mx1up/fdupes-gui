import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:fdupes_gui/presentation/dupe_screen.dart';
import 'package:fdupes_gui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase cubit, Change change) {
    print('${cubit.runtimeType}.onChange: $change');
    super.onChange(cubit, change);
  }

  @override
  void onError(BlocBase cubit, Object error, StackTrace stackTrace) {
    print("${cubit.runtimeType}.onError: $error");
    super.onError(cubit, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print("${bloc.runtimeType}.onTransition: $transition");
    super.onTransition(bloc, transition);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    print("${bloc.runtimeType}.onEvent: $event");
    super.onEvent(bloc, event);
  }
}

void main(List<String> args) {
  List<String>? initialDirsArg;
  if (args.length > 0) {
    initialDirsArg = args;
  }
  print('initialDirs=$initialDirsArg');
  final initialDirs =
      initialDirsArg?.map((e) => Directory(e)).where((element) => element.existsSync()).map((e) => e.absolute).toList();
  print('valid initialDirs=$initialDirs');
  Bloc.observer = MyBlocObserver();

  runApp(MyApp(initialDirs));
}

class MyApp extends StatelessWidget {
  final List<Directory>? initialDirs;

  MyApp(this.initialDirs);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FdupesBloc>(
      create: (context) => FdupesBloc(initialDirs: initialDirs),
      child: AdaptiveTheme(
        // debugShowFloatingThemeButton: true,
        light: FdupesTheme.light(),
        dark: FdupesTheme.dark(),
        initial: AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
          title: 'Fdupes gui',
          theme: theme,
          darkTheme: darkTheme,
          home: Material(child: DupeScreen()),
        ),
      ),
    );
  }
}
