class ProductViewModel {
  int id;
  bool isAvailable;
  String name;
  String paymentType;
  double price;
  String thumbnailUrl;
  int supplierId;

  ProductViewModel({
    required this.id,
    required this.isAvailable,
    required this.name,
    required this.paymentType,
    required this.price,
    required this.thumbnailUrl,
    required this.supplierId,
  });

  factory ProductViewModel.fromJson(Map<String, dynamic> json) =>
      ProductViewModel(
        id: json["id"],
        isAvailable: json["isAvailable"],
        name: json["name"],
        paymentType: json["paymentType"],
        price: json["price"],
        thumbnailUrl: json["thumbnailUrl"],
        supplierId: json["supplierId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isAvailable": isAvailable,
        "name": name,
        "paymentType": paymentType,
        "price": price,
        "thumbnailUrl": thumbnailUrl,
        "supplierId": supplierId,
      };
}
