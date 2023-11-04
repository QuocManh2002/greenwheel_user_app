import 'dart:convert';

LocationViewModel provinceFromJson(String str) => LocationViewModel.fromJson(json.decode(str));

String provinceToJson(LocationViewModel data) => json.encode(data.toJson());

class LocationViewModel {
    int id;
    String description;
    String imageUrls;
    String name;
    List<String> activities;
    List<String> seasons;
    String topographic;
    String templatePlan;
    double latitude;
    double longitude;
    String address;
    String lifeguardPhone;
    String lifeguardAddress;
    String clinicPhone;
    String clinicAddress;
    String hotline;
    int provinceId;

    LocationViewModel({
        required this.id,
        required this.description,
        required this.imageUrls,
        required this.name,
        required this.activities,
        required this.seasons,
        required this.topographic,
        required this.templatePlan,
        required this.latitude,
        required this.longitude,
        required this.address,
        required this.lifeguardPhone,
        required this.lifeguardAddress,
        required this.clinicPhone,
        required this.clinicAddress,
        required this.hotline,
        required this.provinceId,
    });

    factory LocationViewModel.fromJson(Map<String, dynamic> json) => LocationViewModel(
        id: json["id"],
        description: json["description"],
        imageUrls: json["imageUrls"],
        name: json["name"],
        activities: List<String>.from(json["activities"].map((x) => x)),
        seasons: List<String>.from(json["seasons"].map((x) => x)),
        topographic: json["topographic"],
        templatePlan: json["templatePlan"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        address: json["address"],
        lifeguardPhone: json["lifeguardPhone"],
        lifeguardAddress: json["lifeguardAddress"],
        clinicPhone: json["clinicPhone"],
        clinicAddress: json["clinicAddress"],
        hotline: json["hotline"],
        provinceId: json["provinceId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "imageUrls": imageUrls,
        "name": name,
        "activities": List<dynamic>.from(activities.map((x) => x)),
        "seasons": List<dynamic>.from(seasons.map((x) => x)),
        "topographic": topographic,
        "templatePlan": templatePlan,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "lifeguardPhone": lifeguardPhone,
        "lifeguardAddress": lifeguardAddress,
        "clinicPhone": clinicPhone,
        "clinicAddress": clinicAddress,
        "hotline": hotline,
        "provinceId": provinceId,
    };
}