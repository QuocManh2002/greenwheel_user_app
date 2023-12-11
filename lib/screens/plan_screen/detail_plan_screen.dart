import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/plan_item.dart';
import 'package:greenwheel_user_app/models/supplier_order.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/share_plan_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/custom_plan_item.dart';
import 'package:greenwheel_user_app/widgets/supplier_order_card.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../widgets/button_style.dart';

class DetailPlanScreen extends StatefulWidget {
  const DetailPlanScreen(
      {super.key,
      required this.planId,
      required this.locationName,
      required this.isEnableToJoin});
  final int planId;
  final String locationName;
  final bool isEnableToJoin;

  @override
  State<DetailPlanScreen> createState() => _DetailPlanScreenState();
}

class _DetailPlanScreenState extends State<DetailPlanScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  PlanService _planService = PlanService();
  LocationService _locationService = LocationService();
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];
  // List<OrderCreatePlan> _orderList = [];
  PlanDetail? _planDetail;
  late TabController tabController;
  late TextEditingController newItemController;
  List<PlanItem>? planSchedule;
  List<PlanMemberViewModel> _planMembers = [];
  int total = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    newItemController = TextEditingController();
    setupData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
    newItemController.dispose();
  }

  void removeItem(String item, List<String> list) {
    setState(() {
      list.remove(item);
    });
  }

  void addItem(List<String> list) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Hoạt động mới"),
              content: TextField(
                // key: ValueKey(),
                controller: newItemController,
                autofocus: true,
                cursorColor: primaryColor,
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 1.8)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primaryColor)),
                ),
              ),
              actions: [
                OutlinedButton.icon(
                    icon: const Icon(
                      Icons.add,
                      color: primaryColor,
                    ),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: primaryColor,
                          width: 1.8,
                        ),
                        foregroundColor: primaryColor),
                    onPressed: () async {
                      String dupItem = "";
                      if (newItemController.text.isNotEmpty) {
                        bool check = list.any(
                            (element) => element == newItemController.text);
                        if (check) {
                          dupItem = newItemController.text;
                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              body: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  "     Bạn vừa thêm một hoạt động đã có trước đó trong ngày, hãy chắc chắn rằng bạn muốn thêm hoạt động này trước khi xác nhận kế hoạch!",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              btnOkColor: Colors.orange,
                              btnOkOnPress: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  list.add(dupItem);
                                });
                                newItemController.clear();
                              }).show();
                        } else {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                          setState(() {
                            list.add(newItemController.text);
                          });

                          newItemController.clear();
                        }
                      }
                    },
                    label: const Text(
                      "Thêm",
                      style: TextStyle(color: primaryColor),
                    ))
              ],
            ));
  }

  setupData() async {
    _planDetail = null;
    _planDetail = await _planService.GetPlanById(widget.planId);
    planSchedule = [];
    if (_planDetail!.schedule == "") {
      var location =
          await _locationService.GetLocationById(_planDetail!.locationId);
      var templatePlans = generateItems(location!.templatePlan);
      var duration =
          _planDetail!.endDate.difference(_planDetail!.startDate).inDays + 1;
      if (duration <= templatePlans.length) {
        for (int i = 0; i < duration; i++) {
          planSchedule!.add(templatePlans[i]);
        }
      } else {
        for (int i = 0; i < duration; i++) {
          if (i < templatePlans.length) {
            planSchedule!.add(templatePlans[i]);
          } else {
            planSchedule!.add(PlanItem(title: "Ngày ${i + 1}", details: []));
          }
        }
      }
    } else {
      planSchedule = generateItems(_planDetail!.schedule);
    }

    List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];
    
    for (var item in _planDetail!.orders!) {
      if (item.details![0].type == "RESTAURANT") {
        listRestaurant.add(SupplierOrderCard(
            order: SupplierOrder(
                id: item.id,
                imgUrl: item.details![0].supplierThumbnailUrl,
                price: item.total.toDouble(),
                quantity: item.details!.length,
                supplierName: item.details![0].supplierName,
                type: item.details![0].type)));
      } else {
        listMotel.add(SupplierOrderCard(
            order: SupplierOrder(
                id: item.id,
                imgUrl: item.details![0].supplierThumbnailUrl,
                price: item.total.toDouble(),
                quantity: item.details!.length,
                supplierName: item.details![0].supplierName,
                type: item.details![0].type)));
      }
      total += item.total;
    }
    _planMembers = await _planService.getPlanMember(widget.planId);

    setState(() {
      _listMotel = listMotel;
      _listRestaurant = listRestaurant;
      // _orderList = orderList;
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Chuyến đi ${widget.locationName}"),
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
                                      "Chuyến đi ${_planDetail!.locationName}",
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
                                                  ? member.travelerId == int.parse(sharedPreferences.getString('userId')!)? "${member.name} (Bạn)":"${member.name} - LEADING - 0${member.phone.substring(3)}"
                                                  : member.travelerId == int.parse(sharedPreferences.getString('userId')!)? "- ${member.name} (Bạn)": "${member.name} - 0${member.phone.substring(3)}",
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
                                  for (int i = 0; i < planSchedule!.length; i++)
                                    CustomPlanItem(
                                      title: planSchedule![i].title,
                                      details: planSchedule![i].details,
                                      onDismiss: removeItem,
                                      onAddNewItem: addItem,
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
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => SharePlanScreen(
              isEnableToJoin: widget.isEnableToJoin,
              locationName: widget.locationName,
              planId: widget.planId,
            )));
  }

  onJoinPlan() async {
    AwesomeDialog(context: context,
    dialogType: DialogType.question,
    body: Container(
      child: Text(
        "Kinh phí cho chuyến đi này là ${(total / _planDetail!.memberLimit).ceil()} GCOIN. Kinh phí sẽ được trừ vào số GCOIN có sẵn của bạn. Bạn có sẵn sàng tham gia không?"
      ),
    ),
    btnOkOnPress: () async{
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
    }
    ).show();
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
                        icon:const Icon(Icons.share),
                        onPressed: onShare,
                        style: elevatedButtonStyle,
                        label:const Text("Chia sẻ kế hoạch",
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
