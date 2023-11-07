import 'package:greenwheel_user_app/view_models/order_detail_create.dart';

class OrderCreateViewModel {
  int planId;
  DateTime pickupDate;
  DateTime? returnDate;
  String? note;
  String paymentMethod;
  String transactionId;
  int deposit;
  List<OrderDetailCreateViewModel> details;

  OrderCreateViewModel({
    required this.planId,
    required this.pickupDate,
    this.returnDate,
    this.note,
    required this.paymentMethod,
    required this.transactionId,
    required this.deposit,
    required this.details,
  });

  factory OrderCreateViewModel.fromJson(Map<String, dynamic> json) =>
      OrderCreateViewModel(
        planId: json["planId"],
        pickupDate: json["pickupDate"],
        returnDate: json["returnDate"],
        note: json["note"],
        paymentMethod: json["paymentMethod"],
        transactionId: json["transactionId"],
        deposit: json["deposit"],
        details: List<OrderDetailCreateViewModel>.from(
            json["details"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "planId": planId,
        "pickupDate": pickupDate,
        "returnDate": returnDate,
        "note": note,
        "paymentMethod": paymentMethod,
        "transactionId": transactionId,
        "deposit": deposit,
        "details": List<dynamic>.from(details.map((x) => x)),
      };
}
