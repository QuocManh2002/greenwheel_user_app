import 'package:flutter/material.dart';
import 'package:phuot_app/screens/offline_screen/offline_detail_screen.dart';
import 'package:phuot_app/service/offline_service.dart';
import 'package:phuot_app/widgets/offline_screen_widget/offline_plan_card.dart';
import 'package:page_transition/page_transition.dart';

class OfflineHomeScreen extends StatefulWidget {
  const OfflineHomeScreen({super.key});

  @override
  State<OfflineHomeScreen> createState() => _OfflineHomeScreenState();
}

class _OfflineHomeScreenState extends State<OfflineHomeScreen> {
  List<dynamic>? planList;
  final OfflineService _offlineService = OfflineService();

  @override
  void initState() {
    super.initState();
    final list = _offlineService.getOfflinePlans();
    if (list != null) {
      setState(() {
        planList = list;
      });
      if (list.length == 1) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            Navigator.push(
              context,
              PageTransition(
                  child: OfflineDetailScreen(plan: list[0]),
                  type: PageTransitionType.rightToLeft),
            );
          },
        );
      }
    }
  }

  getData() async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white.withOpacity(0.94),
      appBar: AppBar(
        title: const Text('Kế hoạch của bạn'),
      ),
      body: SingleChildScrollView(
          child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: planList!.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: OfflinePlanCard(plan: planList![index]),
        ),
      )),
    ));
  }
}
