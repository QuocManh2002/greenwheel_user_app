import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/emergency_contact.dart';
import 'package:greenwheel_user_app/widgets/plan_screen_widget/emergency_contact_card.dart';
import 'package:sizer2/sizer2.dart';

class SelectEmergencyService extends StatefulWidget {
  const SelectEmergencyService({super.key, required this.location});
  final LocationViewModel location;

  @override
  State<SelectEmergencyService> createState() => _SelectEmergencyServiceState();
}

class _SelectEmergencyServiceState extends State<SelectEmergencyService>
    with TickerProviderStateMixin {
  bool isLoading = true;
  List<EmergencyContactViewModel>? emergencyContacts;
  List<EmergencyContactViewModel>? selectedEmergencyContacts = [];
  List<dynamic> rsList = [];
  List<String>? _selectedIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      emergencyContacts = widget.location.emergencyContacts;
    });
     _selectedIndex =
        sharedPreferences.getStringList('selectedIndex') ?? [];
    if (_selectedIndex != null) {
      getSelectedContact(_selectedIndex!);
    }
    
  }

  callback() {
    _selectedIndex =
        sharedPreferences.getStringList('selectedIndex');
    getSelectedContact(_selectedIndex!);
  }

  getSelectedContact(List<String> selectedIndexes) {
    setState(() {
      selectedEmergencyContacts = [];
      for (final index in selectedIndexes) {
        selectedEmergencyContacts!.add(emergencyContacts![int.parse(index)]);
      }
      rsList = selectedEmergencyContacts!
        .map((e) => EmergencyContactViewModel().toJson(e))
        .toList();
    });
    sharedPreferences.setString('plan_saved_emergency', json.encode(rsList));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 2.h,
        ),
        SizedBox(
          height: 5.h,
          child: const Text(
            'Danh sách liên lạc',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height:
              emergencyContacts!.isEmpty && selectedEmergencyContacts!.isEmpty
                  ? 50.h
                  : 65.h,
          child: emergencyContacts!.isEmpty
              ? Image.asset(
                  empty_plan,
                  fit: BoxFit.cover,
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: emergencyContacts!.length,
                  itemBuilder: (context, index) {
                    return EmergencyContactCard(
                      emergency: emergencyContacts![index],
                      index: index,
                      callback: callback,
                      isSelected: _selectedIndex!
                          .any((element) => element == index.toString()),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
