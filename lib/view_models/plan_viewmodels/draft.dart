// To parse this JSON data, do
//
//     final planDraft = planDraftFromJson(jsonString);

import 'dart:convert';

PlanDraft planDraftFromJson(String str) => PlanDraft.fromJson(json.decode(str));

String planDraftToJson(PlanDraft data) => json.encode(data.toJson());

class PlanDraft {
    DateTime startDate;
    DateTime endDate;
    int locationId;
    int memberLimit;

    PlanDraft({
        required this.startDate,
        required this.endDate,
        required this.locationId,
        required this.memberLimit,
    });

    factory PlanDraft.fromJson(Map<String, dynamic> json) => PlanDraft(
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        locationId: json["locationId"],
        memberLimit: json["memberLimit"],
    );

    Map<String, dynamic> toJson() => {
        "startDate": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "locationId": locationId,
        "memberLimit": memberLimit,
    };
}