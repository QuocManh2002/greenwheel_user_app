import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/service/notification_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:greenwheel_user_app/widgets/test_screen_date.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer2/sizer2.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final CarouselController carouselController = CarouselController();
  int currentImageIndex = 0;
  bool isLoading = true;
  List<dynamic> imageUrls = [];
  List<LocationViewModel>? locationModels;
  String data = 'Quoc Manh';
  final GlobalKey qrkey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/emulated/0/Download/QR_Code';
  NotificationService _notificationService = NotificationService();
  List<List<Room>> _listResult = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _notificationService.requestNotificationPermission();
    // _notificationService.firebaseInit(context);
    // _notificationService.setupInteractMessage(context);
    setUpData();
  }

  setUpData() {
    List<Room> rooms = [
      Room(id: 1, price: 700, size: 1),
      Room(id: 2, price: 1000, size: 2),
      Room(id: 3, price: 500, size: 1),
      Room(id: 4, price: 800, size: 2),
    ];
    findSumCombinations(rooms, 5);
    print(_listResult.length);
    List<Room> rs = getResult(_listResult);
    print(rs);
  }

  
    

    

    // _listResult = listResult;
  

  void findSumCombinations(List<Room> roomList, int targetSum,
      {List<Room> combination = const [], int startIndex = 0}) {
    int currentSum = 0;
    combination.forEach((element) => currentSum += element.size);
    if (currentSum == targetSum) {
      _listResult.add(combination);
      return;
    }

    if (currentSum > targetSum) {
      return;
    }

    for (int i = startIndex; i < roomList.length; i++) {
      List<Room> newCombination = List.from(combination)..add(roomList[i]);
      findSumCombinations(roomList, targetSum,
          combination: newCombination, startIndex: i);
    }
  }

  List<Room> getResult(List<List<Room>> list) {
    List<Room> listRoomsCheapest = [];
    double minPriceRooms = 0;
    list[0].forEach((element) {
      minPriceRooms += element.price;
    });
    for (final rooms in list) {
      double price = 0;
      rooms.forEach((element) {
        price += element.price;
      });
      if (price <= minPriceRooms) {
        minPriceRooms = price;
        listRoomsCheapest = rooms;
      }
    }
    return listRoomsCheapest;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
      child: ElevatedButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => TestScreenDate())),
        child: Text("chon ngay"),
      ),
    )));
  }
}

class Room {
  final int id;
  final int size;
  final double price;
  const Room({required this.id, required this.price, required this.size});
}
