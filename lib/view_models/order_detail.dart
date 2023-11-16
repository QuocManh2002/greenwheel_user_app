// To parse this JSON data, do
//
//     final orderDetail = orderDetailFromJson(jsonString);

import 'dart:convert';

OrderDetailViewModel orderDetailFromJson(String str) => OrderDetailViewModel.fromJson(json.decode(str));

String orderDetailToJson(OrderDetailViewModel data) => json.encode(data.toJson());

class OrderDetailViewModel {
    int id;
    String productName;
    int quantity;
    int price;
    String type;
    String supplierName;
    String supplierThumbnailUrl;

    OrderDetailViewModel({
        required this.id,
        required this.productName,
        required this.quantity,
        required this.price,
        required this.supplierName,
        required this.supplierThumbnailUrl,
        required this.type
    });

    factory OrderDetailViewModel.fromJson(Map<String, dynamic> json) => OrderDetailViewModel(
        id: json["id"],
        productName: json["product"]["name"],
        quantity: json["quantity"],
        price: json["price"],
        supplierName: json["product"]["supplier"]["name"],
        supplierThumbnailUrl: json["product"]["supplier"]["thumbnailUrl"],
        type: json["product"]["supplier"]["type"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "productName": productName,
        "quantity": quantity,
        "price": price,
        "supplierName": supplierName,
        "supplierThumbnailUrl": supplierThumbnailUrl,
    };
}
