class DbRangeValues {
  final int _from;
  final int _to;
  const DbRangeValues({required int from, required int to}) : _from = from, _to = to;

  int get from => _from;
  int get to => _to;
}
