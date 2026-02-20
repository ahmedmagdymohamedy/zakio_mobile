// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';

/// thit Extension make formating more easy
/// using Init inside easy localization.

extension DateTimeExt on DateTime {
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }
}
