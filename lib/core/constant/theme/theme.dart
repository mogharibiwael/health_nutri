import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData themeData = ThemeData(
  fontFamily: "Cairo",
  textTheme: TextTheme(
    displayLarge: const TextStyle(fontFamily: "Cairo"),
    displayMedium: const TextStyle(fontFamily: "Cairo"),
    displaySmall: const TextStyle(fontFamily: "Cairo"),
    headlineLarge: const TextStyle(fontFamily: "Cairo"),
    headlineMedium: const TextStyle(fontFamily: "Cairo"),
    headlineSmall: const TextStyle(fontFamily: "Cairo"),
    titleLarge: const TextStyle(fontFamily: "Cairo"),
    titleMedium: TextStyle(fontFamily: "Cairo", fontSize: 22, fontWeight: FontWeight.bold, color: AppColor.white),
    titleSmall: const TextStyle(fontFamily: "Cairo"),
    bodyLarge: const TextStyle(fontFamily: "Cairo"),
    bodyMedium: const TextStyle(fontFamily: "Cairo"),
    bodySmall: TextStyle(fontFamily: "Cairo", fontSize: 20, color: AppColor.textColor),
    labelLarge: const TextStyle(fontFamily: "Cairo"),
    labelMedium: const TextStyle(fontFamily: "Cairo"),
    labelSmall: const TextStyle(fontFamily: "Cairo"),
  ),
);
