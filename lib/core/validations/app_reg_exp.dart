/// this class have all RegExp you may need to use it in
/// AppValidations or TextInputFormatter.
library;

class AppRegExp {
  static RegExp name = RegExp(r'[a-zA-Z]\s[a-zA-Z]');
  static RegExp numbers = RegExp(r'[0-9]');
  static RegExp space = RegExp(r'\s');
  static RegExp englishCharacters = RegExp(r'[a-zA-Z]');
  static RegExp englishCharactersAndSpaces = RegExp(r'[a-zA-Z\s]');
  static RegExp englishCharactersAndSpacesAndNumbers = RegExp(r'[a-zA-Z0-9\s]');
  static RegExp englishCharactersAndSpacesAndNumbersAndSpicial = RegExp(r'[a-zA-Z0-9\s__\-=@,\.;]');
  static RegExp capitalLetter = RegExp(r'[A-Z]+');
  static RegExp smallLetter = RegExp(r'[a-z]+');
  static RegExp oneNumberOrMore = RegExp(r'[0-9]+');
  static RegExp email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static RegExp specialCharacters = RegExp(r'[^\w\s\u0600-\u06FF@$!]');
  static RegExp onlyAllowedSpecialCharacters = RegExp(r'[@$!]');
}
