import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer2/sizer2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool isLoading = false;

  List<DateTime> selectedList = [];
  DateTime? selectValue = DateTime(0, 0, 0, 1, 0, 0);
  Duration? totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
    List<int> list = [1, 2, 3, 4, 5];
    print(list.sublist(0,7).fold(
        0,
        (previousValue, element) =>
            int.parse(previousValue.toString()) + element));
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
                          InkWell(
                            child: const Text('pick time'),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        content: SizedBox(
                                          width: 100.w,
                                          height: 15.h,
                                          child: CupertinoDatePicker(
                                            use24hFormat: true,
                                            onDateTimeChanged: (value) {
                                              selectValue = value;
                                            },
                                            initialDateTime:
                                                DateTime(0, 0, 0, 1, 0, 0),
                                            mode: CupertinoDatePickerMode.time,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                selectedList.add(selectValue!);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Chọn"))
                                        ],
                                      ));
                            },
                          ),
                          InkWell(
                            child: const Text('print total duration'),
                            onTap: () {
                              totalDuration = selectedList.fold(Duration.zero,
                                  (previousValue, element) {
                                {
                                  return previousValue! +
                                      Duration(
                                          hours: element.hour,
                                          minutes: element.minute);
                                }
                              });

                              print(totalDuration!
                                  .compareTo(Duration(hours: 16)));

                              print(
                                  '${totalDuration!.inHours} ${totalDuration!.inMinutes.remainder(60)}');
                            },
                          )
                        ],
                      ))));
  }
}
