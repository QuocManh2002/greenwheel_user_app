import 'dart:convert';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class SurchargeViewModel {
  String? id;
  bool alreadyDivided;
  String? imagePath;
  int amount;
  String note;
  SurchargeViewModel(
      {String? id,
      required this.alreadyDivided,
      this.imagePath,
      required this.amount,
      required this.note})
      : id = id ?? uuid.v4();

  factory SurchargeViewModel.fromJsonQuery(Map<String, dynamic> json) =>
      SurchargeViewModel(
          id: json['id'].toString(),
          imagePath: json['imagePath'],
          alreadyDivided: json['alreadyDivided'],
          amount: json['amount'],
          note: "${json['note']}"
          
          );

  factory SurchargeViewModel.fromJsonLocal(Map<String, dynamic> json) =>
      SurchargeViewModel(
          id: json['id'].toString(),
          imagePath: json['imagePath'],
          alreadyDivided: json['alreadyDivided'],
          amount: json['amount'],
          note: json['note']);


  Map<String, dynamic> toJson() => {
        'id': id,
        'alreadyDivided': alreadyDivided,
        'imagePath': imagePath,
        'amount': amount,
        'note': json.encode(note),
      };
}
