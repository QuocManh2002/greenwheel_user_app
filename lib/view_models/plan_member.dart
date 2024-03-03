// To parse this JSON data, do
//
//     final planMember = planMemberFromJson(jsonString);

import 'dart:convert';

PlanMemberViewModel planMemberFromJson(String str) => PlanMemberViewModel.fromJson(json.decode(str));

String planMemberToJson(PlanMemberViewModel data) => json.encode(data.toJson());

class PlanMemberViewModel {
    String name;
    int memberId;
    String phone;
    String status;

    PlanMemberViewModel({
        required this.name,
        required this.memberId,
        required this.phone,
        required this.status,
    });

    factory PlanMemberViewModel.fromJson(Map<String, dynamic> json) => PlanMemberViewModel(
        name: json["account"]["name"],
        memberId: json["id"],
        phone: json["account"]["phone"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "travelerId": memberId,
        "phone": phone,
        "status": status,
    };
}