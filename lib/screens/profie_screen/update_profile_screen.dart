import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/select_default_address.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer2/sizer2.dart';
import 'package:http/http.dart' as http;

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key, required this.traveler});
  final CustomerViewModel traveler;

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  XFile? myImage;
  String avatarLink = defaultUserAvatarLink;
  final CustomerService _customerService = CustomerService();

  bool isMale = true;
  PointLatLng? _selectedAddressLatLng;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () async{
              final defaultCoordinate = sharedPreferences.getStringList('defaultCoordinate');
              final rs = await _customerService.updateTravelerProfile(
                CustomerViewModel(
                  id: widget.traveler.id, 
                  name: nameController.text, 
                  isMale: isMale, 
                  avatarUrl: avatarLink, 
                  phone: widget.traveler.phone, 
                  balance: widget.traveler.balance, 
                  defaultAddress: sharedPreferences.getString('defaultAddress'), 
                  defaultCoordinate: PointLatLng(double.parse(defaultCoordinate![0]), double.parse(defaultCoordinate[1])))
              );
              if(rs != null){
               await AwesomeDialog(context: context,
                  animType: AnimType.bottomSlide,
                  dialogType: DialogType.success,
                  title: 'Cập nhật thông tin thành công',
                  titleTextStyle: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSans',
                  )
                ).show();

                Future.delayed(const Duration(seconds: 1), (){
                  Navigator.of(context).pop();
                });
              }
            },
            child: const Text('Lưu thông tin')),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 5.h,
              ),
              InkWell(
                splashColor: Colors.transparent,
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  myImage = await _picker.pickImage(source: ImageSource.gallery);
                  if (myImage != null) {
                    var headers = {
                      'Content-Type': 'application/json',
                    };
                    final bytes = await File(myImage!.path).readAsBytes();
                    final encodedImage = base64Encode(bytes);
                    var response = await http.post(
                        Uri.parse(
                            'https://oafr1w3y52.execute-api.ap-southeast-2.amazonaws.com/default/btss-getPresignedUrl'),
                        headers: headers,
                        body: encodedImage);
                        if(response.statusCode == 200){
                          setState(() {
                            avatarLink = json.decode(response.body)['fileName'];
                          });
                        }else{
                          print('Exception when uploading image to server!');
                        }
                  }
                },
                child: Container(
                  width: 100.w,
                  alignment: Alignment.center,
                  child: Container(
                    height: 20.h,
                    width: 20.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child:
                        Image.network(avatarLink, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              defaultTextFormField(
                controller: nameController,
                inputType: TextInputType.name,
                text: 'Tên người dùng',
                hinttext: 'Nguyễn Văn A',
                onValidate: (value) {
                  if (value!.isEmpty) {
                    return "Tên của người dùng không được để trống";
                  }
                },
              ),
              SizedBox(
                height: 3.h,
              ),
              defaultTextFormField(
                readonly: true,
                controller: addressController,
                inputType: TextInputType.streetAddress,
                text: 'Địa chỉ',
                hinttext: '113 Hồng Lĩnh, ...',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => SelectDefaultAddress(
                            callback: callback,
                          )));
                },
                onValidate: (value) {
                  if (value!.isEmpty) {
                    return "Địa chỉ mặc định không được để trống";
                  }
                },
              ),
              SizedBox(
                height: 2.h,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Giới tính",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isMale = true;
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 6.h,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: isMale
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white,
                              border: Border.all(color: primaryColor, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: const Text(
                            "Nam",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isMale = false;
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 6.h,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: !isMale
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white,
                              border: Border.all(color: primaryColor, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: const Text(
                            "Nữ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  callback(SearchStartLocationResult? selectedAddress,
      PointLatLng? selectedLatLng) async {
    if (selectedAddress != null) {
      setState(() {
        addressController.text = selectedAddress.address;
        _selectedAddressLatLng =
            PointLatLng(selectedAddress.lat, selectedAddress.lng);
      });
    } else {
      var result = await getPlaceDetail(selectedLatLng!);
      if (result != null) {
        setState(() {
          _selectedAddressLatLng = selectedLatLng;
          addressController.text = result['results'][0]['formatted_address'];
        });
      }
    }
  }
}
