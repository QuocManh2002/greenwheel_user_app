import 'package:phuot_app/features/home/business/entities/home_location_entity.dart';
import 'package:phuot_app/features/home/business/repositories/home_repository.dart';
import 'package:phuot_app/models/pagination.dart';

class GetHomeLocations {
  final HomeRepository repository;

  GetHomeLocations(this.repository);

  // Future<List<HomeLocationEntity>?> call(String? cursor) async {
  //   return await repository.getHotLocations(cursor);
  // }
  Future<Pagination<HomeLocationEntity>?> call(String? cursor) async {
    return await repository.getHotLocations(cursor);
  }
}