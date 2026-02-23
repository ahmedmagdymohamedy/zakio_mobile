import 'package:zakio/data/models/child/child.dart';
import 'package:zakio/data/supabase/table/i_table.dart';
import 'package:zakio/data/supabase/table/table_column.dart';

class ChildrenTable extends ITable<Child> {
  @override
  String get tableName => "children";

  @override
  List<TableColumn> get columns => [
    TableColumn(name: "id"),
    TableColumn(name: "created_at"),
    TableColumn(name: "name"),
  ];

  @override
  Child toModel(Map<String, dynamic> map) => Child.fromJson(map);
}
