import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';

class EmergencySupplier extends StatefulWidget {
  const EmergencySupplier({super.key, required this.supplier});
  final SupplierViewModel supplier;

  @override
  State<EmergencySupplier> createState() => _EmergencySupplierState();
}

class _EmergencySupplierState extends State<EmergencySupplier> {
  List<String>? serviceList = sharedPreferences.getStringList('serviceList');
  bool enableToAdd = true;

  @override
  void initState() {
    super.initState();
    if (serviceList != null) {
      if (serviceList!.any((element) => element == widget.supplier.id.toString())) {
        setState(() {
          enableToAdd = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết dịch vụ'),
      ),
      body: Column(children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              height: 30.h,
              width: double.infinity,
              child: Image.network(
                widget.supplier.thumbnailUrl!,
                fit: BoxFit.fitWidth,
                height: 30.h,
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 20.h),
                width: 90.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.black12,
                      offset: Offset(2, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                          top: 2.h, right: 2.h, left: 2.h, bottom: 1.h),
                      child: Text(
                        widget.supplier.name!,
                        style: const TextStyle(
                            fontSize: 23, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.h, vertical: 1.5.h),
                      child: Row(
                        children: [
                          Text(
                            widget.supplier.phone!,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                          left: 2.h, right: 2.h, top: 1.5.h, bottom: 2.h),
                      child: Text(
                        widget.supplier.address!,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54),
                      ),
                    ),
                  ],
                )),
          ],
        ),
        const Spacer(),
        if (enableToAdd)
          ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: () {
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    body: const Text(
                      'Thêm dịch vụ thành công',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    btnOkColor: primaryColor,
                    btnOkOnPress: () {
                      serviceList!.add(widget.supplier.id.toString());
                      sharedPreferences.setStringList(
                          'serviceList', serviceList!);
                      Navigator.of(context).pop();
                    }).show();
              },
              child: const Text(
                'Thêm dịch vụ',
                style: TextStyle(fontSize: 18),
              )),
        const SizedBox(
          height: 32,
        ),
      ]),
    ));
  }
}
