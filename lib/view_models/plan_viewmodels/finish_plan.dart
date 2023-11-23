// To parse this JSON data, do
//
//     final planDraft = planDraftFromJson(jsonString);

import 'dart:convert';

PlanFinish planDraftFromJson(String str) => PlanFinish.fromJson(json.decode(str));

String planDraftToJson(PlanFinish data) => json.encode(data.toJson());

class PlanFinish {
    int planId;
    DateTime startDate;
    DateTime endDate;
    int locationId;
    int memberLimit;
    List<List<String>> schedule;

    PlanFinish({
        required this.planId,
        required this.startDate,
        required this.endDate,
        required this.locationId,
        required this.memberLimit,
        required this.schedule,
    });

    factory PlanFinish.fromJson(Map<String, dynamic> json) => PlanFinish(
        planId: json["planId"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        locationId: json["locationId"],
        memberLimit: json["memberLimit"],
        schedule: json["schedule"],
    );

    Map<String, dynamic> toJson() => {
        "planId": planId,
        "startDate": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "locationId": locationId,
        "memberLimit": memberLimit,
        "schedule": schedule,
    };
}