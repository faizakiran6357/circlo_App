import 'package:flutter/material.dart';
const Color kGreen = Color(0xFF4CAF50);
const Color kTeal = Color(0xFF00BCD4);
const Color kAmber = Color(0xFFFFC107);
const Color kBg = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF212121);

ThemeData circloTheme = ThemeData(
  fontFamily: 'Nunito',
  scaffoldBackgroundColor: kBg,
  primaryColor: kGreen,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 23, 45, 24)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark),
    bodyMedium: TextStyle(fontSize: 14, color: kTextDark),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGreen, width: 1.8)),
  ),
);
