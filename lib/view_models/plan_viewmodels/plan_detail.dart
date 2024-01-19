// To parse this JSON data, do
//
//     final planDetail = planDetailFromJson(jsonString);

import 'dart:convert';

import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/order.dart';

PlanDetail planDetailFromJson(String str) =>
    PlanDetail.fromJson(json.decode(str));

String planDetailToJson(PlanDetail data) => json.encode(data.toJson());

class PlanDetail {
  int id;
  String name;
  DateTime departureDate;
  DateTime startDate;
  DateTime endDate;
  String joinMethod;
  List<dynamic> schedule;
  int memberLimit;
  String status;
  String locationName;
  int locationId;
  double startLocationLat;
  double startLocationLng;
  List<dynamic> imageUrls;
  List<OrderViewModel>? orders;
  List<EmergencyContactViewModel>? savedContacts;
  int numOfExpPeriod;

  PlanDetail(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.schedule,
      required this.memberLimit,
      required this.status,
      required this.locationName,
      required this.locationId,
      required this.imageUrls,
      required this.name,
      required this.joinMethod,
      this.savedContacts,
      required this.startLocationLat,
      required this.startLocationLng,
      required this.numOfExpPeriod,
      required this.departureDate,
      this.orders});

  factory PlanDetail.fromJson(Map<String, dynamic> json) => PlanDetail(
        id: json["id"],
        name: json["name"],
        departureDate: DateTime.parse(json['departureDate']),
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        schedule: json["schedule"],
        memberLimit: json["memberLimit"],
        status: json["status"],
        locationName: json["location"]["name"],
        locationId: json["location"]["id"],
        imageUrls: json["location"]["imageUrls"],
        joinMethod: json["joinMethod"],
        numOfExpPeriod: json['numOfExpPeriod'],
        startLocationLat: json["departurePosition"]["coordinates"][1].toDouble(),
        startLocationLng: json["departurePosition"]["coordinates"][0].toDouble(),
        savedContacts: List<EmergencyContactViewModel>.from(json['savedContacts'].map((e) => EmergencyContactViewModel.fromJsonByLocation(e))).toList(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "schedule": schedule,
        "memberLimit": memberLimit,
        "status": status,
        "locationName": locationName,
        "locationId": locationId,
        "imageUrls": imageUrls,
      };
}
