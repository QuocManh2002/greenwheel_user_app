import 'dart:convert';

import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';

LocationViewModel provinceFromJson(String str) =>
    LocationViewModel.fromJson(json.decode(str));

String provinceToJson(LocationViewModel data) => json.encode(data.toJson());

class LocationViewModel {
  int id;
  String description;
  List<dynamic> imageUrls;
  String name;
  List<String> activities;
  List<String> seasons;
  String topographic;
  List<dynamic> templatePlan;
  double latitude;
  double longitude;
  String address;
  String? lifeguardPhone;
  String? lifeguardAddress;
  String? clinicPhone;
  String? clinicAddress;
  String hotline;
  int provinceId;
  int suggestedTripLength;
  List<EmergencyContactViewModel>? emergencyContacts;
  List<dynamic>? templateEvents;

  LocationViewModel(
      {required this.id,
      required this.description,
      required this.imageUrls,
      required this.name,
      required this.activities,
      required this.seasons,
      required this.topographic,
      required this.templatePlan,
      required this.latitude,
      required this.longitude,
      required this.address,
      this.lifeguardPhone,
      this.lifeguardAddress,
      this.clinicPhone,
      this.clinicAddress,
      required this.hotline,
      required this.provinceId,
      required this.suggestedTripLength,
      this.emergencyContacts,
      this.templateEvents});

  factory LocationViewModel.fromJson(Map<String, dynamic> json) =>
      LocationViewModel(
          id: json["id"],
          description: json["description"],
          imageUrls: json["imageUrls"],
          name: json["name"],
          activities: List<String>.from(json["activities"].map((x) => x)),
          seasons: List<String>.from(json["seasons"].map((x) => x)),
          topographic: json["topographic"],
          templatePlan: json["templateSchedule"],
          latitude: json["coordinate"]["coordinates"][1].toDouble(),
          longitude: json["coordinate"]["coordinates"][0].toDouble(),
          address: json["address"],
          lifeguardPhone: json["lifeguardPhone"],
          lifeguardAddress: json["lifeguardAddress"],
          clinicPhone: json["clinicPhone"],
          clinicAddress: json["clinicAddress"],
          hotline: json["hotline"],
          suggestedTripLength:
              List<dynamic>.from(json['templateSchedule'].map((x) => x)).length,
          provinceId: json["provinceId"],
          emergencyContacts: List<EmergencyContactViewModel>.from(json['emergencyContacts'].map((e) => EmergencyContactViewModel.fromJson(e))).toList(),
          templateEvents: json['templateEvents']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "imageUrls": imageUrls,
        "name": name,
        "activities": List<dynamic>.from(activities.map((x) => x)),
        "seasons": List<dynamic>.from(seasons.map((x) => x)),
        "topographic": topographic,
        "templateSchedule": templatePlan,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "lifeguardPhone": lifeguardPhone,
        "lifeguardAddress": lifeguardAddress,
        "clinicPhone": clinicPhone,
        "clinicAddress": clinicAddress,
        "hotline": hotline,
        "provinceId": provinceId,
      };
}
