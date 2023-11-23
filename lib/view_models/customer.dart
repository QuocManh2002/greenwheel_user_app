import 'dart:convert';

class CustomerViewModel {
  int id;
  String name;
  String email;
  bool isMale;
  String avatarUrl;
  DateTime birthday;
  String phone;
  int balance;

  CustomerViewModel customerFromJson(String str) =>
      CustomerViewModel.fromJson(json.decode(str));

  String customerToJson(CustomerViewModel data) => json.encode(data.toJson());

  CustomerViewModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isMale,
    required this.avatarUrl,
    required this.birthday,
    required this.phone,
    required this.balance,
  });

  factory CustomerViewModel.fromJson(Map<String, dynamic> json) =>
      CustomerViewModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        isMale: json["isMale"],
        avatarUrl: json["avatarUrl"],
        birthday: DateTime.parse(json["birthday"]),
        phone: json["phone"],
        balance: json["balance"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "isMale": isMale,
        "avatarUrl": avatarUrl,
        "birthday": birthday,
        "phone": phone,
        "balance": balance,
      };
}
