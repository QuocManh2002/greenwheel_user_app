class ProductViewModel {
  int id;
  String name;
  String paymentType;
  int originalPrice;
  String thumbnailUrl;
  int supplierId;
  String supplierName;
  int? partySize;

  ProductViewModel({
    required this.id,
    required this.name,
    required this.paymentType,
    required this.originalPrice,
    required this.thumbnailUrl,
    required this.supplierId,
    required this.supplierName,
    required this.partySize,
  });

  factory ProductViewModel.fromJson(Map<String, dynamic> json) =>
      ProductViewModel(
        id: json["id"],
        name: json["name"],
        paymentType: json["paymentType"],
        originalPrice: json["originalPrice"],
        thumbnailUrl: json["thumbnailUrl"],
        supplierId: json["supplier"]["id"],
        supplierName: json["supplier"]["name"],
        partySize: json["partySize"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "paymentType": paymentType,
        "originalPrice": originalPrice,
        "thumbnailUrl": thumbnailUrl,
        "supplierId": supplierId,
        "supplierName": supplierName,
        "partySize": partySize,
      };
}
