
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
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
  double latitude;
  double longitude;
  String address;
  ProvinceViewModel province;
  int? suggestedTripLength;
  List<EmergencyContactViewModel>? emergencyContacts;
  List<CommentViewModel>? comments;

  LocationViewModel(
      {required this.id,
      required this.description,
      required this.imageUrls,
      required this.name,
      required this.activities,
      required this.seasons,
      required this.topographic,
      required this.latitude,
      required this.longitude,
      required this.address,
      required this.province,
      this.comments,
      this.suggestedTripLength,
      this.emergencyContacts,});

  factory LocationViewModel.fromJson(Map<String, dynamic> json) =>
      LocationViewModel(
          id: json["id"],
          description: json["description"],
          imageUrls: json["imageUrls"],
          name: json["name"],
          activities: List<String>.from(json["activities"].map((x) => x)),
          seasons: List<String>.from(json["seasons"].map((x) => x)),
          topographic: json["topographic"],
          latitude: json["coordinate"]["coordinates"][1].toDouble(),
          longitude: json["coordinate"]["coordinates"][0].toDouble(),
          address: json["address"],
          suggestedTripLength:1,
          province: ProvinceViewModel.fromJson(json["province"]),
          comments: List<CommentViewModel>.from(json['comments'].map((e) => CommentViewModel.fromJson(e))).toList(),
          emergencyContacts: List<EmergencyContactViewModel>.from(json['emergencyContacts'].map((e) => EmergencyContactViewModel.fromJsonByLocation(e))).toList(),);
}
