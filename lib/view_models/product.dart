class ProductViewModel {
  int id;
  String name;
  int price;
  String? thumbnailUrl;
  int? partySize;
  int? supplierId;
  String? supplierName;
  String? supplierThumbnailUrl;
  String? supplierPhone;
  String? supplierAddress;
  String? supplierType;

  ProductViewModel(
      {required this.id,
      required this.name,
      required this.price,
      this.thumbnailUrl,
      this.supplierId,
      this.supplierName,
      this.partySize,
      this.supplierThumbnailUrl,
      this.supplierPhone,
      this.supplierType,
      this.supplierAddress});

  factory ProductViewModel.fromJson(Map<String, dynamic> json) =>
      ProductViewModel(
          id: json["id"],
          name: json["name"],
          price: json["price"],
          thumbnailUrl: json["imageUrl"],
          supplierId: json["supplier"]["id"],
          supplierName: json["supplier"]["name"],
          partySize: json["partySize"],
          supplierThumbnailUrl: json['supplier']['imageUrl'],
          supplierPhone: json['supplier']['phone'],
          supplierType: json['supplier']['type'],
          supplierAddress: json['supplier']['address']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "originalPrice": price,
        "thumbnailUrl": thumbnailUrl,
        "supplierId": supplierId,
        "supplierName": supplierName,
        "partySize": partySize,
      };
}
