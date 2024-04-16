import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class CustomerViewModel {
  int id;
  String name;
  bool isMale;
  String? avatarUrl;
  String phone;
  double balance;
  String? defaultAddress;
  PointLatLng? defaultCoordinate;

  CustomerViewModel customerFromJson(String str) =>
      CustomerViewModel.fromJson(json.decode(str));

  String customerToJson(CustomerViewModel data) => json.encode(data.toJson());

  CustomerViewModel(
      {required this.id,
      required this.name,
      required this.isMale,
      required this.avatarUrl,
      required this.phone,
      required this.balance,
      required this.defaultAddress,
      required this.defaultCoordinate});

  factory CustomerViewModel.fromJson(Map<String, dynamic> json) =>
      CustomerViewModel(
        id: json["id"],
        name: json["name"],
        isMale: json["isMale"],
        avatarUrl: json["avatarPath"],
        phone: json["phone"],
        defaultAddress: json['address'],
        defaultCoordinate: json['coordinate'] == null
            ? null
            : PointLatLng(json['coordinate']['coordinates'][1],
                json['coordinate']['coordinates'][0]),
        balance: double.parse(json["gcoinBalance"].toString()),
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
