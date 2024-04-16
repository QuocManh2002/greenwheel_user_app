import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/pdf_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/holiday.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/create_note_surcharge_screen.dart';
import 'package:greenwheel_user_app/service/config_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/province.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sizer2/sizer2.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<int> list = [1];
  bool isLongTap = false;

  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(builder: (context) => _buildOverlay());
  }

  @override
  void dispose() {
    _overlayEntry.dispose();
    super.dispose();
  }

  Widget _buildOverlay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Positioned(
          top: 20,
          bottom: 0,
          right: 0,
          left: 0,
          child: ElevatedButton(
            onPressed: () {
              print('Button Above Pressed');
            },
            child: Text('Button Above'),
          ),
        ),
        SizedBox(height: 3.h,),
        ElevatedButton(
          onPressed: () {
            print('Button Below Pressed');
          },
          child: Text('Button Below'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final num in list)
                  GestureDetector(
                    onLongPress: () {
                      setState(() {
                        isLongTap = true;
                      });
                      Overlay.of(context).insert(_overlayEntry);
                    },
                    onLongPressEnd: (_) {
                      setState(() {
                        isLongTap = false;
                      });
                      _overlayEntry.remove();
                    },
                    child: Container(
                      width: 80.w,
                      height: 10.w,
                      alignment: Alignment.center,
                      decoration:
                          const BoxDecoration(color: lightPrimaryTextColor),
                      child: Text(
                        num.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            )));
  }
}
