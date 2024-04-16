import 'package:greenwheel_user_app/features/home/business/entities/home_location_entity.dart';
import 'package:greenwheel_user_app/features/home/business/entities/home_province_entity.dart';

abstract class HomeRepository {
  Future<List<HomeLocationEntity>?> getHotLocations();
  Future<List<HomeLocationEntity>?> getTrendingLocations();
  Future<List<HomeProvinceEntity>?> getProvinces();
}