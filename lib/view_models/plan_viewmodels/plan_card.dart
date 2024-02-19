
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/province.dart';

class PlanCardViewModel {
    int id;
    String? name;
    DateTime startDate;
    DateTime endDate;
    String status;
    LocationViewModel location;
    ProvinceViewModel province;

    PlanCardViewModel({
        required this.id,
        required this.startDate,
        required this.endDate,
        required this.location,
        required this.province,
        required this.status,
        this.name
    });

    factory PlanCardViewModel.fromJson(Map<String, dynamic> json) => PlanCardViewModel(
        id: json["id"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        location: LocationViewModel.fromJson(json["destination"]),
        province: ProvinceViewModel.fromJson(json["destination"]["province"]),
        status: json["status"],
        name: json["name"]
    );

}