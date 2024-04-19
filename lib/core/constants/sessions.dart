import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/models/session.dart';

const List<Session> sessions = [
  Session(
      index: 0,
      name: "Buổi sáng",
      range: "06:00 SA - 10:00 SA",
      image: morning,
      from: 6,
      to: 10,
      enumName: "MORNING"),
  Session(
      index: 1,
      name: "Buổi trưa",
      range: "10:00 SA - 14:00 CH",
      image: noon,
      from: 10,
      to: 14,
      enumName: "NOON"),
  Session(
      index: 2,
      name: "Buổi chiều",
      range: "14:00 CH - 18:00 CH",
      image: afternoon,
      from: 14,
      to: 18,
      enumName: "AFTERNOON"),
  Session(
      index: 3,
      name: "Buổi tối",
      range: "18:00 CH - 22:00 CH",
      image: evening,
      from: 18,
      to: 22,
      enumName: "EVENING"),
];
