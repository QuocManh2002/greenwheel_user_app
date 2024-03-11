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
    int accountId;
    int? accountType;
    int weight;
    String? imageUrl;

    PlanMemberViewModel({
        required this.name,
        required this.memberId,
        required this.phone,
        required this.status,
        required this.accountId,
        this.accountType,
        this.imageUrl,
        required this.weight,
    });

    factory PlanMemberViewModel.fromJson(Map<String, dynamic> json) => PlanMemberViewModel(
        name: json["account"]["name"],
        memberId: json["id"],
        phone: json["account"]["phone"],
        status: json["status"],
        accountId: json['account']['id'],
        weight: json['weight'],
        imageUrl: json['account']['avatarUrl']
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "travelerId": memberId,
        "phone": phone,
        "status": status,
    };
}