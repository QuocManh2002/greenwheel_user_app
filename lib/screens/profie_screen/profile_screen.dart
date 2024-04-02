import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/loading_screen/profile_loading_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_new_screen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/qr_screen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/transaction_history_screen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/update_profile_screen.dart';
import 'package:greenwheel_user_app/screens/wallet_screen/add_balance.dart';
import 'package:greenwheel_user_app/service/traveler_service.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CustomerService _customerService = CustomerService();
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
    _customer = await _customerService.GetCustomerByPhone(phone);
    if (_customer != null) {
      setState(() {
        _isLoading = false;
      });
      print('$baseBucketImage${_customer!.avatarUrl}');
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  locale: 'vi_VN',
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
                      buildProfileButton(() {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: UpdateProfileScreen(
                                  traveler: _customer!,
                                ),
                                type: PageTransitionType.rightToLeft));
                      }, Icons.person, 'Chỉnh sửa thông tin'),
                      SizedBox(
                        height: 1.h,
                      ),
                      buildProfileButton(() {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: const TransactionHistoryScreen(),
                                type: PageTransitionType.rightToLeft));
                      }, Icons.history, 'Lịch sử giao dịch'),
                      SizedBox(
                        height: 1.h,
                      ),
                      buildProfileButton(() {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: const DetailPlanNewScreen(
                                  isEnableToJoin: true,
                                  planId: 134,
                                  planType: 'INVITATION',
                                ),
                                type: PageTransitionType.rightToLeft));
                      }, Icons.vpn_key, 'Thay đổi mật khẩu'),
                      SizedBox(
                        height: 1.h,
                      ),
                      buildProfileButton(() {
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
                                  final rs =
                                      await _customerService.travelerSignOut();
                                  if (rs != 0) {
                                    sharedPreferences.clear();
                                    Restart.restartApp();
                                  }
                                },
                                btnCancelOnPress: () {})
                            .show();
                      }, Icons.logout, 'Đăng xuất'),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                      margin: EdgeInsets.only(top: 5.h),
                      height: 18.h,
                      width: 18.h,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child:
                          CachedNetworkImage(
                              key: UniqueKey(),
                              height: 18.h,
                              width: 18.h,
                              fit: BoxFit.cover,
                              imageUrl:
                                  '$baseBucketImage${_customer!.avatarUrl}',
                              placeholder: (context, url) =>
                                  Image.memory(kTransparentImage),
                              errorWidget: (context, url, error) => Image.asset(
                                    _customer!.isMale
                                        ? male_default_avatar
                                        : female_default_avatar,
                                    fit: BoxFit.cover,
                                  ))),
                )
              ],
            ),
    ));
  }

  buildProfileButton(void Function() onTap, IconData icon, String text) =>
      InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            width: 100.w,
            height: 6.h,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: primaryColor.withOpacity(0.5),
                    offset: const Offset(1, 3),
                  )
                ],
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 1.h,
                ),
                Icon(
                  icon,
                  color: primaryColor,
                  size: 25,
                ),
                SizedBox(
                  width: 1.h,
                ),
                Text(
                  text,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      );
}
