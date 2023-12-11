import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // setUpData() {
  //   // List<List<Room>> rs = [];
  //   List<List<Room>> listResult = [];

  //   findCheapestRooms(5, listResult);
  //   List<Room> rss = getResult(listResult);
  //   print(rss);
  // }

  // void findCheapestRooms(int numberOfMember, List<List<Room>> listResult) {
  //   List<Room> rooms = [
  //     Room(id: 1, price: 500, size: 1),
  //     Room(id: 2, price: 800, size: 2),
  //     Room(id: 3, price: 700, size: 1),
  //     Room(id: 4, price: 1000, size: 2),
  //   ];

  //   findSumCombination(rooms, numberOfMember, 0, [], listResult);
  // }

  // void findSumCombination(List<Room> roomList, int target, int startIndex,
  //     List<Room> combinations, List<List<Room>> listResult) {
  //   if (target == 0) {
  //     double price = 0;
  //     combinations.forEach(
  //       (element) => price += element.price,
  //     );
  //     listResult.add(combinations);
  //     return;
  //   }
  //   for (int i = startIndex; i < roomList.length; i++) {
  //     if (roomList[i].size <= target) {
  //       combinations.add(roomList[i]);
  //       findSumCombination(
  //           roomList, target - roomList[i].size, i, combinations, listResult);
  //       combinations.removeLast();
  //     }
  //   }
  // }

  // List<Room> getResult(List<List<Room>> list) {
  //   List<Room> listRoomsCheapest = [];
  //   double minPriceRooms = 0;
  //   list[0].forEach((element) {
  //     minPriceRooms += element.price;
  //   });
  //   for (final rooms in list) {
  //     double price = 0;
  //     rooms.forEach((element) {
  //       price += element.price;
  //     });
  //     if (price <= minPriceRooms) {
  //       minPriceRooms = price;
  //       listRoomsCheapest = rooms;
  //     }
  //   }
  //   return listRoomsCheapest;
  // }

  DateTime selectedDate = DateTime.now();

  void _showDatePicker(BuildContext context) async {
    
    DateTime? newDay = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2024),
        builder: (context, child) {
          return Theme(
            data: ThemeData().copyWith(
                colorScheme: const ColorScheme.light(
                    primary: primaryColor, onPrimary: Colors.white)),
            child: DatePickerDialog(
              
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2024),
            ),
          );
        });
    if (newDay != null) {
      setState(() {
        selectedDate = newDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => TestScreenDate())),
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
