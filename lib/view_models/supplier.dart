class SupplierViewModel {
  int id;
  bool isHidden;
  String name;
  String phone;
  String thumbnailUrl;
  double longitude;
  double latitude;

  SupplierViewModel({
    required this.id,
    required this.isHidden,
    required this.name,
    required this.phone,
    required this.thumbnailUrl,
    required this.longitude,
    required this.latitude,
  });

  factory SupplierViewModel.fromJson(Map<String, dynamic> json) =>
      SupplierViewModel(
        id: json["id"],
        isHidden: json["isHidden"],
        name: json["name"],
        phone: json["phone"],
        thumbnailUrl: json["thumbnailUrl"],
        latitude: json["coordinate"]["coordinates"][1],
        longitude: json["coordinate"]["coordinates"][0],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isHidden": isHidden,
        "name": name,
        "phone": phone,
        "thumbnailUrl": thumbnailUrl,
        "latitude": latitude,
        "longitude": longitude,
      };
}
