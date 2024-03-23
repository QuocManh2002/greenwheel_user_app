class ProductViewModel {
  int id;
  String name;
  int price;
  String? thumbnailUrl;
  int? supplierId;
  String? supplierName;
  int? partySize;
  String? supplierThumbnailUrl;
  String? supplierPhone;
  String? supplierAddress;

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
