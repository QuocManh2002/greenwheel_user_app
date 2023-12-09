import 'dart:convert';

class CustomerViewModel {
  int id;
  String name;
  bool isMale;
  String? avatarUrl;
  String phone;
  double balance;

  CustomerViewModel customerFromJson(String str) =>
      CustomerViewModel.fromJson(json.decode(str));

  String customerToJson(CustomerViewModel data) => json.encode(data.toJson());

  CustomerViewModel({
    required this.id,
    required this.name,
    required this.isMale,
    required this.avatarUrl,
    required this.phone,
    required this.balance,
  });

  factory CustomerViewModel.fromJson(Map<String, dynamic> json) =>
      CustomerViewModel(
        id: json["id"],
        name: json["account"]["name"],
        isMale: json["isMale"],
        avatarUrl: json['account']["avatarUrl"],
        phone: json["phone"],
        balance: double.parse(json["balance"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "isMale": isMale,
        "avatarUrl": avatarUrl,
        "phone": phone,
        "balance": balance,
      };
}
