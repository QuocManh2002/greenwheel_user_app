
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/service/offline_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_offline_member.dart';
import 'package:greenwheel_user_app/widgets/style_widget/util.dart';
import 'package:http/http.dart' as http;

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String bytes = '';
  OfflineService _offlineService = OfflineService();
  List<Map<String, dynamic>> planList = [];
  PlanService _planService = PlanService();

  Future<Uint8List> fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image: $imageUrl');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getData() async {
    // const imageUrl =
    //     'https://cdn.tgdd.vn/2023/11/content/image--9--800x450.jpg'; // Replace with the actual image URL

    // final imageBytes = await fetchImageBytes(imageUrl);
    // setState(() {
    //   bytes = base64Encode(imageBytes);
    // });
    final list = await _offlineService.getOfflinePlans();
    // if (list.isNotEmpty) {
    //   setState(() {
    //     planList = list;
    //   });
    // }

    // print(base64String);
    // final decodedBytes = base64Decode(base64String);
  }

  // refreshData(){
  //   final data =
  // }

  saveData() async {
    _offlineService.savePlanToHive(PlanOfflineViewModel(
        id: 1,
        name: 'Chuyen di test',
        imageBase64: await Utils().getImageBase64Encoded(
            'https://cdn.tgdd.vn/2023/11/content/image--9--800x450.jpg'),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        memberLimit: 3,
        schedule: [],
        orders: [],
        memberList: [
          PlanOfflineMember(
              id: 1, name: 'Manh', phone: '0383519580', isLeading: true),
          PlanOfflineMember(
              id: 2, name: 'Thinh', phone: '0123456789', isLeading: false)
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(onPressed: saveData, child: const Text('Save Data')),
          const SizedBox(
            height: 32,
          ),
          ElevatedButton(onPressed: getData, child: const Text('Get Data')),
          for (final plan in planList)
            Container(
              child: Column(children: [
                Text(plan['name']),
                Text(plan['startDate']),
                Text(plan['endDate']),
                Text(plan['memberLimit']),
                Text(plan['imgUrl'])
              ]),
            )
        ],
      ),
    ));
  }
}
