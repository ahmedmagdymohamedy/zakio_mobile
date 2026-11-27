import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zakio/core/resources/string_keys.dart';
import 'package:zakio/presentation/pages/splash/cubit/splash_cubit.dart';
import 'package:zakio/presentation/pages/splash/cubit/state/splash_state.dart';
import 'package:zakio/presentation/widgets/app_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocProvider(
      create: (context) => SplashCubit(),
      child: BlocBuilder<SplashCubit, SplashState>(
        builder: (context, state) {
          SplashCubit cubit = SplashCubit.get(context);
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppButton(
                      text: StringKeys.getStarted.tr(),
                      onTap: cubit.onClick,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
