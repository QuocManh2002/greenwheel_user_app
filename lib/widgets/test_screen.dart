import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:sizer2/sizer2.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("Test Screen")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for(int i = 0; i < 10; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(height: 10.h,color: redColor,),
                    )
                ],
              ),
            ),
          ),
          
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 7.h,
                child: ElevatedButton(
                  onPressed: (){},
                  child: Text("Button"),
                  style: elevatedButtonStyle,
                ),
              ),
            
          )
        ],
      ),
    ));
  }
}
