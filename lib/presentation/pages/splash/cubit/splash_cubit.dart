import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zakio/presentation/pages/splash/cubit/state/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState()) {
    init();
  }

  static SplashCubit get(BuildContext context) => BlocProvider.of<SplashCubit>(context);

  void init() async {}
}
