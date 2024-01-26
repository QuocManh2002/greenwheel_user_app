import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:greenwheel_user_app/widgets/test_screen1.dart';
import 'package:sizer2/sizer2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Widget activeWidget = Text('111');

  onPress() {
    setState(() {
      activeWidget = Center(child: CircularProgressIndicator());
    });
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => TestScreen1()));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activeWidget = Center(
        child: ElevatedButton(onPressed: onPress, child: Text('Change page')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(appBar: AppBar(), body: activeWidget));
  }
}
