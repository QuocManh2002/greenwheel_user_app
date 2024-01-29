import 'dart:convert';

ProvinceViewModel provinceFromJson(String str) => ProvinceViewModel.fromJson(json.decode(str));

String provinceToJson(ProvinceViewModel data) => json.encode(data.toJson());

class ProvinceViewModel {
    int id;
    String name;
    String thumbnailUrl;

    ProvinceViewModel({
        required this.id,
        required this.name,
        required this.thumbnailUrl,
    });

    factory ProvinceViewModel.fromJson(Map<String, dynamic> json) => ProvinceViewModel(
        id: json["id"],
        name: json["name"],
        thumbnailUrl: json["imageUrl"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "thumbnailUrl": thumbnailUrl,
    };
}