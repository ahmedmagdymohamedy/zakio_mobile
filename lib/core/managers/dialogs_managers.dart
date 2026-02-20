import 'package:zakio/app/app.dart';
import 'package:zakio/core/resources/app_colors.dart';
import 'package:zakio/core/resources/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DialogsManager {
  static Future<T> showAppDialog<T>({
    required Widget child,
    Color? backGroundColor,
    bool barrierDismissible = true,
  }) async {
    return await showDialog(
      context: appContext,
      barrierDismissible: barrierDismissible,
      barrierColor: backGroundColor,
      builder: (_) => Dialog(insetPadding: const EdgeInsets.symmetric(horizontal: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), child: child),
    );
  }

  static Future<T?> showAppGeneralDialog<T>({
    required Widget child,
    Color? barrierColor,
    int animationDurationInMilliseconds = 250,
    double finalScale = 1,
    bool barrierDismissible = true,
    String barrierLabel = 'Dismiss dialog',
    MaterialType type = MaterialType.transparency,
    Color? dialogColor,
  }) async {
    return await showGeneralDialog<T>(
      context: appContext,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      transitionDuration: Duration(milliseconds: animationDurationInMilliseconds),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Material(
              type: type,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              color: dialogColor,
              child: child,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, dialogChild) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.3, end: finalScale).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.3, end: 1).animate(curvedAnimation),
            child: dialogChild,
          ),
        );
      },
    );
  }


  static Future<void> showToastMessage(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    ToastGravity? gravity,
    Toast? toastLength = Toast.LENGTH_LONG,
  }) async {
    await Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: toastLength == Toast.LENGTH_LONG ? 3 : 1,
      backgroundColor: backgroundColor ?? AppColors.gray,
      textColor: textColor ?? Colors.white,
      fontSize: 16,
    );
  }

  static Future<T?> showAppModelSheet<T>({
    required Widget child,
    String? title,
    bool barrierDismissible = true,
  }) async {
    return await showModalBottomSheet<T>(
      context: appContext,
      isScrollControlled: true,
      isDismissible: barrierDismissible,
      backgroundColor: Colors.white,
      enableDrag: barrierDismissible,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      builder: (con) => GestureDetector(
        onTap: () {
          FocusScope.of(con).unfocus();
        },
        child: SafeArea(
          child: Wrap(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      height: 4,
                      width: 80,
                      decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 16),
                    if (title != null) ...[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: AppFonts.titlesFont(appContext),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    child,
                    SizedBox(height: MediaQuery.of(appContext).viewInsets.bottom),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
