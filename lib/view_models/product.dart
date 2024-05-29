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
  bool? supplierIsActive;
  bool? isAvailable;

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
      this.isAvailable,
      this.supplierIsActive,
      this.supplierAddress});

  factory ProductViewModel.fromJson(Map<String, dynamic> json) =>
      ProductViewModel(
          id: json["id"],
          name: json["name"],
          isAvailable: json['isAvailable'],
          price: json["price"].toDouble(),
          thumbnailUrl: json["imagePath"],
          supplierId: json["provider"]["id"],
          supplierName: json["provider"]["name"],
          partySize: json["partySize"],
          supplierThumbnailUrl: json['provider']['imagePath'],
          supplierPhone: json['provider']['phone'],
          supplierType: json['provider']['type'],
          supplierIsActive: json['provider']['isActive'],
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
