import 'dart:convert';

import 'package:greenwheel_user_app/constants/contact_type.dart';

class EmergencyContactViewModel {
  String? name;
  String? type;
  String? phone;
  String? address;

  EmergencyContactViewModel({this.address, this.name, this.phone, this.type});

  factory EmergencyContactViewModel.fromJson(Map<String, dynamic> json) =>
      EmergencyContactViewModel(
          address: json['Address'],
          name: json['Name'],
          phone: json['Phone'],
          type: json['Type']);
  Map<String, dynamic> toJson(EmergencyContactViewModel model) => {
        "address": json.encode(model.address),
        "name": json.encode(model.name),
        "phone": json.encode(model.phone),
        "type": contact_types[int.parse(model.type!)]
      };
}
