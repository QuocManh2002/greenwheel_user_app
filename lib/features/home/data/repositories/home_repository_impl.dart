import 'package:greenwheel_user_app/features/home/business/entities/home_location_entity.dart';
import 'package:greenwheel_user_app/features/home/business/repositories/home_repository.dart';
import 'package:greenwheel_user_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_location_model.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_provinces_model.dart';
import 'package:greenwheel_user_app/models/pagination.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Pagination<HomeLocationModel>?> getHotLocations(String? cursor) async {

    final remoteHomeLocations = await remoteDataSource.getHotLocations(cursor);
    return remoteHomeLocations;
  }

  @override
  Future<List<HomeProvinceModel>?> getProvinces() async {
    // TODO: implement getProvinces
    final remoteHomeProvinces = await remoteDataSource.getProvinces();
    return remoteHomeProvinces;
  }

  @override
  Future<List<HomeLocationEntity>?> getTrendingLocations() async {
    final remoteHomeTrendingLocations =
        await remoteDataSource.getTrendingLocations();
    return remoteHomeTrendingLocations;
  }
}
