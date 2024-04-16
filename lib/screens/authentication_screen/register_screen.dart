
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/image_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:greenwheel_user_app/view_models/register.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isMale = true;
  bool isPolicyAccept = false;
  String? avatarPath;

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
                  height: 8,
                ),
                Container(
                  alignment: Alignment.center,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: () async {
                      final _avatarPath =
                          await ImageHandler().handlePickImage(context);
                      if (_avatarPath != null) {
                        setState(() {
                          avatarPath = _avatarPath;
                        });
                      }
                    },
                    child: Container(
                      height: 40.w,
                      width: 40.w,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 1.5)),
                      child: CachedNetworkImage(
                        imageUrl: '$baseBucketImage$avatarPath',
                        height: 40.w,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            Image.memory(kTransparentImage),
                        width: double.infinity,
                        key: UniqueKey(),
                        errorWidget: (context, url, error) => SvgPicture.asset(
                          no_image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                TextFormFieldWithLength(
                  controller: nameController,
                  inputType: TextInputType.name,
                  text: 'Tên người dùng',
                  hinttext: 'Nguyễn Văn A',
                  maxLength: 30,
                  onValidate: (value) {
                    if (value!.isEmpty) {
                      return "Tên của người dùng không được để trống";
                    } else if (value.length < 4 || value.length > 30) {
                      return "Tên của người dùng phải có độ dài từ 4-30 kí tự";
                    }
                    return null;
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
        var rs = await _newService.registerTraveler(RegisterViewModel(
            deviceToken: sharedPreferences.getString('deviceToken')!,
            isMale: isMale,
            avatarUrl: avatarPath,
            name: nameController.text));
        if (rs != null) {
          _newService.saveAccountToSharePref(rs.traveler);
          sharedPreferences.setString('userRefreshToken', rs.refreshToken);
          sharedPreferences.setString('userToken', rs.accessToken);
          Restart.restartApp(); // ignore: use_build_context_synchronously
        }
      }
    }
  }
}
