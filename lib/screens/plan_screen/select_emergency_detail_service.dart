import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class SelectEmergencyDetailService extends StatefulWidget {
  const SelectEmergencyDetailService(
      {super.key,
      required this.emergency,
      required this.index,
      required this.isView,
      required this.callback});

  final EmergencyContactViewModel emergency;
  final int index;
  final void Function() callback;
  final bool isView;

  @override
  State<SelectEmergencyDetailService> createState() =>
      _SelectEmergencyDetailServiceState();
}

class _SelectEmergencyDetailServiceState
    extends State<SelectEmergencyDetailService> {
  @override
  Widget build(BuildContext context) {
    List<String>? selectedIndex =
      sharedPreferences.getStringList('selectedIndex');
  var isEnableToAdd = false;
  if(selectedIndex != null){
    isEnableToAdd = selectedIndex.any(
    (element) => element == widget.index.toString(),
  );
  }
   
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết dịch vụ', style: TextStyle(
                color: Colors.white
              ),),
              leading: BackButton(
                style:const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.white)
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if(!widget.isView){
                    widget.callback();
                  }
                },
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: FadeInImage(
                    height: 25.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: const NetworkImage(
                        "https://vantaihoangminh.com/wp-content/uploads/2021/05/d%E1%BB%8Bch-v%E1%BB%A5-xe-c%E1%BB%A9u-h%E1%BB%99-giao-th%C3%B4ng-v%E1%BA%ADn-t%E1%BA%A3i-ho%C3%A0ng-minh2.jpg"),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.h, right: 1.h),
                  child: Text(
                    widget.emergency.name!,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.h, right: 2.h),
                  child: Row(
                    children: [
                      const Text(
                        'Số điện thoại: ',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '0${widget.emergency.phone!.substring(3)}',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      const Spacer(),
                      IconButton(onPressed: ()async{ 
                        await FlutterPhoneDirectCaller.callNumber('0${widget.emergency.phone!.substring(3)}');
                      }, icon:const Icon(Icons.call, color: primaryColor, size: 32,))
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.h, right: 1.h),
                  child: RichText(
                      overflow: TextOverflow.clip,
                      text: TextSpan(
                          text: 'Địa chỉ: ',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: widget.emergency.address ?? 'Không có địa chỉ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal))
                          ])),
                ),
                const Spacer(),
                if (!isEnableToAdd && !widget.isView)
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                        style: elevatedButtonStyle,
                        onPressed: () {
                          selectedIndex!.add(widget.index.toString());
                          sharedPreferences.setStringList(
                              'selectedIndex', selectedIndex);
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            body: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.h),
                              child: const Center(
                                child: Text(
                                  'Lưu thông tin dịch vụ thành công',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            btnOkColor: primaryColor,
                            btnOkOnPress: () {
                              
                              setState(() {
                                isEnableToAdd == true;
                              });
                              widget.callback();
                              Navigator.of(context).pop();

                            },
                          ).show();
                        },
                        child: const Text(
                          'Lưu dịch vụ',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                  ),
                SizedBox(
                  height: 3.h,
                )
              ],
            )));
  }
}
