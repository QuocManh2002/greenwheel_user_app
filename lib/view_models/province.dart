import 'dart:convert';

ProvinceViewModel provinceFromJson(String str) => ProvinceViewModel.fromJson(json.decode(str));

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
        thumbnailUrl: json["imagePath"],
    );
}