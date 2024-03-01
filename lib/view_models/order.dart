import 'package:greenwheel_user_app/view_models/order_detail.dart';

class OrderViewModel {
  int? id;
  double? total;
  String? note;
  List<dynamic>? serveDateIndexes;
  int? rating;
  int? supplierId;
  DateTime? createdAt;
  String? supplierName;
  String? supplierPhone;
  String? supplierImageUrl;
  String? supplierAddress;
  List<OrderDetailViewModel>? details;
  String? period;
  String? type;

  OrderViewModel(
      {this.id,
      this.period,
      this.note,
      this.serveDateIndexes,
      this.total,
      this.details,
      this.createdAt,
      this.supplierId,
      this.supplierName,
      this.supplierPhone,
      this.supplierAddress,
      this.type,
      required this.supplierImageUrl});

  factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
      id: json["id"],
      note: json["note"],
      serveDateIndexes: json["serveDateIndexes"],
      total: double.parse(json["total"].toString()),
      createdAt: DateTime.parse(json["createdAt"]),
      supplierId: json["supplier"]["id"],
      supplierName: json["supplier"]["name"],
      type: json['type'],
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
