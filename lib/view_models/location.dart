
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/province.dart';

class LocationViewModel {
  int id;
  String description;
  List<dynamic> imageUrls;
  String name;
  List<String> activities;
  List<String> seasons;
  String topographic;
  List<dynamic> templatePlan;
  double latitude;
  double longitude;
  String address;
  String? lifeguardPhone;
  String? lifeguardAddress;
  String? clinicPhone;
  String? clinicAddress;
  String hotline;
  ProvinceViewModel province;
  int suggestedTripLength;
  List<EmergencyContactViewModel>? emergencyContacts;
  List<dynamic>? templateEvents;

  LocationViewModel(
      {required this.id,
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
      this.lifeguardPhone,
      this.lifeguardAddress,
      this.clinicPhone,
      this.clinicAddress,
      required this.hotline,
      required this.province,
      required this.suggestedTripLength,
      this.emergencyContacts,
      this.templateEvents});

  factory LocationViewModel.fromJson(Map<String, dynamic> json) =>
      LocationViewModel(
          id: json["id"],
          description: json["description"],
          imageUrls: json["imageUrls"],
          name: json["name"],
          activities: List<String>.from(json["activities"].map((x) => x)),
          seasons: List<String>.from(json["seasons"].map((x) => x)),
          topographic: json["topographic"],
          templatePlan: json["templateSchedule"],
          latitude: json["coordinate"]["coordinates"][1].toDouble(),
          longitude: json["coordinate"]["coordinates"][0].toDouble(),
          address: json["address"],
          lifeguardPhone: json["lifeguardPhone"],
          lifeguardAddress: json["lifeguardAddress"],
          clinicPhone: json["clinicPhone"],
          clinicAddress: json["clinicAddress"],
          hotline: json["hotline"],
          suggestedTripLength:
              List<dynamic>.from(json['templateSchedule'].map((x) => x)).length,
          province: ProvinceViewModel.fromJson(json["province"]),
          emergencyContacts: List<EmergencyContactViewModel>.from(json['emergencyContacts'].map((e) => EmergencyContactViewModel.fromJsonByLocation(e))).toList(),
          templateEvents: json['templateEvents']);

}
