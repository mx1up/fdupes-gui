import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:fdupes_gui/presentation/dupe_screen.dart';
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
  String? initialDir;
  if (args.length > 0) {
    initialDir = args[0];
  }
  print('initialDir=$initialDir');
  Bloc.observer = MyBlocObserver();

  runApp(MyApp(initialDir));
}

class MyApp extends StatelessWidget {
  final String? initialDir;

  MyApp(this.initialDir);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FdupesBloc>(
      create: (context) => FdupesBloc(initialDir: initialDir),
      child: AdaptiveTheme(
        // debugShowFloatingThemeButton: true,
        light: ThemeData.light(useMaterial3: true),
        dark: ThemeData.dark(useMaterial3: true),
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
