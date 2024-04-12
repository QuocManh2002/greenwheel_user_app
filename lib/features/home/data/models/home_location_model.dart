import 'package:greenwheel_user_app/features/home/business/entities/home_location_entity.dart';

class HomeLocationModel extends HomeLocationEntity {
  // int id;
  // String name;
  // String description;
  // List<dynamic> imagePaths;
  // int rating;

  HomeLocationModel(
      {required String description,
      required int id,
      required String name,
      required List<dynamic> imagePaths,
      required int rating})
      : super(
            description: description,
            id: id,
            imagePaths: imagePaths,
            name: name,
            rating: rating);

  factory HomeLocationModel.fromJson(Map<String, dynamic> json) =>
      HomeLocationModel(
          id: json['id'],
          name: json['name'],
          description: json['description'],
          imagePaths: json['imagePaths'],
          rating: json['rating'] ?? 0);
}
