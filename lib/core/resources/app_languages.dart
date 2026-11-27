//
//
// the suborted language you must to add it here
// and don't forget to add a new json file on translations

// and add new lang to ios/Runner/Info.plist
// <key>CFBundleLocalizations</key>
// <array>
// 	<string>en</string>
// 	<string>ar</string>
// </array>

enum LanguageType {
  english("en"),
  arabic("ar");

  const LanguageType(this.code);

  final String code;
}
