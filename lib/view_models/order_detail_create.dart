class OrderDetailCreateViewModel {
  int productId;
  int quantity;

  OrderDetailCreateViewModel({
    required this.productId,
    required this.quantity,
  });

  factory OrderDetailCreateViewModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailCreateViewModel(
        productId: json["productId"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "quantity": quantity,
      };
}
