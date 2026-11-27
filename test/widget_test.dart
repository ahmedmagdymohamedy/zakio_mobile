import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zakio/presentation/widgets/app_button.dart';

Future<void> _pumpButton(WidgetTester tester, AppButton button) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      child: Builder(
        builder: (context) => MaterialApp(
          locale: context.locale,
          home: Scaffold(body: button),
        ),
      ),
    ),
  );
  // let easy_localization load the translations.
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('AppButton shows its text and calls onTap', (tester) async {
    int taps = 0;
    await _pumpButton(tester, AppButton(text: 'Get Started', onTap: () => taps++));

    await tester.tap(find.text('Get Started'));
    expect(taps, 1);
  });

  testWidgets('AppButton ignores taps while loading', (tester) async {
    int taps = 0;
    await _pumpButton(tester, AppButton(text: 'Get Started', isLoading: true, onTap: () => taps++));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
    await tester.tap(find.byType(AppButton));
    expect(taps, 0);
  });
}
