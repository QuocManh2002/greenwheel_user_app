import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/urls.dart';
import '../../../main.dart';
import '../../../service/plan_service.dart';
import '../../../service/supplier_service.dart';
import '../../../view_models/location.dart';
import '../../../view_models/location_viewmodels/emergency_contact.dart';
import '../../../view_models/plan_viewmodels/plan_create.dart';
import '../../../view_models/supplier.dart';
import '../../../widgets/plan_screen_widget/craete_plan_header.dart';
import '../../../widgets/plan_screen_widget/emergency_contact_card.dart';
import '../../../widgets/style_widget/button_style.dart';
import '../../loading_screen/emergency_list_loading_screen.dart';
import 'select_plan_schedule_screen.dart';

class SelectEmergencyService extends StatefulWidget {
  const SelectEmergencyService(
      {super.key,
      required this.isCreate,
      this.plan,
      required this.location,
      required this.isClone});
  final LocationViewModel location;
  final bool isCreate;
  final PlanCreate? plan;
  final bool isClone;

  @override
  State<SelectEmergencyService> createState() => _SelectEmergencyServiceState();
}

class _SelectEmergencyServiceState extends State<SelectEmergencyService>
    with TickerProviderStateMixin {
  bool isLoading = true;
  List<EmergencyContactViewModel>? emergencyContacts = [];
  List<EmergencyContactViewModel>? selectedEmergencyContacts = [];
  List<EmergencyContactViewModel>? vehicleContacts = [];
  List<EmergencyContactViewModel>? groceryContacts = [];
  List<EmergencyContactViewModel>? totalContacts = [];
  List<dynamic> rsList = [];
  List<String>? _selectedIndex;
  final SupplierService _supplierService = SupplierService();
  final PlanService _planService = PlanService();
  List<SupplierViewModel>? suppliers = [];
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpDataUpdate() async {
    // _selectedIndex =
    //     widget.plan!.savedContacts!.map((e) => e.id.toString()).toList();
    _selectedIndex = widget.plan!.savedContactIds ?? [];
    getSelectedContact(_selectedIndex!);
  }

  setUpDataCreate() async {
    _selectedIndex = sharedPreferences.getStringList('selectedIndex') ?? [];
    if (_selectedIndex != null) {
      getSelectedContact(_selectedIndex!);
    }
  }

  setUpData() async {
    emergencyContacts = await _supplierService.getEmergencyContacts(
        PointLatLng(widget.location.latitude, widget.location.longitude),
        ['EMERGENCY'],
        30000);
    totalContacts = await _supplierService.getEmergencyContacts(
        PointLatLng(widget.location.latitude, widget.location.longitude),
        ['REPAIR', 'GROCERY'],
        10000);
    totalContacts!.addAll(emergencyContacts!);
    if (totalContacts != null) {
      setState(() {
        isLoading = false;
      });
    }
    final totalContactsGroup =
        totalContacts!.groupListsBy((element) => element.type);

    emergencyContacts = totalContactsGroup.values
            .firstWhereOrNull((element) => element.first.type == 'EMERGENCY') ??
        [];
    groceryContacts = totalContactsGroup.values
            .firstWhereOrNull((element) => element.first.type == 'GROCERY') ??
        [];
    vehicleContacts = totalContactsGroup.values
            .firstWhereOrNull((element) => element.first.type == 'REPAIR') ??
        [];

    _tabController = TabController(length: 3, vsync: this);
    if (widget.isCreate) {
      setUpDataCreate();
    } else {
      setUpDataUpdate();
    }
  }

  callback() {
    _selectedIndex = widget.plan == null
        ? sharedPreferences.getStringList('selectedIndex')
        : widget.plan!.savedContactIds;
    getSelectedContact(_selectedIndex!);
  }

  getSelectedContact(List<String> selectedIndexes) async {
    selectedEmergencyContacts = [];
    List<String> newIndexes = selectedIndexes.map((e) => e).toList();
    List<int> invalidIds = [];
    for (final index in selectedIndexes) {
      final contact = totalContacts!
          .firstWhereOrNull((element) => element.id == int.parse(index));
      if (contact == null) {
        invalidIds.add(int.parse(index));
        newIndexes.remove(index);
      } else {
        selectedEmergencyContacts!.add(contact);
      }
    }
    sharedPreferences.setStringList('selectedIndex', newIndexes);

    if (invalidIds.isNotEmpty) {
      final invalidContacts =
          await _supplierService.getEmergencyContactByIds(invalidIds);
      if (invalidContacts != null) {
        AwesomeDialog(
          // ignore: use_build_context_synchronously
          context: context,
          animType: AnimType.leftSlide,
          dialogType: DialogType.infoReverse,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Thay đổi quan trọng',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans'),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Các liên lạc khẩn cấp dưới đây không còn khả dụng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NotoSans',
                        color: Colors.grey),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                for (int index = 0; index < invalidContacts.length; index++)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: index.isOdd
                            ? primaryColor.withOpacity(0.1)
                            : lightPrimaryTextColor.withOpacity(0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: index == 0
                              ? const Radius.circular(10)
                              : Radius.zero,
                          topRight: index == 0
                              ? const Radius.circular(10)
                              : Radius.zero,
                          bottomLeft: index == invalidContacts.length - 1
                              ? const Radius.circular(10)
                              : Radius.zero,
                          bottomRight: index == invalidContacts.length - 1
                              ? const Radius.circular(10)
                              : Radius.zero,
                        )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 60.w,
                          child: Text(
                            invalidContacts[index].name ?? 'Không có thông tin',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans',
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: primaryColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 1.5.w,
                            ),
                            Text(
                              invalidContacts[index].phone == null ?
                                  'Không có thông tin' : '0${invalidContacts[index].phone!.substring(2)}',
                              style: const TextStyle(
                                  fontSize: 13, fontFamily: 'NotoSans'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                SizedBox(
                  height: 1.h,
                ),
                const Text(
                  'Hãy lựa chọn thêm các liên lạc khác để chuyến đi của bạn thêm an toàn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontFamily: 'NotoSans'),
                )
              ],
            ),
          ),
          btnOkColor: Colors.blueAccent,
          btnOkOnPress: () {},
          btnOkText: 'OK',
        ).show();
      }
    }
    setState(() {
      rsList = selectedEmergencyContacts!
          .map((e) => EmergencyContactViewModel().toJson(e))
          .toList();
    });
    sharedPreferences.setString('plan_saved_emergency', json.encode(rsList));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Lên kế hoạch'),
        leading: BackButton(
          onPressed: () {
            _planService.handleQuitCreatePlanScreen(() {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }, context);
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              _planService.handleShowPlanInformation(
                  context, widget.location, widget.plan);
            },
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                backpack,
                fit: BoxFit.fill,
                height: 32,
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? const EmergencyListLoadingScreen()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CreatePlanHeader(
                          stepNumber: 4, stepName: 'Liên lạc khẩn cấp'),
                      SizedBox(
                        height: 5.h,
                        child: const Text(
                          'Danh sách liên lạc',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TabBar(
                          indicatorColor: primaryColor,
                          labelColor: primaryColor,
                          automaticIndicatorColorAdjustment: true,
                          indicatorSize: TabBarIndicatorSize.tab,
                          unselectedLabelColor: Colors.grey,
                          controller: _tabController,
                          tabs: const [
                            Tab(
                              icon: Icon(
                                Icons.medical_services_outlined,
                              ),
                              text: 'Cứu hộ',
                            ),
                            Tab(
                              icon: Icon(
                                Icons.directions_car_outlined,
                              ),
                              text: 'Di chuyển',
                            ),
                            Tab(
                              icon: Icon(
                                Icons.local_grocery_store_outlined,
                              ),
                              text: 'Tiện ích',
                            ),
                          ]),
                      SizedBox(
                        height: 60.h,
                        child:
                            TabBarView(controller: _tabController, children: [
                          SizedBox(
                            height: 60.h,
                            child: emergencyContacts == null ||
                                    emergencyContacts!.isEmpty
                                ? buildEmptyEmergencyList()
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: emergencyContacts!.length,
                                    itemBuilder: (context, index) =>
                                        EmergencyContactCard(
                                      emergency: emergencyContacts![index],
                                      index: index,
                                      callback: callback,
                                      plan: widget.plan,
                                      isSelected: _selectedIndex!.any(
                                          (element) =>
                                              element ==
                                              emergencyContacts![index]
                                                  .id
                                                  .toString()),
                                    ),
                                  ),
                          ),
                          SizedBox(
                            height: 60.h,
                            child: vehicleContacts!.isEmpty
                                ? buildEmptyEmergencyList()
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: vehicleContacts!.length,
                                    itemBuilder: (context, index) =>
                                        EmergencyContactCard(
                                      emergency: vehicleContacts![index],
                                      index: index,
                                      callback: callback,
                                      plan: widget.plan,
                                      isSelected: _selectedIndex!.any(
                                          (element) =>
                                              element ==
                                              vehicleContacts![index]
                                                  .id
                                                  .toString()),
                                    ),
                                  ),
                          ),
                          SizedBox(
                            height: 60.h,
                            child: groceryContacts!.isEmpty
                                ? buildEmptyEmergencyList()
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: groceryContacts!.length,
                                    itemBuilder: (context, index) =>
                                        EmergencyContactCard(
                                      emergency: groceryContacts![index],
                                      index: index,
                                      callback: callback,
                                      plan: widget.plan,
                                      isSelected: _selectedIndex!.any(
                                          (element) =>
                                              element ==
                                              groceryContacts![index]
                                                  .id
                                                  .toString()),
                                    ),
                                  ),
                          ),
                        ]),
                      ),
                    ]),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        child: Row(
          children: [
            Expanded(
                child: ElevatedButton(
              style: elevatedButtonStyle.copyWith(
                  backgroundColor: const MaterialStatePropertyAll(Colors.white),
                  foregroundColor: const MaterialStatePropertyAll(primaryColor),
                  shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                      side: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(10))))),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Quay lại'),
            )),
            SizedBox(
              width: 2.w,
            ),
            Expanded(
                child: ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: () {
                if (!selectedEmergencyContacts!
                    .any((element) => element.type == 'EMERGENCY')) {
                  AwesomeDialog(
                          context: context,
                          animType: AnimType.leftSlide,
                          dialogType: DialogType.warning,
                          title:
                              'Bạn phải chọn ít nhất 1 liên lạc cứu hộ cho chuyến đi',
                          titleTextStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSans'),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          btnOkColor: Colors.amber,
                          btnOkOnPress: () {},
                          btnOkText: 'OK')
                      .show();
                } else {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: SelectPlanScheduleScreen(
                              isClone: widget.isClone,
                              plan: widget.plan,
                              isCreate: widget.isCreate,
                              location: widget.location),
                          type: PageTransitionType.rightToLeft));
                }
              },
              child: const Text('Tiếp tục'),
            )),
          ],
        ),
      ),
    ));
  }

  buildEmptyEmergencyList() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            empty_plan,
            height: 30.h,
          ),
          const Text(
            'Dịch vụ không khả dụng',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSans',
                color: Colors.grey),
          )
        ],
      );
}
