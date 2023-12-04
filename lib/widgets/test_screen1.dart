import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class TestScreen1 extends StatelessWidget {
  const TestScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("App bar"),
          leading: BackButton(
            onPressed: (){
              AwesomeDialog(context: context,
              dialogType: DialogType.warning,
              body: Text("Hello, its me"),
              btnOkOnPress: () {
                Navigator.of(context).pop();
              },
              ).show();
            },
          ),
        ),
        body: Center(
          child: Text('Page'),
        ),
        ));
  }
}