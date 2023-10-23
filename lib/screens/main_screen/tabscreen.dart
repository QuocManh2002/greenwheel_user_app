import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/main_screen/historyscreen.dart';
import 'package:greenwheel_user_app/screens/main_screen/home.dart';
import 'package:greenwheel_user_app/screens/main_screen/notificationscreen.dart';
import 'package:greenwheel_user_app/screens/main_screen/planscreen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _selectedPageIndex = 0;
  void selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const HomeScreen();
    switch (_selectedPageIndex) {
      case 1:
        // switch to plan  page;
        activePage = const PlanScreen();
        break;
      case 2:
        //switch to Noti page;
        activePage = const NotificationScreen();
        break;
      case 3:
        //switch to history page;
        activePage = const HistoryScreen();
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
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Thông báo"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử")
        ],
      ),
    ));
  }
}
