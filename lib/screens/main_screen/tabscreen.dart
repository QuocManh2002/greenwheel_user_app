import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/screens/main_screen/home.dart';
import 'package:greenwheel_user_app/screens/main_screen/notificationscreen.dart';
import 'package:greenwheel_user_app/screens/main_screen/planscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_screen.dart';
import 'package:greenwheel_user_app/screens/profie_screen/profile_screen.dart';
import 'package:uni_links/uni_links.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key, required this.pageIndex});
  final int pageIndex;
  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _selectedPageIndex = 0;

  StreamSubscription? _sub;  
   void initUniLinks() {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = linkStream.listen((String? link)  {
      // Parse the link and warn the user, if it is not correct
      if(link != null){
        print("111111111111111111111111111111");
        var uri = Uri.parse(link);
        if(uri.queryParameters['id'] != null){
          print(uri.queryParameters['id'].toString());
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) =>  DetailPlanScreen(planId: int.parse(uri.queryParameters['id'].toString()), locationName: "Rừng tràm Trà Sư", isEnableToJoin: true,)));
        }
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

  void selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initUniLinks();
    _selectedPageIndex = widget.pageIndex;
  }

  @override
  Widget build(BuildContext context) {
    // _selectedPageIndex = widget.pageIndex;
    late Widget activePage ;
    switch (_selectedPageIndex) {
      case 0:
        activePage = const HomeScreen();
        break;
      case 1:
        // switch to plan  page;
        activePage = const PlanScreen();
        break;
      case 2:
        //switch to Noti page;
        activePage = const NotificationScreen();
        break;
      case 3:
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
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Thông báo"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ")
        ],
      ),
    ));
  }
}
