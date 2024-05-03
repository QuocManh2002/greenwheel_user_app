class LoginModel {
  String accessToken;
  String refreshToken;
  String? deviceToken;
  LoginModel(
      {required this.accessToken,
      required this.refreshToken,
       this.deviceToken});

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
      deviceToken: json['deviceToken'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken']);
}
