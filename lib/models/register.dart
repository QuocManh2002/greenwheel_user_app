import 'package:phuot_app/view_models/customer.dart';

class RegisterModel {
  String accessToken;
  String refreshToken;
  TravelerViewModel traveler;

  RegisterModel(
      {required this.accessToken,
      required this.traveler,
      required this.refreshToken});

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
      traveler: TravelerViewModel.fromJson(json['account']),
      accessToken: json['authResult']['accessToken'],
      refreshToken: json['authResult']['refreshToken']);
}
