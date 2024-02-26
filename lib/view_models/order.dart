
import 'package:greenwheel_user_app/view_models/order_detail.dart';

class OrderViewModel {
  int id;
  double deposit;
  double total;
  String? note;
  List<dynamic> serveDateIndexes;
  String? comment;
  int? rating;
  int supplierId;
  DateTime createdAt;
  String supplierName;
  String supplierPhone;
  String supplierImageUrl;
  String supplierAddress;
  List<OrderDetailViewModel>? details;
  String period;
  String? type;

  OrderViewModel(
      {required this.id,
      required this.deposit,
      required this.period,
      this.note,
      required this.serveDateIndexes,
      required this.total,
      this.details,
      required this.createdAt,
      required this.supplierId,
      required this.supplierName,
      required this.supplierPhone,
      required this.supplierAddress,
      this.type,
      required this.supplierImageUrl});

  factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
      id: json["id"],
      deposit: double.parse(json["deposit"].toString()),
      note: json["note"],
      serveDateIndexes: json["serveDateIndexes"],
      total: double.parse(json["total"].toString()),
      createdAt: DateTime.parse(json["createdAt"]),
      supplierId: json["supplier"]["id"],
      supplierName: json["supplier"]["name"],
      type: json['details'][0]['product']['type'],
      supplierPhone: json["supplier"]["phone"],
      supplierAddress: json["supplier"]["address"],
      supplierImageUrl: json["supplier"]["imageUrl"],
      period: json['period']);

  List<OrderDetailViewModel> getDetails(dynamic details) {
    List<OrderDetailViewModel> list = [];
    for (final detail in details) {
      list.add(OrderDetailViewModel.fromJson(detail));
    }
    return list;
  }
}
