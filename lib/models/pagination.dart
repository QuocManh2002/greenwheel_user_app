class Pagination<T>{
  int pageSize;
  String? cursor;
  List<T>? objects;

  Pagination({
    required this.pageSize,
    required this.cursor,
    required this.objects
  });
}