class SupplierViewModel {
  int id;
  bool isHidden;
  String name;
  String phone;
  String thumbnailUrl;

  SupplierViewModel({
    required this.id,
    required this.isHidden,
    required this.name,
    required this.phone,
    required this.thumbnailUrl,
  });

  factory SupplierViewModel.fromJson(Map<String, dynamic> json) =>
      SupplierViewModel(
        id: json["id"],
        isHidden: json["isHidden"],
        name: json["name"],
        phone: json["phone"],
        thumbnailUrl: json["thumbnailUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isHidden": isHidden,
        "name": name,
        "phone": phone,
        "thumbnailUrl": thumbnailUrl,
      };
}
