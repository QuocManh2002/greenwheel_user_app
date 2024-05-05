import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/features/home/presentation/widgets/home_header.dart';
import 'package:greenwheel_user_app/features/home/presentation/widgets/hot_locations.dart';
import 'package:greenwheel_user_app/features/home/presentation/widgets/provinces.dart';
import 'package:greenwheel_user_app/features/home/presentation/widgets/trending_locations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            HomeHeader(),
            HotLocations(),
            TrendingLocations(),
            Provinces()
          ],
        ),
      ),
    ));
  }
}
