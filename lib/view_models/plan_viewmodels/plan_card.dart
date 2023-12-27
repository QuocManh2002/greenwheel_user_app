import 'dart:convert';

PlanCardViewModel planCardFromJson(String str) => PlanCardViewModel.fromJson(json.decode(str));

String planCardToJson(PlanCardViewModel data) => json.encode(data.toJson());

class PlanCardViewModel {
    int id;
    String name;
    DateTime startDate;
    DateTime endDate;
    String locationName;
    List<dynamic> imageUrls;
    String provinceName;
    String status;

    PlanCardViewModel({
        required this.id,
        required this.startDate,
        required this.endDate,
        required this.locationName,
        required this.imageUrls,
        required this.provinceName,
        required this.status,
        required this.name
    });

    factory PlanCardViewModel.fromJson(Map<String, dynamic> json) => PlanCardViewModel(
        id: json["id"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        locationName: json["location"]['name'],
        imageUrls: json["location"]["imageUrls"],
        provinceName: json["location"]["province"]["name"],
        status: json["status"],
        name: json["name"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "locationName": locationName,
        "imageUrls": imageUrls,
        "provinceName": provinceName,
    };
}