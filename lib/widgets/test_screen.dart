
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/service/order_service.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:intl/intl.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool isLoading = false;



  @override
  void initState() {
    super.initState();
  }

  setUpData() async {

    final date = DateTime(2024,10,10, 8,6,22);

    print(DateFormat('HH:mm dd/MM/yyyy').format(date));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
                child: isLoading
                    ? const Center(
                        child: Text('Loading...'),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: (){
                            setUpData();
                          }, child: Text('lay ket qua'))
                        ],
                      ))));
  }
}
