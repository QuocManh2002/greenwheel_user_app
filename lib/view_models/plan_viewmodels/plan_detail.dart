
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/surcharge.dart';
import 'package:intl/intl.dart';

class PlanDetail {
  int id;
  String? name;
  DateTime? departDate;
  DateTime? departTime;
  DateTime? startDate;
  DateTime? endDate;
  String? joinMethod;
  List<dynamic> schedule;
  int maxMemberCount;
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
  String? travelDuration;
  List<dynamic>? tempOrders;
  int? leaderId;
  String? note;
  int? memberCount;
  List<SurchargeViewModel>? surcharges;
  int? maxMemberWeight;
  String? departureAddress;
  DateTime? regCloseAt;
  String? leaderName;
  int? actualGcoinBudget;
  int? displayGcoinBudget;
  int? gcoinHostDonated;

  PlanDetail(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.schedule,
      required this.maxMemberCount,
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
      required this.departDate,
      this.departTime,
      this.travelDuration,
      this.tempOrders,
      this.leaderId,
      this.memberCount,
      this.note,
      this.actualGcoinBudget,
      this.displayGcoinBudget,
      this.gcoinHostDonated,
      this.surcharges,
      this.maxMemberWeight,
      this.departureAddress,
      this.regCloseAt,
      this.leaderName,
      this.orders});

  factory PlanDetail.fromJson(Map<String, dynamic> json) => PlanDetail(
        id: json["id"],
        name: json["name"],
        leaderName: json['account']['name'],
        tempOrders: json['tempOrders'],
        departDate: DateTime.parse(json['departDate']),
        departTime: DateFormat.Hms().parse(json['departTime']),
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
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
        gcoinHostDonated: json['gcoinHostDonated'],
        actualGcoinBudget: json['actualGcoinBudget'],
        displayGcoinBudget: json['displayGcoinBudget'],
        memberCount: json['memberCount'],
        regCloseAt: DateTime.parse(json['regCloseAt']),
        departureAddress: json['departureAddress'],
        gcoinBudgetPerCapita: json['gcoinBudgetPerCapita'],
        startLocationLat: json["departure"]["coordinates"][1].toDouble(),
        startLocationLng: json["departure"]["coordinates"][0].toDouble(),
        surcharges: List<SurchargeViewModel>.from(json['surcharges'].map((e) => SurchargeViewModel.fromJson(e))).toList(),
        members: List<PlanMemberViewModel>.from(json['members'].map((e) => PlanMemberViewModel.fromJson(e))).toList(),
        savedContacts: List<EmergencyContactViewModel>.from(json['savedContacts'].map((e) => EmergencyContactViewModel.fromJsonByLocation(e))).toList(),
      );
}
