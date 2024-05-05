import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/features/home/presentation/pages/home_screen.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/announcement_screen/announcement_list_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/planscreen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/profile_screen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/transaction_history_screen.dart';
import 'package:greenwheel_user_app/service/announcement_service.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key, required this.pageIndex});
  final int pageIndex;
  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _selectedPageIndex = 0;
  final AnnouncementService _notificationService = AnnouncementService();

  void selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedPageIndex = widget.pageIndex;
    sendDeviceToken();
    _notificationService.requestNotificationPermission();
    _notificationService.firebaseInit(context);
  }

  sendDeviceToken() async{
    var isDeviceTokenSended = sharedPreferences.getBool('isDeviceTokenSended');
    if (isDeviceTokenSended == null || !isDeviceTokenSended) {
      sharedPreferences.setBool("isDeviceTokenSended", true);
      // await _customerService.sendDeviceToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    // _selectedPageIndex = widget.pageIndex;
    late Widget activePage;
    switch (_selectedPageIndex) {
      case 0:
        activePage = const HomeScreen();
        break;
      case 1:
        // switch to plan  page;
        activePage = const PlanScreen();
        break;
      case 2:
        activePage = const TransactionHistoryScreen();
        break;
      case 3:
        //switch to Noti page;
        activePage = const AnnouncementListScreen();
        break;
      case 4:
        //switch to profie page;
        activePage = const ProfileScreen();
        break;
    }

    return SafeArea(
        child: Scaffold(
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        onTap: selectPage,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
              ),
              label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: "Kế hoạch"),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Thanh toán',),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Thông báo"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ")
        ],
      ),
    ));
  }
}
