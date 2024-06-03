import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:phuot_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:phuot_app/view_models/order.dart';
import 'package:phuot_app/view_models/plan_member.dart';
import 'package:phuot_app/view_models/plan_viewmodels/surcharge.dart';

class PlanDetail {
  int? id;
  String? name;
  String? joinMethod;
  List<dynamic>? schedule;
  int? maxMemberCount;
  String? status;
  String? locationName;
  int? locationId;
  double? startLocationLat;
  double? startLocationLng;
  List<dynamic>? imageUrls;
  List<OrderViewModel>? orders;
  List<EmergencyContactViewModel>? savedContacts;
  int? numOfExpPeriod;
  List<PlanMemberViewModel>? members;
  int? gcoinBudgetPerCapita;
  String? travelDuration;
  List<dynamic>? tempOrders;
  int? leaderId;
  String? note;
  int? memberCount;
  List<SurchargeViewModel>? surcharges;
  int? maxMemberWeight;
  String? departureAddress;
  String? leaderName;
  int? actualGcoinBudget;
  int? displayGcoinBudget;
  int? actualNumOfExpPeriod;
  DateTime? utcRegCloseAt;
  DateTime? utcDepartAt;
  DateTime? utcStartAt;
  DateTime? utcEndAt;
  PointLatLng? locationLatLng;
  bool? isPublished;

  PlanDetail(
      {this.id,
      this.schedule,
      this.maxMemberCount,
      this.status,
      this.locationName,
      this.locationId,
      this.imageUrls,
      this.name,
      this.joinMethod,
      this.savedContacts,
      this.members,
      this.gcoinBudgetPerCapita,
      this.startLocationLat,
      this.startLocationLng,
      this.numOfExpPeriod,
      this.travelDuration,
      this.tempOrders,
      this.leaderId,
      this.memberCount,
      this.note,
      this.actualGcoinBudget,
      this.displayGcoinBudget,
      this.surcharges,
      this.maxMemberWeight,
      this.departureAddress,
      this.leaderName,
      this.actualNumOfExpPeriod,
      this.utcDepartAt,
      this.utcEndAt,
      this.utcRegCloseAt,
      this.utcStartAt,
      this.locationLatLng,
      this.isPublished,
      this.orders});

  factory PlanDetail.fromJson(Map<String, dynamic> json) => PlanDetail(
      utcDepartAt: DateTime.parse(json['utcDepartAt']),
      utcEndAt: DateTime.parse(json['utcEndAt']),
      utcRegCloseAt: json['utcRegCloseAt'] == null
          ? null
          : DateTime.parse(json['utcRegCloseAt']),
      utcStartAt: DateTime.parse(json['utcStartAt']),
      id: json["id"],
      name: json["name"],
      leaderName: json['account']['name'],
      tempOrders: json['tempOrders'],
      schedule: json["schedule"],
      maxMemberCount: json["maxMemberCount"],
      status: json["status"],
      leaderId: json['accountId'],
      maxMemberWeight: json['maxMemberWeight'],
      travelDuration: json['travelDuration'],
      locationName: json["destination"]["name"],
      locationId: json["destination"]["id"],
      imageUrls: json["destination"]["imagePaths"],
      joinMethod: json["joinMethod"],
      numOfExpPeriod: json['periodCount'],
      note: json['note'],
      actualGcoinBudget: json['actualGcoinBudget'].toInt(),
      displayGcoinBudget: json['displayGcoinBudget'].toInt(),
      memberCount: json['memberCount'],
      departureAddress: json['departureAddress'],
      isPublished: json['isPublished'],
      gcoinBudgetPerCapita: json['gcoinBudgetPerCapita'].toInt(),
      startLocationLat: json["departure"]["coordinates"][1].toDouble(),
      startLocationLng: json["departure"]["coordinates"][0].toDouble(),
      locationLatLng: PointLatLng(
          json['destination']['coordinate']['coordinates'][1],
          json['destination']['coordinate']['coordinates'][0]),
      surcharges: List<SurchargeViewModel>.from(
              json['surcharges'].map((e) => SurchargeViewModel.fromJsonQuery(e)))
          .toList(),
      members: List<PlanMemberViewModel>.from(
          json['members'].map((e) => PlanMemberViewModel.fromJson(e))).toList(),
      savedContacts: List<EmergencyContactViewModel>.from(json['savedProviders']
          .map((e) => EmergencyContactViewModel.fromJsonByPlan(e))).toList(),
      orders:
          List<OrderViewModel>.from(json['orders'].map((e) => OrderViewModel.fromJson(e))).toList());
}
