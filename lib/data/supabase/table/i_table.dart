import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zakio/data/supabase/db_logger_manager.dart';
import 'package:zakio/data/supabase/supabase_manager.dart';

abstract class TableColumn {
  final String columnName;
  const TableColumn({required this.columnName});
}

abstract class ITable<T, C extends TableColumn> {
  String get tableName;
  List<C> get columns;

  String formateColumnToSelections(List<C>? columns) {
    return columns?.map((e) => e.columnName).toList().join(",") ?? "*";
  }

  T toModel(Map<String, dynamic> map);

  Future<List<Map<String, dynamic>>> onQuery(PostgrestFilterBuilder Function() queryCall, {String operation = ""}) async {
    final result = await queryCall();
    DBLoggerManager.logResponse(operation, tableName, result);
    return result;
  }

  Future<List<T>> select({
    List<C>? column,
  }) async {
    final result = await onQuery(
      () => SupabaseManager.supabase
          .from(tableName) //
          .select(formateColumnToSelections(column)),
      operation: 'SELECT',
    );
    return result.map((e) => toModel(e)).toList();
  }
}
