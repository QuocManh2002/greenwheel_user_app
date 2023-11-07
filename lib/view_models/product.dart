class ProductViewModel {
  int id;
  String name;
  String paymentType;
  int price;
  String thumbnailUrl;
  int supplierId;

  ProductViewModel({
    required this.id,
    required this.name,
    required this.paymentType,
    required this.price,
    required this.thumbnailUrl,
    required this.supplierId,
  });

  factory ProductViewModel.fromJson(Map<String, dynamic> json) =>
      ProductViewModel(
        id: json["id"],
        name: json["name"],
        paymentType: json["paymentType"],
        price: json["price"],
        thumbnailUrl: json["thumbnailUrl"],
        supplierId: json["supplierId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "paymentType": paymentType,
        "price": price,
        "thumbnailUrl": thumbnailUrl,
        "supplierId": supplierId,
      };
}
