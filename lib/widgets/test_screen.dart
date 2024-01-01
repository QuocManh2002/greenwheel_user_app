import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:sizer2/sizer2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getData() async {}

  saveData() async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white.withOpacity(0.94),
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Colors.purple,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Ngày đặt: ',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '10/3/2023',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: primaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Ngày phục vụ: ',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '10/3/2023',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: yellowColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Ghi chú:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        height: 10.h,
                        margin: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 1.h),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              10.0), // Set the border radius
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        child: TextField(
                          controller: noteController,
                          maxLines: null, // Allow for multiple lines of text
                          decoration: const InputDecoration(
                            hintText: 'Thêm ghi chú',
                            border:
                                InputBorder.none, // Remove the bottom border
                            contentPadding:
                                EdgeInsets.all(8.0), // Set the padding
                          ),
                          style: const TextStyle(
                            height:
                                1.8, // Adjust the line height (e.g., 1.5 for 1.5 times the font size)
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        height: 0.5.h,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        'Sản phẩm',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              '1x',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 18,),
                            Text('Phong doi (VIP)', style: TextStyle(
                              fontSize: 18
                            ),),
                            Spacer(),
                            Text('40.000', style: TextStyle(
                              fontSize: 14
                            ),)
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        height: 0.2.h,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              '1x',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 18,),
                            Text('Phong doi (VIP)', style: TextStyle(
                              fontSize: 18
                            ),),
                            Spacer(),
                            Text('40.000', style: TextStyle(
                              fontSize: 14
                            ),)
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        height: 0.2.h,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              '1x',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 18,),
                            Text('Phong doi (VIP)', style: TextStyle(
                              fontSize: 18
                            ),),
                            Spacer(),
                            Text('40.000', style: TextStyle(
                              fontSize: 14
                            ),)
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        height: 0.2.h,
                      ),
                      const SizedBox(height: 12,),
                      const Row(children: [
                         Text('Tổng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                         Spacer(),
                         Text('120.000', style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                         ),)
                      ],)
                    ]),
              ),
            )));
  }
}
