import 'package:flutter/material.dart';

class FdupesTheme {
  static ThemeData light() {
    return ThemeData.light(useMaterial3: true).copyWith(
      tooltipTheme: TooltipThemeData(
        waitDuration: Duration(milliseconds: 500),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      tooltipTheme: TooltipThemeData(
        waitDuration: Duration(milliseconds: 500),
      ),
    );
  }
}
