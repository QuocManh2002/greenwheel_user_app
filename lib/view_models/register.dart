import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RegisterViewModel{
  String name;
  bool isMale;
  String deviceToken;

  RegisterViewModel({
    required this.isMale,
    required this.name,
    required this.deviceToken,
  });
}