import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zakio/data/repositories/app_config/app_config.dart';

part 'app_data_state.freezed.dart';

@freezed
abstract class AppDataState with _$AppDataState {
  const factory AppDataState({
    AppConfig? appConfig,
  }) = _AppDataState;
}
