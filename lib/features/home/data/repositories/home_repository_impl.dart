
import 'package:greenwheel_user_app/features/home/business/repositories/home_repository.dart';
import 'package:greenwheel_user_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_location_model.dart';
import 'package:greenwheel_user_app/features/home/data/models/home_provinces_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HomeLocationModel>?> getLocations() async{
    // TODO: implement getLocations
    
    final remoteHomeLocations = await remoteDataSource.getLocations();
    return remoteHomeLocations;
  }

  @override
  Future<List<HomeProvinceModel>?> getProvinces() async{
    // TODO: implement getProvinces
    final remoteHomeProvinces = await remoteDataSource.getProvinces();
    return remoteHomeProvinces;
  }
}
