import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      );

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      );
}
