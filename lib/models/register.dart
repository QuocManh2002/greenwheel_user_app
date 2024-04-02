class RegisterModel {
  String accessToken;
  String refreshToken;
  int accountId;

  RegisterModel(
      {required this.accessToken,
      required this.accountId,
      required this.refreshToken});

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
      accountId: json['account']['id'],
      accessToken: json['authResult']['accessToken'],
      refreshToken: json['authResult']['refreshToken']);
}
