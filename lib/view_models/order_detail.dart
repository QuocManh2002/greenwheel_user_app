// To parse this JSON data, do
//
//     final orderDetail = orderDetailFromJson(jsonString);

import 'dart:convert';

OrderDetailViewModel orderDetailFromJson(String str) =>
    OrderDetailViewModel.fromJson(json.decode(str));

String orderDetailToJson(OrderDetailViewModel data) =>
    json.encode(data.toJson());

class OrderDetailViewModel {
  int? id;
  String productName;
  int productId;
  int quantity;
  double? price;
  bool? isAvailable;
  int? partySize;

  OrderDetailViewModel(
      {this.id,
      required this.productName,
      required this.quantity,
      this.partySize,
      this.price,
      required this.productId,
      this.isAvailable});

  factory OrderDetailViewModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailViewModel(
          id: json["id"],
          productId: json['product']['id'],
          productName: json["product"]["name"],
          quantity: json["quantity"],
          partySize: json["product"]['partySize'],
          isAvailable: json['product']['isAvailable'],
          price: double.parse(json['product']['price'].toString()),
          );

  Map<String, dynamic> toJson() => {
        "id": id,
        "productName": productName,
        "quantity": quantity,
        "price": price,
      };
}
