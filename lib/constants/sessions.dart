import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/models/session.dart';

const List<Session> sessions = [
  Session(name: "Buổi sáng", range: "06:00 SA - 10:00 SA", image: morning),
  Session(name: "Buổi trưa", range: "10:00 SA - 14:00 CH", image: noon),
  Session(name: "Buổi chiều", range: "14:00 CH - 18:00 CH", image: afternoon),
  Session(name: "Buổi tối", range: "18:00 CH - 23:00 CH", image: evening),
];
