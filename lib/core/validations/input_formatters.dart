import 'package:zakio/core/validations/app_reg_exp.dart';
import 'package:flutter/services.dart';

/// that class have all TextInputFormatter you want to use on app.

abstract class AppInputFormatters {
  static List<TextInputFormatter> numbers = [
    FilteringTextInputFormatter.allow(AppRegExp.numbers),
  ];

  static List<TextInputFormatter> userOneName = [
    FilteringTextInputFormatter.allow(AppRegExp.englishCharacters),
  ];

  static List<TextInputFormatter> userName = [
    FilteringTextInputFormatter.allow(AppRegExp.englishCharactersAndSpaces),
  ];
}
