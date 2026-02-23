import 'package:zakio/data/supabase/supabase_manager.dart';
import 'package:zakio/data/supabase/table/table_column.dart';

abstract class ITable<T> {
  String get tableName;
  List<TableColumn> get columns;

  String formateColumnToSelections(List<TableColumn>? columns) {
    return columns?.map((e) => e.name).toList().join(",") ?? "*";
  }

  T toModel(Map<String, dynamic> map);

  Future<List<T>> select({
    List<TableColumn>? column,
  }) async {
    final result = await SupabaseManager.supabase.from(tableName).select(formateColumnToSelections(column));
    return result.map((e) => toModel(e)).toList();
  }
}
