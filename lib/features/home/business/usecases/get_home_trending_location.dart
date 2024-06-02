import 'package:phuot_app/features/home/business/entities/home_location_entity.dart';
import 'package:phuot_app/features/home/business/repositories/home_repository.dart';

class GetHomeTrendingLocations {
  final HomeRepository repository;

  GetHomeTrendingLocations(this.repository);

  Future<List<HomeLocationEntity>?> call() async {
    return await repository.getTrendingLocations();
  }
}