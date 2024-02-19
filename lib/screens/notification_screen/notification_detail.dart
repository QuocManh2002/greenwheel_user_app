import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/view_models/notification_viewmodels/notification_viewmodel.dart';
import 'package:greenwheel_user_app/view_models/plan_member.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/base_information.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_card.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/plan_schedule.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/supplier_order_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({super.key, required this.notification});
  final NotificationViewModel notification;

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen>  with TickerProviderStateMixin{
  final PlanService _planService = PlanService();
  PlanDetail? _targetViewModel;
  bool _isLoading = true;
  String? type;
  late TabController tabController;
  late TextEditingController newItemController;
  List<PlanMemberViewModel> _planMembers = [];
  List<PlanMemberViewModel> _joinedMember = [];
  double total = 0;
  List<SupplierViewModel>? _saveSupplier;
  int _currentIndexEmergencyCard = 0;
  List<Widget> _listRestaurant = [];
  List<Widget> _listMotel = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    newItemController = TextEditingController();
    setUpData();
  }

  setUpData() async{  
    if(widget.notification.type == "INVITATION"){
      _targetViewModel = await _planService.GetPlanById(widget.notification.targetId!);
      List<Widget> listRestaurant = [];
    List<Widget> listMotel = [];

    for (var item in _targetViewModel!.orders!) {
      if (item.serviceType!.id == 5) {
        // listRestaurant.add(SupplierOrderCard(order: item));
      } else {
        // listMotel.add(SupplierOrderCard(order: item));
      }
      total += item.total;
    }
    _planMembers = await _planService.getPlanMember(widget.notification.targetId!);
    _joinedMember =
        _planMembers.where((member) => member.status == 'JOINED').toList();
            setState(() {
      _listMotel = listMotel;
      _listRestaurant = listRestaurant;
    });
      if(_targetViewModel != null){
        setState(() {
          type = 'plan';
          _isLoading = false;
        });
      }
    }else{
      setState(() {
        type = 'order';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Chi tiết thông báo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:
       _isLoading ? 
      const Center(
        child: Text('Loading...'),
       ):
       type == 'plan' ?
       Column(
         children: [
           Expanded(
             child: SingleChildScrollView(
              child: Column(
                children: [
                  CachedNetworkImage(
                              height: 35.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl: _targetViewModel!.imageUrls[0],
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
                              height: 32,
                            ),
                            BaseInformationWidget(plan: _targetViewModel!),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  if (_targetViewModel!.savedContacts != null)
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
                                        SizedBox(
                                          height: 18.h,
                                          width: double.infinity,
                                          child: PageView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _targetViewModel!
                                                .savedContacts!.length,
                                            onPageChanged: (value) {
                                              setState(() {
                                                _currentIndexEmergencyCard =
                                                    value;
                                              });
                                            },
                                            itemBuilder: (context, index) {
                                              return EmergencyContactCard(
                                                  emergency: _targetViewModel!
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
                                        if (_targetViewModel!.savedContacts!.length >
                                            1)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      _targetViewModel!
                                                          .savedContacts!
                                                          .length;
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
                                        for (final member in _joinedMember)
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
                                      schedule: _targetViewModel!.schedule,
                                      startDate: _targetViewModel!.startDate!,
                                      endDate: _targetViewModel!.endDate!,
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
                                          icon: const Icon(Icons.hotel),
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
              ),
                   ),
           ),
           buildNewFooter()
         ],
       )
      :const
       Center(
        child: Text('Chưa handle chỗ này', style: TextStyle(fontSize: 18),),
      )
      ,
    ));
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

   Widget buildNewFooter() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          height: 6.h,
          child:  ElevatedButton(
                  onPressed: () {
                    onJoinPlan();
                  },
                  style: elevatedButtonStyle,
                  child: const Text(
                    "Tham gia kế hoạch",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
             
        ),
      );
      onJoinPlan() async {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        animType: AnimType.topSlide,
        title: "Xác nhận tham gia",
        desc:
            "Kinh phí cho chuyến đi này là ${(total / _targetViewModel!.memberLimit).ceil()} GCOIN. Kinh phí sẽ được trừ vào số GCOIN có sẵn của bạn. Bạn có sẵn sàng tham gia không?",
        btnOkText: "Xác nhận",
        btnOkOnPress: () async {
          int? rs = await _planService.joinPlan(widget.notification.targetId!);
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
}
