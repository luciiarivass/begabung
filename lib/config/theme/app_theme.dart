import "package:flutter/material.dart";

class AppTheme {
  ThemeData getTheme() => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFFE8F2FD),
      scaffoldBackgroundColor: Colors.white, //Color(0xFFE8F2FD),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white)); //Color(0xFFE8F2FD)));
}
