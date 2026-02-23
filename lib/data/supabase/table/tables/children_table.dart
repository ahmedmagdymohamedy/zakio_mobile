import 'package:zakio/data/models/child/child.dart';
import 'package:zakio/data/supabase/table/i_table.dart';

class ChildrenTableColumn extends TableColumn {
  // columns
  static const id = ChildrenTableColumn(columnName: "id");
  static const createdAt = ChildrenTableColumn(columnName: "created_at");
  static const name = ChildrenTableColumn(columnName: "name");

  const ChildrenTableColumn({required super.columnName});
}

class ChildrenTable extends ITable<Child, ChildrenTableColumn> {
  @override
  String get tableName => "children";

  @override
  List<ChildrenTableColumn> get columns => [
    ChildrenTableColumn.id,
    ChildrenTableColumn.createdAt,
    ChildrenTableColumn.name,
  ];

  @override
  Child toModel(Map<String, dynamic> map) => Child.fromJson(map);
}
