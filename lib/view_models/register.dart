import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RegisterViewModel{
  String name;
  bool isMale;
  String email;
  String deviceToken;
  String defaultAddress;
  PointLatLng defaultCoordinate;

  RegisterViewModel({
    required this.isMale,
    required this.email,
    required this.name,
    required this.deviceToken,
    required this.defaultAddress,
    required this.defaultCoordinate
  });
}