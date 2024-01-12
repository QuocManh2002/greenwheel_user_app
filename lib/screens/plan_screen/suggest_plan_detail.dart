import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/helpers/direction_handler.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_new_plan_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/combo_date.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/base_information.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class SuggestPlanDetailScreen extends StatefulWidget {
  const SuggestPlanDetailScreen(
      {super.key,
      required this.planId,
      required this.leaderName,
      required this.location});
  final int planId;
  final String leaderName;
  final LocationViewModel location;

  @override
  State<SuggestPlanDetailScreen> createState() =>
      _SuggestPlanDetailScreenState();
}

class _SuggestPlanDetailScreenState extends State<SuggestPlanDetailScreen>
    with TickerProviderStateMixin {
  PlanDetail? _planDetail;
  final PlanService _planService = PlanService();
  bool _isLoading = true;
  late TabController _tabController;
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  int _currentIndexEmergencyCard = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  setUpData() async {
    _planDetail = await _planService.GetPlanById(widget.planId);
    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];

    for (var item in _planDetail!.orders!) {
      if (item.supplierType == "RESTAURANT") {
        listRestaurant.add(SupplierOrderCard(order: item));
      } else {
        listMotel.add(SupplierOrderCard(order: item));
      }
    }
    setState(() {
      _listMotel = listMotel;
      _listRestaurant = listRestaurant;
      // _orderList = orderList;
    });
    if (_planDetail != null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.white)),
        ),
        title: const Text(
          'Chi tiết kế hoạch',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Text('Loading...'),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          height: 35.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          imageUrl: _planDetail!.imageUrls[0],
                          placeholder: (context, url) =>
                              Image.memory(kTransparentImage),
                          errorWidget: (context, url, error) =>
                              FadeInImage.assetNetwork(
                            height: 15.h,
                            width: 15.h,
                            fit: BoxFit.cover,
                            placeholder: 'No Image',
                            image:
                                'https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0',
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        BaseInformationWidget(plan: _planDetail!),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Leader:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  Text(
                                    widget.leaderName,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                height: 1.8,
                                color: Colors.grey.withOpacity(0.4),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              if (_planDetail!.savedContacts != null)
                                Column(
                                  children: [
                                    Container(
                                        alignment: Alignment.centerLeft,
                                        child: const Text(
                                          'Dịch vụ khẩn cấp đã lưu: ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    SizedBox(
                                      height: 18.h,
                                      width: double.infinity,
                                      child: PageView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            _planDetail!.savedContacts!.length,
                                        onPageChanged: (value) {
                                          setState(() {
                                            _currentIndexEmergencyCard = value;
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          return EmergencyContactCard(
                                              emergency: _planDetail!
                                                  .savedContacts![index],
                                              index: index,
                                              callback: () {},
                                              isSelected: true);
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    if (_planDetail!.savedContacts!.length > 1)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          for (int i = 0;
                                              i <
                                                  _planDetail!
                                                      .savedContacts!.length;
                                              i++)
                                            Container(
                                                height: 1.5.h,
                                                child: buildIndicator(i)),
                                        ],
                                      ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      height: 1.8,
                                      color: Colors.grey.withOpacity(0.4),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                ),
                              const Text(
                                'Lịch trình:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                height: 60.h,
                                child: PLanScheduleWidget(
                                  schedule: _planDetail!.schedule,
                                  startDate: _planDetail!.startDate,
                                  endDate: _planDetail!.endDate,
                                ),
                              ),
                              Container(
                                height: 1.8,
                                color: Colors.grey.withOpacity(0.4),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const Text(
                                'Dịch vụ:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              TabBar(
                                  controller: _tabController,
                                  indicatorColor: primaryColor,
                                  labelColor: primaryColor,
                                  unselectedLabelColor: Colors.grey,
                                  tabs: [
                                    Tab(
                                      text: "(${_listMotel.length})",
                                      icon: const Icon(Icons.hotel),
                                    ),
                                    Tab(
                                      text: "(${_listRestaurant.length})",
                                      icon: const Icon(Icons.restaurant),
                                    )
                                  ]),
                              SizedBox(
                                height: getHeightServiceWidget(),
                                child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      // ListView.builder(
                                      //   physics: const BouncingScrollPhysics(),
                                      //   shrinkWrap: true,
                                      //   itemCount: _listMotel.length,
                                      //   itemBuilder: (context, index) {
                                      //     return _listMotel[index];
                                      //   },
                                      // ),
                                      // ListView.builder(
                                      //   physics: const BouncingScrollPhysics(),
                                      //   shrinkWrap: true,
                                      //   itemCount: _listRestaurant.length,
                                      //   itemBuilder: (context, index) {
                                      //     return _listRestaurant[index];
                                      //   },
                                      // ),
                                      SizedBox(
                                        height: _listMotel.length <= 2
                                            ? _listMotel.length * 16.h
                                            : 32.h,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              for (final item in _listMotel)
                                                item
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: _listRestaurant.length <= 2
                                            ? _listRestaurant.length * 16.h
                                            : 32.h,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              for (final item
                                                  in _listRestaurant)
                                                item
                                            ],
                                          ),
                                        ),
                                      )
                                    ]),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onClonePlan,
                  style: elevatedButtonStyle,
                  child: const Text(
                    "Sao chép kế hoạch",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 16,
                )
              ],
            ),
    ));
  }

  getHeightServiceWidget() {
    double rs = 0;
    if (_tabController.index == 0) {
      if (_listMotel.length <= 2) {
        rs = _listMotel.length * 16.h;
      } else {
        rs = 32.h;
      }
    } else {
      if (_listMotel.length <= 2) {
        rs = _listRestaurant.length * 16.h;
      } else {
        rs = 32.h;
      }
    }
    return rs;
  }

  onClonePlan() async {
    ComboDate _comboDate = listComboDate.firstWhere((element) =>
        (element.numberOfDay + element.numberOfNight) ==
        _planDetail!.numOfExpPeriod);

    var rsList = _planDetail!.savedContacts!
        .map((e) => EmergencyContactViewModel().toJson(e))
        .toList();
    sharedPreferences.setInt('plan_combo_date', _comboDate.id - 1);
    sharedPreferences.setInt('numOfExpPeriod', _planDetail!.numOfExpPeriod);
    sharedPreferences.setInt('plan_number_of_member', _planDetail!.memberLimit);
    sharedPreferences.setDouble(
        'plan_start_lat', _planDetail!.startLocationLat);
    sharedPreferences.setDouble(
        'plan_start_lng', _planDetail!.startLocationLng);
    var mapInfo = await getDirectionsAPIResponse(
        LatLng(_planDetail!.startLocationLat, _planDetail!.startLocationLng),
        LatLng(widget.location.latitude, widget.location.longitude));
    if (mapInfo.isNotEmpty) {
      sharedPreferences.setDouble('plan_distance', mapInfo["distance"] / 1000);
      sharedPreferences.setDouble('plan_duration', mapInfo["duration"] / 3600);
    }
    sharedPreferences.setString('plan_saved_emergency', rsList.toString());
    var test1 = _planService.GetPlanScheduleFromJsonNew(
        _planDetail!.schedule,
        _planDetail!.startDate,
        _planDetail!.endDate.difference(_planDetail!.startDate).inDays + 1);
    List<dynamic> listrs = [];
    List<dynamic> listItem = [];
    for (final plan in test1) {
      listItem = [];
      for (final item in plan.items) {
        listItem.add(item.toJson());
      }
      listrs.add(listItem);
    }
    print(listrs);
    var encodeList = json.encode(listrs);
    print(json.encode(listrs));
    print(json.decode(encodeList));
    sharedPreferences.setString('plan_schedule', json.encode(listrs));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => CreateNewPlanScreen(
              location: widget.location,
              isCreate: true,
              schedule: _planDetail!.schedule,
            )));
  }

  Widget buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
      margin: const EdgeInsets.only(left: 16),
      width: _currentIndexEmergencyCard == index ? 35 : 12,
      decoration: BoxDecoration(
          color: _currentIndexEmergencyCard == index
              ? primaryColor
              : primaryColor.withOpacity(0.7),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, offset: Offset(2, 3), blurRadius: 3)
          ]),
    );
  }
}
