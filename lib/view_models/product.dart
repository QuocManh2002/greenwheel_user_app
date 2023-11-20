class ProductViewModel {
  int id;
  String name;
  String paymentType;
  int price;
  String thumbnailUrl;
  int supplierId;
  String supplierName;

  ProductViewModel({
    required this.id,
    required this.name,
    required this.paymentType,
    required this.price,
    required this.thumbnailUrl,
    required this.supplierId,
    required this.supplierName,
  });

  factory ProductViewModel.fromJson(Map<String, dynamic> json) =>
      ProductViewModel(
        id: json["id"],
        name: json["name"],
        paymentType: json["paymentType"],
        price: json["price"],
        thumbnailUrl: json["thumbnailUrl"],
        supplierId: json["supplier"]["id"],
        supplierName: json["supplier"]["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "paymentType": paymentType,
        "price": price,
        "thumbnailUrl": thumbnailUrl,
        "supplierId": supplierId,
        "supplierName": supplierName,
      };
}
