
class RegisterViewModel{
  String name;
  bool isMale;
  String deviceToken;
  String? avatarUrl;

  RegisterViewModel({
    required this.isMale,
    required this.name,
    required this.deviceToken,
    this.avatarUrl,
  });
}