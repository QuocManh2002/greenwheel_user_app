import 'package:greenwheel_user_app/features/home/business/entities/home_location_entity.dart';
import 'package:greenwheel_user_app/features/home/business/repositories/home_repository.dart';

class GetHomeLocations {
  final HomeRepository repository;

  GetHomeLocations(this.repository);

  Future<List<HomeLocationEntity>?> call() async {
    return await repository.getLocations();
  }
}