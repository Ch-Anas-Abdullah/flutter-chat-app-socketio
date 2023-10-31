import 'package:flutter/material.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MyColor.primaryColor,
        foregroundColor: Colors.white,
        shape: CircleBorder()),
    fontFamily: GoogleFonts.poppins().fontFamily,
    popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
    )),
    appBarTheme: const AppBarTheme(
        backgroundColor: MyColor.primaryColor,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: MyColor.primaryColor,
            systemNavigationBarColor: MyColor.primaryColor,
            statusBarIconBrightness: Brightness.light)),
    colorScheme: ColorScheme.fromSeed(
      surfaceTint: Colors.white,
      seedColor: MyColor.primaryColor,
    ));
