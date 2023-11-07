class SupplierViewModel {
  int id;
  String name;
  String phone;
  String thumbnailUrl;
  String address;
  String type;
  double longitude;
  double latitude;

  SupplierViewModel(
      {required this.id,
      required this.name,
      required this.phone,
      required this.thumbnailUrl,
      required this.address,
      required this.longitude,
      required this.latitude,
      required this.type});

  factory SupplierViewModel.fromJson(Map<String, dynamic> json) =>
      SupplierViewModel(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        thumbnailUrl: json["thumbnailUrl"],
        address: json["address"],
        type: json["type"],
        latitude: json["coordinate"]["coordinates"][1],
        longitude: json["coordinate"]["coordinates"][0],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "thumbnailUrl": thumbnailUrl,
        "address": address,
        "type": type,
        "latitude": latitude,
        "longitude": longitude,
      };
}
