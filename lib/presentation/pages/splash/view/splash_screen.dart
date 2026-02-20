import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zakio/core/resources/app_colors.dart';
import 'package:zakio/presentation/pages/splash/cubit/splash_cubit.dart';
import 'package:zakio/presentation/pages/splash/cubit/state/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(),
      child: BlocBuilder<SplashCubit, SplashState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Stack(children: [
              ],
            ),
          );
        },
      ),
    );
  }
}
