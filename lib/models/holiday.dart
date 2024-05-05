
class Holiday {
  int? id;
  DateTime from;
  DateTime to;
  String name;

  Holiday({required this.from, required this.name, required this.to, this.id});

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
      name: json['name'],
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']));
  Map<String, dynamic> toJson() =>
      {"name": name, 
      "from": from.toString().split(' ')[0], 
      "to": to.toString().split(' ')[0]};
}
