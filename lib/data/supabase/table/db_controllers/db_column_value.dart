import 'package:zakio/data/supabase/table/i_table.dart';

class DBColumnValue {
  final List<TableColumn> _tableColumns;
  final Object value;

  DBColumnValue({required List<TableColumn> tableColumns, required this.value}) : _tableColumns = tableColumns;

  String get columnNames => _tableColumns.map((e) => e.columnName).toList().join(".");
}
