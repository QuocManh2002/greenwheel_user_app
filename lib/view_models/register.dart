class RegisterViewModel{
  String name;
  bool isMale;
  String email;
  String deviceToken;

  RegisterViewModel({
    required this.isMale,
    required this.email,
    required this.name,
    required this.deviceToken
  });
}