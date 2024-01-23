// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/combo_date_plan.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_new_plan_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/share_plan_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/base_information.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/tab_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../widgets/style_widget/button_style.dart';

class DetailPlanNewScreen extends StatefulWidget {
  const DetailPlanNewScreen(
      {super.key,
      required this.planId,
      required this.location,
      required this.isEnableToJoin});
  final int planId;
  final bool isEnableToJoin;
  final LocationViewModel location;

  @override
  State<DetailPlanNewScreen> createState() => _DetailPlanScreenState();
}

class _DetailPlanScreenState extends State<DetailPlanNewScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  PlanService _planService = PlanService();
  LocationService _locationService = LocationService();
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  PlanDetail? _planDetail;
  late TabController tabController;
  late TextEditingController newItemController;
  List<PlanMemberViewModel> _planMembers = [];
  List<PlanMemberViewModel> _joinedMember = [];
  double total = 0;
  List<SupplierViewModel>? _saveSupplier;
  int _currentIndexEmergencyCard = 0;
  int _selectedTab = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    newItemController = TextEditingController();
    setupData();
  }

  void removeItem(String item, List<String> list) {
    setState(() {
      list.remove(item);
    });
  }

  setupData() async {
    _planDetail = null;
    _planDetail = await _planService.GetPlanById(widget.planId);

    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];

    for (var item in _planDetail!.orders!) {
      if (item.supplierType == "RESTAURANT") {
        listRestaurant.add(SupplierOrderCard(order: item));
      } else {
        listMotel.add(SupplierOrderCard(order: item));
      }
      total += item.total;
    }
    _planMembers = _planDetail!.members!;
    setState(() {
      _listMotel = listMotel;
      _listRestaurant = listRestaurant;
      // _orderList = orderList;
    });
    if (_planDetail != null) {
      // if (_planDetail!.savedContacts != null) {
      //   List<int> ids = _planDetail!.savedContacts!
      //       .map((e) => int.parse(e.toString()))
      //       .toList();
      //   final rs = await _supplierService.getSuppliersByIds(ids);
      //   setState(() {
      //     _saveSupplier = rs;
      //   });
      // }

      setState(() {
        isLoading = false;
      });
      print(_saveSupplier);
    }
  }

  updatePlan() async {
    final location =
        await _locationService.GetLocationById(_planDetail!.locationId);
    if (location != null) {
      final defaultComboDate = listComboDate
              .firstWhere((element) =>
                  element.duration == location.suggestedTripLength * 2)
              .id -
          1;
      sharedPreferences.setInt('planId', widget.planId);
      sharedPreferences.setInt(
          "plan_number_of_member", _planDetail!.memberLimit);
      sharedPreferences.setInt('plan_combo_date', defaultComboDate);
      sharedPreferences.setDouble(
          'plan_start_lat', _planDetail!.startLocationLat);
      sharedPreferences.setDouble(
          'plan_start_lng', _planDetail!.startLocationLng);
      sharedPreferences.setString(
          'plan_start_date', _planDetail!.startDate.toString());
      sharedPreferences.setString('plan_start_time',
          '${_planDetail!.startDate.hour}:${_planDetail!.startDate.minute}');
      sharedPreferences.setString(
          'plan_end_date', _planDetail!.endDate.toString());
      sharedPreferences.setString(
          'plan_schedule', _planDetail!.schedule.toString());
      sharedPreferences.setString(
          'plan_saved_emergency',
          _planDetail!.savedContacts!
              .map((e) => e.toJson(e))
              .toList()
              .toString());
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => CreateNewPlanScreen(
                location: location,
                isCreate: false,
                schedule: _planDetail!.schedule,
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Kế hoạch',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              leading: BackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white)),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: updatePlan,
                    icon: const Icon(
                      Icons.edit_square,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            body: isLoading
                ? const Center(
                    child: Text("Loading..."),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _planDetail!.name,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Container(
                                height: 1.8,
                                color: Colors.grey.withOpacity(0.4),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        onTap: () {
                                          setState(() {
                                            _selectedTab = 0;
                                          });
                                        },
                                        child: TabIconButton(
                                          iconDefaultUrl: basic_information_green,
                                          iconSelectedUrl: basic_information_white,
                                          text: 'Thông tin cơ bản',
                                          isSelected: _selectedTab == 0,
                                          index: 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        onTap: () {
                                          setState(() {
                                            _selectedTab = 1;
                                          });
                                        },
                                        child: TabIconButton(
                                          iconDefaultUrl: schedule_green,
                                          iconSelectedUrl: schedule_white,
                                          text: 'Lịch trình',
                                          isSelected: _selectedTab == 1,
                                          index: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        onTap: () {
                                          setState(() {
                                            _selectedTab = 2;
                                          });
                                        },
                                        child: TabIconButton(
                                          iconDefaultUrl: service_green,
                                          iconSelectedUrl: service_white,
                                          text: 'Dịch vụ',
                                          isSelected: _selectedTab == 2,
                                          index: 2,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              child: _selectedTab == 0
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Padding(padding: EdgeInsets.symmetric(horizontal: 24),
                                          child: Text(
                                            'Thông tin cơ bản', style: TextStyle(
                                              fontSize: 20, 
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16,),
                                        BaseInformationWidget(
                                            plan: _planDetail!),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: Column(
                                            children: [
                                              Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                    'Dịch vụ khẩn cấp đã lưu: ',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              SizedBox(
                                                height: 18.h,
                                                width: double.infinity,
                                                child: PageView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: _planDetail!
                                                      .savedContacts!.length,
                                                  onPageChanged: (value) {
                                                    setState(() {
                                                      _currentIndexEmergencyCard =
                                                          value;
                                                    });
                                                  },
                                                  itemBuilder:
                                                      (context, index) {
                                                    return EmergencyContactCard(
                                                        emergency: _planDetail!
                                                                .savedContacts![
                                                            index],
                                                        index: index,
                                                        callback: () {},
                                                        isSelected: true);
                                                  },
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              if (_planDetail!
                                                      .savedContacts!.length >
                                                  1)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    for (int i = 0;
                                                        i <
                                                            _planDetail!
                                                                .savedContacts!
                                                                .length;
                                                        i++)
                                                      Container(
                                                          height: 1.5.h,
                                                          child: buildIndicator(
                                                              i)),
                                                  ],
                                                ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Container(
                                                height: 1.8,
                                                color: Colors.grey
                                                    .withOpacity(0.4),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Thành viên đã tham gia: ",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                                for (final member
                                                    in _joinedMember)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6,
                                                        horizontal: 12),
                                                    child: Text(
                                                      member.status == "LEADING"
                                                          ? member.travelerId ==
                                                                  int.parse(sharedPreferences
                                                                      .getString(
                                                                          'userId')!)
                                                              ? "- ${member.name} (Bạn)"
                                                              : "- ${member.name} - LEADING - 0${member.phone.substring(3)}"
                                                          : member.travelerId ==
                                                                  int.parse(sharedPreferences
                                                                      .getString(
                                                                          'userId')!)
                                                              ? "- ${member.name} (Bạn)"
                                                              : "- ${member.name} - 0${member.phone.substring(3)}",
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : _selectedTab == 1
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: Column(
                                            children: [
                                              Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                    "Lịch trình",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              SizedBox(
                                                height: 60.h,
                                                child: PLanScheduleWidget(
                                                  schedule:
                                                      _planDetail!.schedule,
                                                  startDate:
                                                      _planDetail!.startDate,
                                                  endDate: _planDetail!.endDate,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: Column(
                                            children: [
                                              Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                    "Các loại dịch vụ",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              TabBar(
                                                  controller: tabController,
                                                  indicatorColor: primaryColor,
                                                  labelColor: primaryColor,
                                                  unselectedLabelColor:
                                                      Colors.grey,
                                                  tabs: [
                                                    Tab(
                                                      text:
                                                          "(${_listMotel.length})",
                                                      icon: const Icon(
                                                          Icons.hotel),
                                                    ),
                                                    Tab(
                                                      text:
                                                          "(${_listRestaurant.length})",
                                                      icon: const Icon(
                                                          Icons.restaurant),
                                                    )
                                                  ]),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 8),
                                                height:
                                                    _listRestaurant.isEmpty &&
                                                            _listMotel.isEmpty
                                                        ? 0.h
                                                        : 35.h,
                                                child: TabBarView(
                                                    controller: tabController,
                                                    children: [
                                                      ListView.builder(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            _listMotel.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return _listMotel[
                                                              index];
                                                        },
                                                      ),
                                                      ListView.builder(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            _listRestaurant
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return _listRestaurant[
                                                              index];
                                                        },
                                                      ),
                                                    ]),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              if (total != 0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'Tổng cộng: ',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(total)} VND',
                                                        style: const TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                            )
                          ],
                        )),
                      ),
                      buildNewFooter()
                    ],
                  )));
  }

  onShare() async {
    var enableToShare = checkEnableToShare();
    if (enableToShare['status']) {
      if (_planDetail!.joinMethod == "NONE") {
        bool updateJoinMethod =
            await _planService.updateJoinMethod(widget.planId);
        print(updateJoinMethod);
      }
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => SharePlanScreen(
                planMembers: _planMembers,
                isEnableToJoin: widget.isEnableToJoin,
                locationName: widget.location.name,
                planId: widget.planId,
              )));
    } else {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text(
                        'Không thể chia sẻ kế hoạch',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans'),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text(
                        enableToShare['message'],
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSans',
                            color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              btnOkColor: Colors.orange,
              btnOkText: 'Ok',
              btnOkOnPress: () {})
          .show();
    }
  }

  onJoinPlan() async {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        animType: AnimType.topSlide,
        title: "Xác nhận tham gia",
        desc:
            "Kinh phí cho chuyến đi này là ${(total / _planDetail!.memberLimit).ceil()} GCOIN. Kinh phí sẽ được trừ vào số GCOIN có sẵn của bạn. Bạn có sẵn sàng tham gia không?",
        btnOkText: "Xác nhận",
        btnOkOnPress: () async {
          int? rs = await _planService.joinPlan(widget.planId);
          if (rs != null) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.topSlide,
              showCloseIcon: true,
              title: "Tham gia kế hoạch thành công",
              desc: "Ấn tiếp tục để trở về",
              btnOkText: "Tiếp tục",
              btnOkOnPress: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (ctx) => const TabScreen(pageIndex: 0)),
                    (route) => false);
              },
            ).show();
          }
        }).show();
  }

  Widget buildNewFooter() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: SizedBox(
          height: 6.h,
          child: widget.isEnableToJoin
              ? ElevatedButton(
                  onPressed: () {
                    onJoinPlan();
                  },
                  style: elevatedButtonStyle,
                  child: const Text(
                    "Tham gia kế hoạch",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        onPressed: onShare,
                        style: elevatedButtonStyle,
                        label: const Text(
                          "Chia sẻ kế hoạch",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      );

  Widget buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
      height: 0.5,
      margin: const EdgeInsets.only(left: 16),
      width: _currentIndexEmergencyCard == index ? 35 : 12,
      decoration: BoxDecoration(
          color: _currentIndexEmergencyCard == index
              ? Colors.grey
              : Colors.grey.withOpacity(0.7),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, offset: Offset(2, 3), blurRadius: 3)
          ]),
    );
  }

  checkEnableToShare() {
    var enableToShare = {
      'status': true,
      'message': 'Kế hoạch đủ điều kiện để chia sẻ'
    };

    if (_planDetail!.memberLimit == _joinedMember.length) {
      return {
        'status': false,
        'message': 'Đã đủ số lượng thành viên của chuyến đi'
      };
    } else if (_planDetail!.orders != null && _planDetail!.orders!.isNotEmpty) {
      if (_planDetail!.orders!.any((element) => element.createdAt
          .add(const Duration(hours: 72))
          .isAfter(DateTime.now()))) {
        return {
          'status': false,
          'message': 'Kế hoạch có đơn hàng đang trong thời gian xác nhậnß'
        };
      }
    }
    return enableToShare;
  }
}
