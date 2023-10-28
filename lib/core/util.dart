import 'dart:io';

String get userHome =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';