import 'dart:io';

import 'package:fdupes_gui/domain/fdupes_bloc.dart';
import 'package:fdupes_gui/presentation/dupe_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_run/which.dart';
import 'package:fdupes_gui/core/util.dart' as util;

class MyBlocObserver extends BlocObserver {
  @override
  void onChange(Cubit cubit, Change change) {
    print('${cubit.runtimeType}.onChange: $change');
    super.onChange(cubit, change);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print("${cubit.runtimeType}.onError: $error");
    super.onError(cubit, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print("${bloc.runtimeType}.onTransition: $transition");
    super.onTransition(bloc, transition);
  }

  @override
  void onEvent(Bloc bloc, Object event) {
    print("${bloc.runtimeType}.onEvent: $event");
    super.onEvent(bloc, event);
  }
}

void main(List<String> args) {
  var initialDir = util.userHome;
  if (args.length > 0) {
    initialDir = args[0];
  }
  print('initialDir=$initialDir');
  Bloc.observer = MyBlocObserver();



  runApp(MyApp(initialDir));
}

class MyApp extends StatelessWidget {
  final String initialDir;

  MyApp(this.initialDir);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<FdupesBloc>(
      create: (context) => FdupesBloc(initialDir),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Material(child: DupeScreen()),
      ),
    );
  }
}