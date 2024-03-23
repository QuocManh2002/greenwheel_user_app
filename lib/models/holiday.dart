class Holiday{
  int? id;
  DateTime from;
  DateTime to;
  String name;

  Holiday({
    required this.from,
    required this.name,
    required this.to,
    this.id
  });
}