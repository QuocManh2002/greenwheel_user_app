

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

  List<DateTime> selectedList = [];
  DateTime? selectValue = DateTime(0, 0, 0, 1, 0, 0);
  Duration? totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    setUpData();
  }

  setUpData() async {
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
                            },
                          )
                        ],
                      ))));
  }
}
