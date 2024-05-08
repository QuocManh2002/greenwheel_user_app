import 'package:greenwheel_user_app/models/plan_status.dart';

List<PlanStatus> planStatuses = [
  PlanStatus(engName: 'PENDING', name: 'Chờ xác nhận', value: 0),
  PlanStatus(engName: 'REGISTERING', name: 'Đang mời', value: 1),
  PlanStatus(engName: 'READY', name: 'Đã chốt', value: 2),
  PlanStatus(engName: 'VERIFIED', name: 'Đã xác nhận', value: 3),
  PlanStatus(engName: 'COMPLETED', name: 'Đã hoàn thành', value: 4),
  PlanStatus(engName: 'FLAWED', name: 'Thiếu sót', value: 5),
  PlanStatus(engName: 'CANCELED', name: 'Đã huỷ', value: 6),
];
