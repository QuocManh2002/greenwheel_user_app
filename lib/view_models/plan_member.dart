// To parse this JSON data, do
//
//     final planMember = planMemberFromJson(jsonString);

import 'dart:convert';

PlanMemberViewModel planMemberFromJson(String str) => PlanMemberViewModel.fromJson(json.decode(str));

class PlanMemberViewModel {
    String name;
    int memberId;
    String phone;
    String status;
    int accountId;
    int weight;
    String? imagePath;
    List<dynamic>? companions;
    bool isMale;

    PlanMemberViewModel({
        required this.name,
        required this.memberId,
        required this.phone,
        required this.status,
        required this.accountId,
        this.companions,
        this.imagePath,
        required this.weight,
        required this.isMale
    });

    factory PlanMemberViewModel.fromJson(Map<String, dynamic> json) => PlanMemberViewModel(
        name: json["account"]["name"],
        memberId: json["id"],
        phone: json["account"]["phone"],
        status: json["status"],
        accountId: json['account']['id'],
        weight: json['weight'],
        imagePath: json['account']['avatarPath'],
        companions: json['companions'],
        isMale: json['account']['isMale']
    );
}