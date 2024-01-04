import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/share_plan_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/service/supplier_service.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../widgets/style_widget/button_style.dart';

class DetailPlanNewScreen extends StatefulWidget {
  const DetailPlanNewScreen(
      {super.key,
      required this.planId,
      required this.locationName,
      required this.isEnableToJoin});
  final int planId;
  final String locationName;
  final bool isEnableToJoin;

  @override
  State<DetailPlanNewScreen> createState() => _DetailPlanScreenState();
}

class _DetailPlanScreenState extends State<DetailPlanNewScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  PlanService _planService = PlanService();
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  // List<OrderCreatePlan> _orderList = [];
  PlanDetail? _planDetail;
  late TabController tabController;
  late TextEditingController newItemController;
  List<PlanMemberViewModel> _planMembers = [];
  int total = 0;
  SupplierService _supplierService = SupplierService();
  List<SupplierViewModel>? _saveSupplier;
  // List<PlanSchedule> scheduleList = [];

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
    _planMembers = await _planService.getPlanMember(widget.planId);

    setState(() {
      _listMotel = listMotel;
      _listRestaurant = listRestaurant;
      // _orderList = orderList;
    });
    if (_planDetail != null) {
      if (_planDetail!.savedContacts != null) {
        List<int> ids = _planDetail!.savedContacts!
            .map((e) => int.parse(e.toString()))
            .toList();
        final rs = await _supplierService.getSuppliersByIds(ids);
        setState(() {
          _saveSupplier = rs;
        });
      }

      setState(() {
        isLoading = false;
      });
      print(_saveSupplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Kế hoạch'),
            ),
            body: isLoading
                ? const Center(
                    child: Text("Loading..."),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                          children: [
                            Hero(
                                tag: widget.planId,
                                child: FadeInImage(
                                  placeholder: MemoryImage(kTransparentImage),
                                  height: 35.h,
                                  image:
                                      NetworkImage(_planDetail!.imageUrls[0]),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )),
                            const SizedBox(
                              height: 32,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _planDetail!.name,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
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
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                            text: "Khởi hành:  ",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${_planDetail!.startDate.day}/${_planDetail!.startDate.month}/${_planDetail!.startDate.year}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal))
                                            ])),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                            text: "Kết thúc:     ",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${_planDetail!.endDate.day}/${_planDetail!.endDate.month}/${_planDetail!.endDate.year}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal))
                                            ])),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                            text: "Thành viên: ",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${_planDetail!.memberLimit} người',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal))
                                            ])),
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
                                  if (_saveSupplier != null)
                                    Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Dịch vụ khẩn cấp đã lưu: ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  if (_saveSupplier != null)
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  if (_saveSupplier != null)
                                    for (final sup in _saveSupplier!)
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding:const EdgeInsets.only(left: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(sup.name, style: const TextStyle(fontSize: 16),),
                                            Text(sup.phone, style: const TextStyle(fontSize: 16),),
                                            Text(sup.address, style: const TextStyle(fontSize: 16),),
                                            const SizedBox(
                                              height: 12,
                                            )
                                          ],
                                        ),
                                      ),
                                  if (_saveSupplier != null)
                                    Container(
                                      height: 1.8,
                                      color: Colors.grey.withOpacity(0.4),
                                    ),
                                  if (_saveSupplier != null)
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Thành viên đã tham gia: ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        for (final member in _planMembers)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 12),
                                            child: Text(
                                              member.status == "LEADING"
                                                  ? member.travelerId ==
                                                          int.parse(
                                                              sharedPreferences
                                                                  .getString(
                                                                      'userId')!)
                                                      ? "- ${member.name} (Bạn)"
                                                      : "- ${member.name} - LEADING - 0${member.phone.substring(3)}"
                                                  : member.travelerId ==
                                                          int.parse(
                                                              sharedPreferences
                                                                  .getString(
                                                                      'userId')!)
                                                      ? "- ${member.name} (Bạn)"
                                                      : "- ${member.name} - 0${member.phone.substring(3)}",
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          )
                                      ],
                                    ),
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
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        "Lịch trình",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
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
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        "Các loại dịch vụ",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  TabBar(
                                      controller: tabController,
                                      indicatorColor: primaryColor,
                                      labelColor: primaryColor,
                                      unselectedLabelColor: Colors.grey,
                                      tabs: [
                                        Tab(
                                          text: "(${_listMotel.length})",
                                          icon: const Icon(Icons.bed),
                                        ),
                                        Tab(
                                          text: "(${_listRestaurant.length})",
                                          icon: const Icon(Icons.restaurant),
                                        )
                                      ]),
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    height: _listRestaurant.length == 0 &&
                                            _listMotel.length == 0
                                        ? 0.h
                                        : 35.h,
                                    child: TabBarView(
                                        controller: tabController,
                                        children: [
                                          ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: _listMotel.length,
                                            itemBuilder: (context, index) {
                                              return _listMotel[index];
                                            },
                                          ),
                                          ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: _listRestaurant.length,
                                            itemBuilder: (context, index) {
                                              return _listRestaurant[index];
                                            },
                                          ),
                                        ]),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
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
    if (_planDetail!.joinMethod == "NONE") {
      bool updateJoinMethod =
          await _planService.updateJoinMethod(widget.planId);
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => SharePlanScreen(
              isEnableToJoin: widget.isEnableToJoin,
              locationName: widget.locationName,
              planId: widget.planId,
            )));
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
            // ignore: use_build_context_synchronously
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
        child: Container(
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
}
