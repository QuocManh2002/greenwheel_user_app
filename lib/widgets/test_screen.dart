import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer2/sizer2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool isLoading = false;

  List<List<int>> updatedOrderIndex = [];
  List<List<int>> canceledOrderIndex = [];

  List<List<int>> orderIndexList = [
    [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
    ],
    [0, 1, 3, 4, 6],
    [4, 5, 6]
  ];

  List<DateTime> input = [
    DateTime(2024, 5, 6),
    DateTime(2024, 5, 7),
    DateTime(2024, 5, 9),
    DateTime(2024, 5, 11),
    DateTime(2024, 5, 12),
    DateTime(2024, 5, 13),
    DateTime(2024, 5, 16),
  ];

  List<List<DateTime>> output = [];

  int newDuration = 3;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    List<DateTime> current = [input[0]];
    for (int i = 1; i < input.length; i++) {
      DateTime previousDateTime = input[i - 1];
      DateTime currentDateTime = input[i];
      if (currentDateTime.difference(previousDateTime).inDays == 1) {
        current.add(currentDateTime);
      } else {
        output.add(current);
        current = [currentDateTime];
      }
    }
    output.add(current);
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
                        children: [],
                      ))));
  }
}
