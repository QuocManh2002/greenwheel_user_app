import 'package:greenwheel_user_app/view_models/order_detail.dart';

class OrderViewModel {
  int id;
  int userId;
  double deposit;
  String note;
  DateTime orderDate;
  DateTime pickupDate;
  DateTime? returnDate;
  String paymentMethod;
  String? comment;
  int? rating;
  String transactionId;
  List<OrderDetailViewModel> details;

  OrderViewModel({
    required this.id,
    required this.userId,
    required this.deposit,
    required this.note,
    required this.orderDate,
    required this.pickupDate,
    this.returnDate,
    required this.paymentMethod,
    this.comment,
    this.rating,
    required this.transactionId,
    required this.details,
  });

  factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
        id: json["id"],
        userId: json["userId"],
        deposit: json["deposit"],
        note: json["note"],
        orderDate: json["orderDate"],
        pickupDate: json["pickupDate"],
        returnDate: json["returnDate"],
        paymentMethod: json["paymentMethod"],
        comment: json["comment"],
        rating: json["rating"],
        transactionId: json["transactionId"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "deposit": deposit,
        "note": note,
        "orderDate": orderDate,
        "pickupDate": pickupDate,
        "returnDate": returnDate,
        "paymentMethod": paymentMethod,
        "comment": comment,
        "rating": rating,
        "transactionId": transactionId,
        "details": details,
      };
}
