import 'dart:convert';

import 'package:greenwheel_user_app/constants/contact_type.dart';

class EmergencyContactViewModel {
  String? name;
  String? type;
  String? phone;
  String? address;

  EmergencyContactViewModel({this.address, this.name, this.phone, this.type});

  factory EmergencyContactViewModel.fromJsonByLocation(Map<String, dynamic> json) =>
      EmergencyContactViewModel(
          address: json['address'],
          name: json['name'],
          phone: json['phone'],
          type: json['type']);
      factory EmergencyContactViewModel.fromJsonByPlan(Map<String, dynamic> json) =>
      EmergencyContactViewModel(
          address: json['address'],
          name: json['name'],
          phone: json['phone'],
          type: contact_types[int.parse(json['type'].toString())]); 
  Map<String, dynamic> toJson(EmergencyContactViewModel model) => {
        "address": json.encode(model.address),
        "name": json.encode(model.name),
        "phone": json.encode(model.phone),
        "type": model.type!
      };
}
