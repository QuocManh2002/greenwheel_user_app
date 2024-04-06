import 'package:greenwheel_user_app/view_models/order_detail.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';

class OrderViewModel {
  int? id;
  String? guid;
  double? total;
  String? note;
  List<dynamic>? serveDates;
  int? rating;
  DateTime? createdAt;
  List<dynamic>? details;
  String? period;
  String? type;
  SupplierViewModel? supplier;

  OrderViewModel({
    this.id,
    this.period,
    this.note,
    this.serveDates,
    this.total,
    this.details,
    this.createdAt,
    this.type,
    this.guid,
    this.supplier,
  });

  factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
      id: json["id"],
      guid: json['guid'],
      note: json["note"],
      serveDates: json["serveDates"],
      total: double.parse(json["total"].toString()),
      createdAt: DateTime.parse(json["createdAt"]),
      type: json['type'],
      details: List<OrderDetailViewModel>.from(json['details'].map((e) => OrderDetailViewModel.fromJson(e))).toList(),
      supplier: SupplierViewModel(
          type: json["provider"]['type'],
          id: json["provider"]["id"],
          name: json["provider"]["name"],
          phone: json["provider"]["phone"],
          thumbnailUrl: json["provider"]["imageUrl"],
          address: json["provider"]["address"]),
      period: json['period']);

  List<OrderDetailViewModel> getDetails(dynamic details) {
    List<OrderDetailViewModel> list = [];
    for (final detail in details) {
      list.add(OrderDetailViewModel.fromJson(detail));
    }
    return list;
  }
}
