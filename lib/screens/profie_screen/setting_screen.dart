import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/screens/wallet_screen/add_balance.dart';
import 'package:sizer2/sizer2.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
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
                  height: 13.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Ly Sang Hốc",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Image.asset(
                      male_icon,
                      height: 20,
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  "0797695011",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                        borderRadius: BorderRadius.all(Radius.circular(14)),
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
                                  const Text(
                                    "1000",
                                    style: TextStyle(
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
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  const AddBalanceScreen()));
                                    },
                                    icon: const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: primaryColor,
                                    )),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              const Text(
                                "Nạp",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
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
                        alignment:const Alignment(-1, 0),
                          backgroundColor: Colors.white,
                          minimumSize: Size(100.w, 6.h),
                          shadowColor: primaryColor,
                          shape:const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.person,
                        color: primaryColor,
                      ),
                      label: const Text(
                        "Chỉnh sửa thông tin",
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      )),
                ),
                const SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        alignment:const Alignment(-1, 0),
                          backgroundColor: Colors.white,
                          minimumSize: Size(100.w, 6.h),
                          shadowColor: primaryColor,
                          shape:const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.vpn_key,
                        color: primaryColor,
                      ),
                      label: const Text(
                        "Thay đổi mật khẩu",
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      )),
                ),
                const SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        alignment:const Alignment(-1, 0),
                          backgroundColor: Colors.white,
                          minimumSize: Size(100.w, 6.h),
                          shadowColor: primaryColor,
                          shape:const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout,
                        color: primaryColor,
                      ),
                      label: const Text(
                        "Đăng xuất",
                        style: TextStyle(color: Colors.black54, fontSize: 18),
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
                "https://cdn.gametv.vn/gtv-photo/GTVNews/1604629662/api_cdn.gametv.vn-e21206645ee357227c2f354ea4c0eb50.png",
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
    ));
  }
}
