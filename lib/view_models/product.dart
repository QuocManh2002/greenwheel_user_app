class ProductViewModel {
  int id;
  String name;
  double price;
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
          price: json["price"].toDouble(),
          thumbnailUrl: json["imagePath"],
          supplierId: json["provider"]["id"],
          supplierName: json["provider"]["name"],
          partySize: json["partySize"],
          supplierThumbnailUrl: json['provider']['imagePath'],
          supplierPhone: json['provider']['phone'],
          supplierType: json['provider']['type'],
          supplierAddress: json['provider']['address']);

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
