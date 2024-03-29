class LoginModel {
  String accessToken;
  String refreshToken;
  LoginModel({required this.accessToken, required this.refreshToken});

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
      accessToken: json['accessToken'], refreshToken: json['refreshToken']);
}
