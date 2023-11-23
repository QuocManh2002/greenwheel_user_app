// To parse this JSON data, do
//
//     final userViewModel = userViewModelFromJson(jsonString);

import 'dart:convert';

UserViewModel userViewModelFromJson(String str) => UserViewModel.fromJson(json.decode(str));

String userViewModelToJson(UserViewModel data) => json.encode(data.toJson());

class UserViewModel {
    int id;
    String name;
    String email;
    String phone;
    bool isMale;
    String avatarUrl;
    DateTime birthday;
    int balance;
    bool isBlocked;

    UserViewModel({
        required this.id,
        required this.name,
        required this.email,
        required this.phone,
        required this.isMale,
        required this.avatarUrl,
        required this.birthday,
        required this.balance,
        required this.isBlocked,
    });

    factory UserViewModel.fromJson(Map<String, dynamic> json) => UserViewModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        isMale: json["isMale"],
        avatarUrl: json["avatarUrl"],
        birthday: DateTime.parse(json["birthday"]),
        balance: json["balance"],
        isBlocked: json["isBlocked"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "isMale": isMale,
        "avatarUrl": avatarUrl,
        "birthday": "${birthday.year.toString().padLeft(4, '0')}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}",
        "balance": balance,
        "isBlocked": isBlocked,
    };
}
