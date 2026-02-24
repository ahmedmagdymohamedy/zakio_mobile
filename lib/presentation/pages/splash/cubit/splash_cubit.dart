import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zakio/data/supabase/db_manager.dart';
import 'package:zakio/data/supabase/table/db_controllers/db_column_value.dart';
import 'package:zakio/data/supabase/table/db_controllers/db_range_values.dart';
import 'package:zakio/data/supabase/table/tables/children_table.dart';
import 'package:zakio/presentation/pages/splash/cubit/state/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState()) {
    init();
  }

  static SplashCubit get(BuildContext context) => BlocProvider.of<SplashCubit>(context);

  void init() async {
    // RealtimeDatabaseManager.listenAppConfig((appConfig) {
    //   AppDataCubit.get(appContext).setAppConfig(appConfig);
    // });
  }

  void onClick() async {
    final children = await DBManager.childrenTable.select(
      column: [
        ChildrenTableColumn.id,
        ChildrenTableColumn.name,
        // ChildrenTableColumn.createdAt,
      ],
      isEqual: DBColumnValue(
        tableColumns: [ChildrenTableColumn.name],
        value: "Alaa",
      ),
      // orderBy: ChildrenTableColumn.name,
      // limit: 1,
      // range: DbRangeValues(from: 0, to: 10),
      isSinlge: true,
    );
    print(children);
  }
}
