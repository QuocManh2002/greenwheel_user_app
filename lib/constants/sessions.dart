import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/models/session.dart';

const List<Session> sessions = [
  Session(
      name: "Buổi sáng",
      range: "06:00 SA - 10:00 SA",
      image: morning,
      enumName: "MORNING"),
  Session(
      name: "Buổi trưa",
      range: "10:00 SA - 14:00 CH",
      image: noon,
      enumName: "NOON"),
  Session(
      name: "Buổi chiều",
      range: "14:00 CH - 18:00 CH",
      image: afternoon,
      enumName: "AFTERNOON"),
  Session(
      name: "Buổi tối",
      range: "18:00 CH - 23:00 CH",
      image: evening,
      enumName: "EVENING"),
];
