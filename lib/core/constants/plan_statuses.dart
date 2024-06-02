import 'package:phuot_app/models/plan_status.dart';

List<PlanStatus> planStatuses = [
  PlanStatus(engName: 'PENDING', name: 'Chờ xác nhận', value: 0),
  PlanStatus(engName: 'REGISTERING', name: 'Đang chờ tham gia', value: 1),
  PlanStatus(engName: 'READY', name: 'Sắp diễn ra', value: 2),
  PlanStatus(engName: 'ONGOING', name: 'Đang diễn ra', value: 3),
  PlanStatus(engName: 'VERIFIED', name: 'Đã xác nhận', value: 4),
  PlanStatus(engName: 'COMPLETED', name: 'Đã kết thúc', value: 5),
  PlanStatus(engName: 'FLAWED', name: 'Đã kết thúc', value: 6),
  PlanStatus(engName: 'CANCELED', name: 'Đã huỷ', value: 7),
];
