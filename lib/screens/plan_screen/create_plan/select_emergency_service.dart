import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/loading_screen/emergency_list_loading_screen.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/select_plan_schedule_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/service/supplier_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_card.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

import '../../../widgets/plan_screen_widget/craete_plan_header.dart';

class SelectEmergencyService extends StatefulWidget {
  const SelectEmergencyService({super.key, required this.location});
  final LocationViewModel location;

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

  setUpData() async {
    emergencyContacts = await _supplierService.getEmergencyContacts(
        PointLatLng(widget.location.latitude, widget.location.longitude),
        ['EMERGENCY'],
        30000);
    totalContacts = await _supplierService.getEmergencyContacts(
        PointLatLng(widget.location.latitude, widget.location.longitude),
        ['TAXI', 'REPAIR', 'GROCERY'],
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
            .firstWhereOrNull((element) => element.first.type == 'TAXI') ??
        [];
    var _repairContacts = totalContactsGroup.values
            .firstWhereOrNull((element) => element.first.type == 'REPAIR') ??
        [];
    vehicleContacts!.addAll(_repairContacts);

    _tabController = TabController(length: 3, vsync: this);
    _selectedIndex = sharedPreferences.getStringList('selectedIndex') ?? [];
    if (_selectedIndex != null) {
      getSelectedContact(_selectedIndex!);
    }
  }

  callback() {
    _selectedIndex = sharedPreferences.getStringList('selectedIndex');
    getSelectedContact(_selectedIndex!);
  }

  getSelectedContact(List<String> selectedIndexes) {
    setState(() {
      selectedEmergencyContacts = [];
      for (final index in selectedIndexes) {
        selectedEmergencyContacts!.add(totalContacts!
            .firstWhere((element) => element.id == int.parse(index)));
      }

      rsList = selectedEmergencyContacts!
          .map((e) => EmergencyContactViewModel().toJson(e))
          .toList();
    });
    print(rsList);
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
              _planService.handleShowPlanInformation(context, widget.location);
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
                      AwesomeDialog(context: context,
                      animType: AnimType.leftSlide,
                      dialogType: DialogType.warning,
                      title: 'Bạn phải chọn ít nhất 1 liên lạc cứu hộ cho chuyến đi',
                      titleTextStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      btnOkColor: Colors.amber,
                      btnOkOnPress: () {
                        
                      },
                      btnOkText: 'OK'
                      ).show();
                  
                }else{
                  Navigator.push(
                      context,
                      PageTransition(
                          child: SelectPlanScheduleScreen(
                              isClone: false,
                              isCreate: true,
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
