// To parse this JSON data, do
//
//     final planMember = planMemberFromJson(jsonString);

import 'dart:convert';

PlanMemberViewModel planMemberFromJson(String str) => PlanMemberViewModel.fromJson(json.decode(str));

String planMemberToJson(PlanMemberViewModel data) => json.encode(data.toJson());

class PlanMemberViewModel {
    String name;
    int travelerId;
    String phone;
    String status;

    PlanMemberViewModel({
        required this.name,
        required this.travelerId,
        required this.phone,
        required this.status,
    });

    factory PlanMemberViewModel.fromJson(Map<String, dynamic> json) => PlanMemberViewModel(
        name: json["account"]["name"],
        travelerId: json["id"],
        phone: json["account"]["phone"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "travelerId": travelerId,
        "phone": phone,
        "status": status,
    };
}