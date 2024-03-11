class SupplierViewModel {
  int id;
  String? name;
  String? phone;
  String? thumbnailUrl;
  String? address;
  double? longitude;
  double? latitude;

  SupplierViewModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.thumbnailUrl,
    required this.address,
    this.longitude,
    this.latitude,
  });

  factory SupplierViewModel.fromJson(Map<String, dynamic> json) =>
      SupplierViewModel(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        thumbnailUrl: json["imageUrl"],
        address: json["address"],
        latitude: json["coordinate"]["coordinates"][1],
        longitude: json["coordinate"]["coordinates"][0],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "thumbnailUrl": thumbnailUrl,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      };
}
