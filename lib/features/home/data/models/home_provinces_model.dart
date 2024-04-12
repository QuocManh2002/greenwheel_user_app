import 'package:greenwheel_user_app/features/home/business/entities/home_province_entity.dart';

class HomeProvinceModel extends HomeProvinceEntity{
   HomeProvinceModel({
    required int id,
    required String name,
    required String imagePath
  }):super(
    id:  id,
    name: name,
    imagePath: imagePath
  );

  factory HomeProvinceModel.fromJson(Map<String, dynamic> json) =>
    HomeProvinceModel(
      id: json['id'], 
      name: json['name'], 
      imagePath: json['imagePath']);
}