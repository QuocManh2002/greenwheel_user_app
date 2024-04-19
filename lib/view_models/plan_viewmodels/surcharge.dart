import 'dart:convert';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class SurchargeViewModel {
  String? id;
  bool? alreadyDivided;
  String? imagePath;
  int gcoinAmount;
  String note;
  SurchargeViewModel(
      {String? id,
      this.alreadyDivided,
      this.imagePath,
      required this.gcoinAmount,
      required this.note})
      : id = id ?? uuid.v4();

  factory SurchargeViewModel.fromJsonQuery(Map<String, dynamic> json) =>
      SurchargeViewModel(
          id: json['id'].toString(),
          imagePath: json['imagePath'],
          gcoinAmount: json['gcoinAmount'],
          note: "${json['note']}");

  factory SurchargeViewModel.fromJsonLocal(Map<String, dynamic> json) =>
      SurchargeViewModel(
          id: json['id'].toString(),
          imagePath: json['imagePath'],
          alreadyDivided: json['alreadyDivided'],
          gcoinAmount: json['gcoinAmount'],
          note: json['note']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'alreadyDivided': alreadyDivided,
        'imagePath': imagePath,
        'gcoinAmount': gcoinAmount,
        'note': json.encode(note),
      };

  Map<String, dynamic> toJsonWithoutImage() => {
        'id': id,
        'alreadyDivided': true,
        'imagePath': null,
        'gcoinAmount': gcoinAmount,
        'note': json.encode(note),
      };
}
