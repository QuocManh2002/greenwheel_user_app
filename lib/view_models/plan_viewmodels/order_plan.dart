import 'dart:convert';

OrderCreatePlan orderCreatePlanFromJson(String str) => OrderCreatePlan.fromJson(json.decode(str));

String orderCreatePlanToJson(OrderCreatePlan data) => json.encode(data.toJson());

class OrderCreatePlan {
    int id;
    int planId;
    String type;
    int deposit;
    String thumbnailUrl;
    List<OrderCreatePlanDetail> details;

    OrderCreatePlan({
        required this.id,
        required this.planId,
        required this.type,
        required this.deposit,
        required this.thumbnailUrl,
        required this.details,
    });

    factory OrderCreatePlan.fromJson(Map<String, dynamic> json) => OrderCreatePlan(
        id: json["id"],
        planId: json["planId"],
        type: json['details'][0]['product']['supplier']["type"],
        deposit: json["deposit"],
        thumbnailUrl: json['details'][0]['product']['supplier']["thumbnailUrl"],
        details: List<OrderCreatePlanDetail>.from(json["details"].map((x) => OrderCreatePlanDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "planId": planId,
        "type": type,
        "deposit": deposit,
        "thumbnailUrl": thumbnailUrl,
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
    };
}
class OrderCreatePlanDetail {
    int price;
    int quantity;
    String productName;
    String supplierName;

    OrderCreatePlanDetail({
        required this.price,
        required this.quantity,
        required this.productName,
        required this.supplierName,
    });

    factory OrderCreatePlanDetail.fromJson(Map<String, dynamic> json) => OrderCreatePlanDetail(
        price: json["price"],
        quantity: json["quantity"],
        productName: json['product']["name"],
        supplierName: json['product']['supplier']["name"],
    );

    Map<String, dynamic> toJson() => {
        "price": price,
        "quantity": quantity,
        "producName": productName,
        "supplierName": supplierName,
    };
}
