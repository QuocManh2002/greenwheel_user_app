import 'package:greenwheel_user_app/view_models/order_detail.dart';

class OrderViewModel {
  int id;
  int customerId;
  int deposit;
  String note;
  DateTime orderDate;
  DateTime pickupDate;
  DateTime? returnDate;
  String paymentMethod;
  String? comment;
  int? rating;
  String transactionId;
  List<OrderDetailViewModel>? details;

  OrderViewModel({
    required this.id,
    required this.customerId,
    required this.deposit,
    required this.note,
    required this.orderDate,
    required this.pickupDate,
    this.returnDate,
    required this.paymentMethod,
    required this.transactionId,
    this.details,
  });

  factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
        id: json["id"],
        customerId: json["customerId"],
        deposit: json["deposit"],
        note: json["note"],
        orderDate: DateTime.parse(json["orderDate"]),
        pickupDate: DateTime.parse(json["pickupDate"]),
        returnDate: json["returnDate"] == null
            ? null
            : DateTime.parse(json["returnDate"]),
        paymentMethod: json["paymentMethod"],
        transactionId: json["transactionId"],
        // details: getDetails(json["details"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": customerId,
        "deposit": deposit,
        "note": note,
        "orderDate": orderDate,
        "pickupDate": pickupDate,
        "returnDate": returnDate,
        "paymentMethod": paymentMethod,
        "transactionId": transactionId,
        // "details": details,
      };
  List<OrderDetailViewModel> getDetails(dynamic details) {
    List<OrderDetailViewModel> list = [];
    for (final detail in details) {
      list.add(OrderDetailViewModel.fromJson(detail));
    }
    return list;
  }
}
