import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/authentication_screen/login_screen.dart';
import 'package:greenwheel_user_app/screens/loading_screen/profile_loading_screen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/qr_screen.dart';
import 'package:greenwheel_user_app/screens/wallet_screen/add_balance.dart';
import 'package:greenwheel_user_app/service/customer_service.dart';
import 'package:greenwheel_user_app/service/device_service.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sizer2/sizer2.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CustomerService _customerService = CustomerService();
  DeviceService _deviceService = DeviceService();
  CustomerViewModel? _customer;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    String phone = sharedPreferences.getString("userPhone")!;
    List<CustomerViewModel>? customer;
    customer = await _customerService.GetCustomerByPhone(phone);
    if (customer.isNotEmpty) {
      setState(() {
        _customer = customer![0];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: _isLoading ? Colors.white : primaryColor,
      body: _isLoading
          ? const ProfileLoadingScreen()
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Hồ sơ",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                Container(
                  height: 75.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(42),
                          topRight: Radius.circular(42))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10.h,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3,
                                    color: Colors.black12,
                                    offset: Offset(1, 3),
                                  )
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        _customer!.name,
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "0${_customer!.phone.substring(3)}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5, right: 0),
                                    child: IconButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      QRScreen()));
                                        },
                                        icon: const Icon(
                                          Icons.qr_code_2,
                                          size: 40,
                                        )),
                                  )
                                ],
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  color: Colors.black12,
                                  offset: Offset(1, 3),
                                )
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14)),
                              color: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        "Số dư:",
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24, right: 16, bottom: 16),
                                    child: Row(
                                      children: [
                                        Text(
                                          NumberFormat.simpleCurrency(
                                                  locale: 'en-US',
                                                  decimalDigits: 0,
                                                  name: "")
                                              .format(double.parse(_customer!
                                                  .balance
                                                  .toString())),
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        SvgPicture.asset(
                                          gcoin_logo,
                                          height: 32,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 5.h,
                                      width: 5.h,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.25),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(14))),
                                      child: IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        AddBalanceScreen(
                                                          balance: _customer!
                                                              .balance,
                                                        )));
                                          },
                                          icon: const Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            color: primaryColor,
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    const Text(
                                      "Nạp",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 32),
                        child: const Text(
                          "Tổng quát",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                alignment: const Alignment(-1, 0),
                                backgroundColor: Colors.white,
                                minimumSize: Size(100.w, 6.h),
                                shadowColor: primaryColor,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            onPressed: () {},
                            icon: const Icon(
                              Icons.person,
                              color: primaryColor,
                            ),
                            label: const Text(
                              "Chỉnh sửa thông tin",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 18),
                            )),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                alignment: const Alignment(-1, 0),
                                backgroundColor: Colors.white,
                                minimumSize: Size(100.w, 6.h),
                                shadowColor: primaryColor,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            onPressed: () {},
                            icon: const Icon(
                              Icons.vpn_key,
                              color: primaryColor,
                            ),
                            label: const Text(
                              "Thay đổi mật khẩu",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 18),
                            )),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                alignment: const Alignment(-1, 0),
                                backgroundColor: Colors.white,
                                minimumSize: Size(100.w, 6.h),
                                shadowColor: primaryColor,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            onPressed: () {
                              AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.question,
                                      animType: AnimType.leftSlide,
                                      showCloseIcon: true,
                                      title: "Đăng xuất",
                                      btnOkColor: primaryColor,
                                      btnOkText: "Đồng ý",
                                      btnCancelText: "Đóng",
                                      desc:
                                          "   Bạn có muốn thoát khỏi phiên đăng nhập này không ?  ",
                                      btnOkOnPress: () async {
                                        // _deviceService.stopNotification();
                                        final rs = await _customerService
                                            .travelerSignOut();
                                        if (rs != 0) {
                                          sharedPreferences.clear();
                                          // ignore: use_build_context_synchronously
                                          // Navigator.pushAndRemoveUntil(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (_) =>
                                          //           const LoginScreen()),
                                          //   (route) => false,
                                          // );
                                          Restart.restartApp();
                                        }
                                      },
                                      btnCancelOnPress: () {})
                                  .show();
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: primaryColor,
                            ),
                            label: const Text(
                              "Đăng xuất",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 18),
                            )),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    margin: EdgeInsets.only(top: 5.h),
                    height: 18.h,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Image.network(
                      _customer!.avatarUrl == null || _customer!.avatarUrl == ""
                          ? defaultUserAvatarLink
                          : _customer!.avatarUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
    ));
  }
}
