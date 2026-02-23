import 'package:zakio/data/models/child/child.dart';
import 'package:zakio/data/supabase/table/i_table.dart';
import 'package:zakio/data/supabase/table/tables/children_table.dart';

class DBManager {
  ITable<Child> childrenTable = ChildrenTable();
}
