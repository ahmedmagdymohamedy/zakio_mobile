import 'package:zakio/core/resources/app_colors.dart';
import 'package:zakio/core/resources/app_fonts.dart';
import 'package:flutter/material.dart';

/// the general theme of the application;

ThemeData getAppTheme(BuildContext context) {
  return ThemeData(
    primaryColor: AppColors.primary,
    disabledColor: AppColors.lightGray,
    scaffoldBackgroundColor: Colors.white,
    splashColor: AppColors.primary.withOpacity(0.1),
    highlightColor: AppColors.primary.withOpacity(0.1),
    // app bar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.primary,
      titleTextStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 18,
        fontFamily: AppFonts.headersFont(context),
        fontWeight: FontWeight.w600,
      ),
    ),

    // elevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(0),
        backgroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
        ),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        textStyle: WidgetStateProperty.all<TextStyle>(
          TextStyle(
            fontSize: 16,
            fontFamily: AppFonts.titlesFont(context),
          ),
        ),
      ),
    ),

    // cursor color
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
    ),

    // Text Theme
    textTheme: Theme.of(context).textTheme.apply(
          bodyColor: AppColors.primary,
          fontFamily: AppFonts.bodyFont(context),
        ),

    // input theme
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      hintStyle: const TextStyle(
        color: AppColors.lightGray,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.gray, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.lightGray, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      suffixIconColor: AppColors.primary,
      prefixIconColor: AppColors.primary,
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
      ),
    ),
  );
}
