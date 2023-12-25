import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:hive/hive.dart';

class OfflineHomeScreen extends StatefulWidget {
  const OfflineHomeScreen({super.key});

  @override
  State<OfflineHomeScreen> createState() => _OfflineHomeScreenState();
}

class _OfflineHomeScreenState extends State<OfflineHomeScreen> {
  final _myplans = Hive.box('myplans');
  bool isShow = false;

  write() async {
    _myplans.put('1', 'Nguyen Quoc Manh');

    final image = File('image_plan/image1.jpg');

    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    _myplans.put('image', base64Image);
  }

  read() {
    print(_myplans.get('1'));
    final base64Image = _myplans.get('image');
    print(base64Image);
  }

  delete() {
    _myplans.delete('1');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveImage();
  }

  saveImage() async {
    const fileImagePath = 'image_plan/image1.jpg';

    final byteData = await rootBundle.load(empty_plan);
    final bytes = byteData.buffer.asUint8List();

    final file = File(fileImagePath);
    await file.writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white.withOpacity(0.94),
      appBar: AppBar(
        title: const Text('Kế hoạch của bạn'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          ElevatedButton(onPressed: write, child: Text('write')),
          ElevatedButton(onPressed: read, child: Text('read')),
          ElevatedButton(onPressed: delete, child: Text('delete'))
        ],
      )),
    ));
  }
}
