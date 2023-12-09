import 'package:greenwheel_user_app/view_models/order_detail_create.dart';

class OrderCreateViewModel {
  final int? planId;
  final List<dynamic> servingDates;
  final String period;
  String? note;
  final List<OrderDetailCreateViewModel> details;

  OrderCreateViewModel({
    this.planId,
    required this.servingDates,
    required this.period,
    this.note,
    required this.details,
  });

//   factory OrderCreateViewModel.fromJson(Map<String, dynamic> json) =>
//       OrderCreateViewModel(
//         planId: json["planId"],
        
//         note: json["note"],
//         details: List<OrderDetailCreateViewModel>.from(
//             json["details"].map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "planId": planId,
//         "pickupDate": pickupDate,
//         "returnDate": returnDate,
//         "note": note,
//         "details": List<dynamic>.from(details.map((x) => x)),
//       };
}
