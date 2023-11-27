class RegisterViewModel{
  String name;
  DateTime birthday;
  bool isMale;
  String email;

  RegisterViewModel({
    required this.birthday,
    required this.isMale,
    required this.email,
    required this.name
  });
}