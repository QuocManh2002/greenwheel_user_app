// To parse this JSON data, do
//
//     final planDetail = planDetailFromJson(jsonString);

import 'dart:convert';

import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';

PlanDetail planDetailFromJson(String str) =>
    PlanDetail.fromJson(json.decode(str));

String planDetailToJson(PlanDetail data) => json.encode(data.toJson());

class PlanDetail {
  int id;
  String? name;
  DateTime? departureDate;
  DateTime? startDate;
  DateTime? endDate;
  String? joinMethod;
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
  List<PlanMemberViewModel>? members;
  int? gcoinBudgetPerCapita;

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
      this.joinMethod,
      this.savedContacts,
      this.members,
      this.gcoinBudgetPerCapita,
      required this.startLocationLat,
      required this.startLocationLng,
      required this.numOfExpPeriod,
      required this.departureDate,
      this.orders});

  factory PlanDetail.fromJson(Map<String, dynamic> json) => PlanDetail(
        id: json["id"],
        name: json["name"],
        departureDate: DateTime.parse(json['departDate']),
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        schedule: json["proposedSchedule"],
        memberLimit: json["memberLimit"],
        status: json["status"],
        locationName: json["destination"]["name"],
        locationId: json["destination"]["id"],
        imageUrls: json["destination"]["imageUrls"],
        joinMethod: json["joinMethod"],
        numOfExpPeriod: json['periodCount'],
        gcoinBudgetPerCapita: json['gcoinBudgetPerCapita'],
        startLocationLat: json["departure"]["coordinates"][1].toDouble(),
        startLocationLng: json["departure"]["coordinates"][0].toDouble(),
        members: List<PlanMemberViewModel>.from(json['members'].map((e) => PlanMemberViewModel.fromJson(e))).toList(),
        savedContacts: List<EmergencyContactViewModel>.from(json['savedContacts'].map((e) => EmergencyContactViewModel.fromJsonByLocation(e))).toList(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startDate": startDate!.toIso8601String(),
        "endDate": endDate!.toIso8601String(),
        "schedule": schedule,
        "memberLimit": memberLimit,
        "status": status,
        "locationName": locationName,
        "locationId": locationId,
        "imageUrls": imageUrls,
      };
}
