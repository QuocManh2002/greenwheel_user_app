import 'package:greenwheel_user_app/view_models/product.dart';

class OrderDetailViewModel {
  int id;
  int quantity;
  int orderId;
  ProductViewModel product;

  OrderDetailViewModel({
    required this.id,
    required this.quantity,
    required this.orderId,
    required this.product,
  });

  factory OrderDetailViewModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailViewModel(
        id: json["id"],
        quantity: json["quantity"],
        orderId: json["orderId"],
        product: json["product"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quantity": quantity,
        "orderId": orderId,
        "product": product,
      };
}
