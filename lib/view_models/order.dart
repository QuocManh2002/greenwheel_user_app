import 'package:greenwheel_user_app/view_models/order_detail.dart';

class OrderViewModel {
  int id;
  int travelerId;
  int deposit;
  int total;
  String? note;
  List<dynamic> servingDates;
  String? comment;
  int? rating;
  List<OrderDetailViewModel>? details;

  OrderViewModel({
    required this.id,
    required this.travelerId,
    required this.deposit,
    this.note,
    required this.servingDates,
    required this.total,
    this.details,
  });

  factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
        id: json["id"],
        travelerId: json["travelerId"],
        deposit: json["deposit"],
        note: json["note"],
        servingDates: json["servingDates"],
        total: json["total"]
      );

  List<OrderDetailViewModel> getDetails(dynamic details) {
    List<OrderDetailViewModel> list = [];
    for (final detail in details) {
      list.add(OrderDetailViewModel.fromJson(detail));
    }
    return list;
  }
}
