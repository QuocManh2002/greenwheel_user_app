import 'package:phuot_app/view_models/order_detail.dart';
import 'package:phuot_app/view_models/supplier.dart';

class OrderViewModel {
  int? id;
  String? uuid;
  double? total;
  double? actualTotal;
  String? note;
  List<String>? serveDates;
  int? rating;
  DateTime? createdAt;
  List<OrderDetailViewModel>? details;
  String? period;
  String? type;
  SupplierViewModel? supplier;
  String? currentStatus;

  OrderViewModel(
      {this.id,
      this.period,
      this.note,
      this.serveDates,
      this.total,
      this.details,
      this.createdAt,
      this.type,
      this.uuid,
      this.supplier,
      this.currentStatus,
      this.actualTotal});

  factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
      id: json["id"],
      uuid: json['uuid'],
      note: json["note"],
      serveDates: List<String>.from(json["serveDates"].map((e) => e)).toList(),
      total: double.parse(json["total"].toString()),
      createdAt: DateTime.parse(json["createdAt"]),
      type: json['type'],
      currentStatus: json['currentStatus'],
      details: List<OrderDetailViewModel>.from(
              json['details'].map((e) => OrderDetailViewModel.fromJson(e)))
          .toList(),
      supplier: SupplierViewModel(
          latitude: json['provider']['coordinate']['coordinates'][1],
          longitude: json['provider']['coordinate']['coordinates'][0],
          type: json["provider"]['type'],
          id: json["provider"]["id"],
          name: json["provider"]["name"],
          phone: json["provider"]["phone"],
          isActive: json['provider']['isActive'],
          thumbnailUrl: json["provider"]["imagePath"],
          address: json["provider"]["address"]),
      period: json['period']);
}
