import 'package:phuot_app/features/home/business/entities/home_province_entity.dart';
import 'package:phuot_app/features/home/business/repositories/home_repository.dart';

class GetHomeProvinces{
  final HomeRepository repository;

  GetHomeProvinces(this.repository);

  Future<List<HomeProvinceEntity>?> call() async {
    return await repository.getProvinces();
  }
}