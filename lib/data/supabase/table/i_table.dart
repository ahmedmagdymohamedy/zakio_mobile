import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zakio/data/supabase/db_logger_manager.dart';
import 'package:zakio/data/supabase/supabase_manager.dart';
import 'package:zakio/data/supabase/table/db_controllers/db_column_value.dart';
import 'package:zakio/data/supabase/table/db_controllers/db_range_values.dart';

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

  Future<dynamic> onQuery(dynamic queryCall, {String operation = ""}) async {
    final result = await queryCall;
    DBLoggerManager.logResponse(operation, tableName, result);
    return result;
  }

  Future<List<T>> select({
    List<C>? column,
    DBColumnValue? isEqual,
    DBColumnValue? isNotEqual,
    DBColumnValue? greaterThan,
    DBColumnValue? greaterThanOrEqual,
    DBColumnValue? lessThan,
    DBColumnValue? lessThanOrEqual,
    int? limit = 20,
    C? orderBy,
    DbRangeValues? range,
    bool isSinlge = false,
  }) async {
    // check if developer selected single item but not provided isEqual condition
    assert (!isSinlge || isEqual != null);

    dynamic query = SupabaseManager.supabase
        .from(tableName) //
        .select(formateColumnToSelections(column));

    // check if there is Equal condition
    if (isEqual != null) {
      query = query.eq(isEqual.columnNames, isEqual.value);
    }

    // check if there is not Equal condition
    if (isNotEqual != null) {
      query = query.neq(isNotEqual.columnNames, isNotEqual.value);
    }

    // check if there is greater than condition
    if (greaterThan != null) {
      query = query.gt(greaterThan.columnNames, greaterThan.value);
    }

    // check if there is greater than or equal condition
    if (greaterThanOrEqual != null) {
      query = query.gte(greaterThanOrEqual.columnNames, greaterThanOrEqual.value);
    }

    // check if there is less than condition
    if (lessThan != null) {
      query = query.lt(lessThan.columnNames, lessThan.value);
    }

    // check if there is less than or equal condition
    if (lessThanOrEqual != null) {
      query = query.lte(lessThanOrEqual.columnNames, lessThanOrEqual.value);
    }

    // check if there is limit
    if (limit != null) {
      query = query.limit(limit);
    }

    // check if there is order by
    if (orderBy != null) {
      query = query.order(orderBy.columnName);
    }

    // check if there is range
    if (range != null) {
      query = query.range(range.from, range.to);
    }

    // check if there is single
    if (isSinlge) {
      query = query.single();
    }

    dynamic queryResult = await onQuery(query, operation: 'SELECT');

    // casting the values if list or map depend on isSinlge or not.
    List<Map<String, dynamic>> result = [];

    if (isSinlge) {
      result = [queryResult];
    } else {
      result = List<Map<String, dynamic>>.from(queryResult);
    }

    return result.map((e) => toModel(e)).toList();
  }
}
