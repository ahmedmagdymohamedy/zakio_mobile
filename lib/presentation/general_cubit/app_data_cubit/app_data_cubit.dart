import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zakio/data/repositories/app_config/app_config.dart';
import 'package:zakio/presentation/general_cubit/app_data_cubit/state/app_data_state.dart';

// save some app data you may need from any where in your app

class AppDataCubit extends Cubit<AppDataState> {
  AppDataCubit() : super(const AppDataState());

  static AppDataCubit get(BuildContext context) => BlocProvider.of<AppDataCubit>(context);

  void setAppConfig(AppConfig appConfig) {
    emit(state.copyWith(appConfig: appConfig));
  }
}
