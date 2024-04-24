import 'package:greenwheel_user_app/features/home/business/entities/home_location_entity.dart';
import 'package:greenwheel_user_app/features/home/business/entities/home_province_entity.dart';
import 'package:greenwheel_user_app/models/pagination.dart';

abstract class HomeRepository {
  // Future<List<HomeLocationEntity>?> getHotLocations(String? cursor);
  Future<Pagination<HomeLocationEntity>?> getHotLocations(String? cursor);

  Future<List<HomeLocationEntity>?> getTrendingLocations();
  Future<List<HomeProvinceEntity>?> getProvinces();
}