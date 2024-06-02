import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/features/home/business/entities/home_location_entity.dart';
import 'package:greenwheel_user_app/features/home/business/entities/home_province_entity.dart';
import 'package:greenwheel_user_app/features/home/business/usecases/get_home_location.dart';
import 'package:greenwheel_user_app/features/home/business/usecases/get_home_province.dart';
import 'package:greenwheel_user_app/features/home/business/usecases/get_home_trending_location.dart';
import 'package:greenwheel_user_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:greenwheel_user_app/features/home/data/repositories/home_repository_impl.dart';

class HomeProvider extends ChangeNotifier {
  List<HomeLocationEntity>? hotLocations = [];
  List<HomeProvinceEntity>? homeProvinces;
  List<HomeLocationEntity>? homeTrendingLocations;
  HomeProvider({
    this.hotLocations,
    this.homeProvinces,
  });

  String? cursorHotLocation;

  void getHotLocations() async {
    HomeRepositoryImpl repository =
        HomeRepositoryImpl(remoteDataSource: HomeRemoteDataSourceImpl());

    final hotLocation =
        await GetHomeLocations(repository).call(cursorHotLocation);
    if (hotLocation != null) {
      if (hotLocation.objects != null && hotLocation.objects!.isNotEmpty) {
        if (hotLocations == null || hotLocations!.isEmpty) {
          hotLocations = hotLocation.objects!;
        } else {
          hotLocations!.addAll(hotLocation.objects!);
        }
      }
      cursorHotLocation = hotLocation.cursor;
      notifyListeners();
    }
  }

  void getHomeProvinces() async {
    HomeRepositoryImpl repository =
        HomeRepositoryImpl(remoteDataSource: HomeRemoteDataSourceImpl());

    final homeProvince = await GetHomeProvinces(repository).call();
    if (homeProvince != null) {
      homeProvinces = homeProvince;
      notifyListeners();
    }
  }

  void getHomeTrendingLocations() async {
    HomeRepositoryImpl repository =
        HomeRepositoryImpl(remoteDataSource: HomeRemoteDataSourceImpl());
    final homeTrendingLocation =
        await GetHomeTrendingLocations(repository).call();
    if (homeTrendingLocation != null) {
      homeTrendingLocations = homeTrendingLocation;
      notifyListeners();
    }
  }
}
