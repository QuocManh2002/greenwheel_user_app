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

    OrderDetailViewModel({
        required this.id,
        required this.productName,
        required this.quantity,
        required this.price,
    });

    factory OrderDetailViewModel.fromJson(Map<String, dynamic> json) => OrderDetailViewModel(
        id: json["id"],
        productName: json["product"]["name"],
        quantity: json["quantity"],
        price: json["price"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "productName": productName,
        "quantity": quantity,
        "price": price,
    };
}
