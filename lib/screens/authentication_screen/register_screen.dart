import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/config/token_refresher.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/goong_request.dart';
import 'package:greenwheel_user_app/helpers/restart_widget.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/select_default_address.dart';
import 'package:greenwheel_user_app/screens/introduce_screen/splash_screen.dart';
import 'package:greenwheel_user_app/service/customer_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/search_start_location_result.dart';
import 'package:greenwheel_user_app/view_models/register.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sizer2/sizer2.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PointLatLng? _selectedAddressLatLng;
  bool isMale = true;
  DateTime selectedDate = DateTime.now();
  bool isPolicyAccept = false;
  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Đăng ký tài khoản",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Lần đầu đăng nhập vào ứng dụng",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Text(
                  "Hãy cho chúng tôi biết một vài thông tin về bạn",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 16,
                ),
                const SizedBox(
                  height: 8,
                ),
                defaultTextFormField(
                  controller: nameController,
                  inputType: TextInputType.name,
                  text: 'Tên người dùng',
                  hinttext: 'Câu cá, tắm suối...',
                  onValidate: (value) {
                    if (value!.isEmpty) {
                      return "Tên của người dùng không được để trống";
                    }
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Giới tính",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 8,
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
                                border:
                                    Border.all(color: primaryColor, width: 1),
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
                                border:
                                    Border.all(color: primaryColor, width: 1),
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
                const SizedBox(
                  height: 16,
                ),
                // defaultTextFormField(
                //   readonly: true,
                //   controller: addressController,
                //   inputType: TextInputType.streetAddress,
                //   text: 'Địa chỉ',
                //   hinttext: '113 Hồng Lĩnh, ...',
                //   onTap: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //         builder: (ctx) => SelectDefaultAddress(
                //               callback: callback,
                //             )));
                //   },
                //   onValidate: (value) {
                //     if (value!.isEmpty) {
                //       return "Địa chỉ mặc định không được để trống";
                //     }
                //   },
                // ),
                Row(
                  children: [
                    Checkbox(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      value: isPolicyAccept,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          isPolicyAccept = !isPolicyAccept;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Tôi đã đọc và đồng ý tất cả các điều khoản về chính sách sử dụng và quyền lợi của người dùng",
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: _register,
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }

  _register() async {
    if (!isPolicyAccept) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Bạn phải đồng ý với các chính sách của ứng dụng trước khi bắt đầu cùng GREENWHEELS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              btnOkColor: Colors.orange,
              btnOkOnPress: () {},
              btnOkText: 'Ok')
          .show();
    } else {
      if (_formKey.currentState!.validate()) {
        final CustomerService _newService = CustomerService();
        var id = await _newService.registerTraveler(RegisterViewModel(
            deviceToken: sharedPreferences.getString('deviceToken')!,
            isMale: isMale,
            name: nameController.text));
        if (id != null || id != 0) {
          await TokenRefresher.refreshToken();
          print("2: ${sharedPreferences.getString('userToken')}");
          await _customerService.travelerSignIn(sharedPreferences.getString('deviceToken')!);
          // ignore: use_build_context_synchronously
          Restart.restartApp(); // ignore: use_build_context_synchronously
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (ctx) => const SplashScreen()),
          //     (route) => false);
        }
      }
    }
  }

  // callback(SearchStartLocationResult? selectedAddress,
  //     PointLatLng? selectedLatLng) async {
  //   if (selectedAddress != null) {
  //     setState(() {
  //       addressController.text = selectedAddress.address;
  //       _selectedAddressLatLng =
  //           PointLatLng(selectedAddress.lat, selectedAddress.lng);
  //     });
  //   } else {
  //     var result = await getPlaceDetail(selectedLatLng!);
  //     if (result != null) {
  //       setState(() {
  //         _selectedAddressLatLng = selectedLatLng;
  //         addressController.text = result['results'][0]['formatted_address'];
  //       });
  //     }
  //   }
  // }
}
