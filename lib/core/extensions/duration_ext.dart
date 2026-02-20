extension DurationExt on Duration {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  String print() {
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String get days => inDays.toString();
  String get hours => twoDigits(inHours % 24);
  String get minutes => twoDigits(inMinutes % 60);
  String get seconds => twoDigits(inSeconds % 60);
}
