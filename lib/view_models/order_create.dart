import 'package:greenwheel_user_app/view_models/order_detail_create.dart';

class OrderCreateViewModel {
  int? planId;
  DateTime pickupDate;
  DateTime? returnDate;
  String? note;
  List<OrderDetailCreateViewModel> details;

  OrderCreateViewModel({
    this.planId,
    required this.pickupDate,
    this.returnDate,
    this.note,
    required this.details,
  });

  factory OrderCreateViewModel.fromJson(Map<String, dynamic> json) =>
      OrderCreateViewModel(
        planId: json["planId"],
        pickupDate: json["pickupDate"],
        returnDate: json["returnDate"],
        note: json["note"],
        details: List<OrderDetailCreateViewModel>.from(
            json["details"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "planId": planId,
        "pickupDate": pickupDate,
        "returnDate": returnDate,
        "note": note,
        "details": List<dynamic>.from(details.map((x) => x)),
      };
}
