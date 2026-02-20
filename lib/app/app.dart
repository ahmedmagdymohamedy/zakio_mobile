import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zakio/app/app_theme.dart';
import 'package:zakio/core/flavors/flavors_config.dart';
import 'package:zakio/presentation/general_cubit/app_data_cubit/app_data_cubit.dart';
import 'package:zakio/presentation/pages/splash/view/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// here the start of your material app.

/// i useing native navigator with no plugens
/// and you can use static navigators functions inside AppRouter
/// class to navigat with only one PageRoute way and change it any
/// time you need

/// Any generic cubit or bloc add it here please.

// to get current context from any where
final GlobalKey<NavigatorState> appKey = GlobalKey<NavigatorState>();
BuildContext get appContext => appKey.currentContext!;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppDataCubit>(
          create: (BuildContext context) => AppDataCubit(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: "Zakio",
        debugShowCheckedModeBanner: FlavorsConfig.instance.isTest,
        theme: getAppTheme(context),
        home: const SplashScreen(),
        navigatorKey: appKey,
      ),
    );
  }
}
