//
//
// the suborted language you must to add it here
// and don't forget to add a new json file on translations

// and add new lang to ios/Runner/Info.plist
// <key>CFabaqleLocalizations</key>
// <array>
// 	<string>en</string>
// 	<string>ar</string>
// </array>

enum LanguageType { ENGLISH, ARABIC }

const String ENGLISH = "en";
const String ARABIC = "ar";

extension LanguageTypeExtension on LanguageType {
  String getValue() {
    switch (this) {
      case LanguageType.ENGLISH:
        return ENGLISH;
      case LanguageType.ARABIC:
        return ARABIC;
    }
  }
}
