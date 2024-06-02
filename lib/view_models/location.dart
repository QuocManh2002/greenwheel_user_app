
import 'package:phuot_app/view_models/location_viewmodels/comment.dart';
import 'package:phuot_app/view_models/province.dart';

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
  List<CommentViewModel>? comments;
  int? rating;

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
      this.rating,});

  factory LocationViewModel.fromJson(Map<String, dynamic> json) =>
      LocationViewModel(
          id: json["id"],
          description: json["description"],
          imageUrls: json["imagePaths"],
          name: json["name"],
          activities: List<String>.from(json["activities"].map((x) => x)),
          seasons: List<String>.from(json["seasons"].map((x) => x)),
          topographic: json["topographic"],
          latitude: json["coordinate"]["coordinates"][1].toDouble(),
          longitude: json["coordinate"]["coordinates"][0].toDouble(),
          address: json["address"],
          rating: json['rating'],
          province: ProvinceViewModel.fromJson(json["province"]),
          comments: List<CommentViewModel>.from( (json['comments'] ?? []).map((e) => CommentViewModel.fromJson(e))).toList(),
          );
}
