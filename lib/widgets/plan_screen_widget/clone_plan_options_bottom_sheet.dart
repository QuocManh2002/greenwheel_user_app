// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/clone_plan_options.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/create_plan/select_start_location_screen.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer2/sizer2.dart';

class ClonePlanOptionsBottomSheet extends StatefulWidget {
  const ClonePlanOptionsBottomSheet({
    super.key,
    required this.plan,
  });
  final PlanDetail plan;

  @override
  State<ClonePlanOptionsBottomSheet> createState() =>
      _ClonePlanOptionsBottomSheetState();
}

class _ClonePlanOptionsBottomSheetState
    extends State<ClonePlanOptionsBottomSheet> {
  List<bool> values = clonePlanOptions.map((e) => false).toList();
  final LocationService _locationService = LocationService();
  bool isSelectAll = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  color: primaryColor.withOpacity(0.5)),
              height: 8,
              width: 20.w,
            ),
            SizedBox(
              height: 1.h,
            ),
            Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Checkbox(
                      value: values.every((element) => element),
                      activeColor: primaryColor,
                      onChanged: (value) {
                        isSelectAll = !isSelectAll;
                        setState(() {
                          values =
                              clonePlanOptions.map((e) => isSelectAll).toList();
                        });
                      }),
                ),
                Container(
                  width: 100.w,
                  alignment: Alignment.center,
                  child: const Text(
                    'Các mục sao chép',
                    style: TextStyle(
                        fontSize: 19,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 0.4.h,
            ),
            for (int index = 0; index < clonePlanOptions.length; index++)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    activeColor: primaryColor,
                    value: values[index],
                    onChanged: (value) {
                      setState(() {
                        values[index] = !values[index];
                      });
                    },
                  ),
                  SizedBox(
                      width: 75.w,
                      child: Text(
                        clonePlanOptions[index],
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            fontSize: 17, fontFamily: 'NotoSans'),
                      ))
                ],
              ),
            SizedBox(
              height: 1.h,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        style: elevatedButtonStyle.copyWith(
                            backgroundColor:
                                const MaterialStatePropertyAll(Colors.transparent),
                            foregroundColor:
                                const MaterialStatePropertyAll(primaryColor),
                            shape: const MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    side: BorderSide(
                                        color: primaryColor, width: 1.5)))),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Huỷ'))),
                SizedBox(
                  width: 2.w,
                ),
                Expanded(
                    child: ElevatedButton(
                        style: elevatedButtonStyle.copyWith(
                            backgroundColor: MaterialStatePropertyAll(
                                values.any((element) => element)
                                    ? primaryColor
                                    : Colors.grey.withOpacity(0.2))),
                        onPressed: () async {
                          if (values.any((element) => element)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: SizedBox(
                                  height: 10.h,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                            final location =
                                await _locationService.getLocationById(
                                    widget.plan.locationId!);
                            String? locationName = sharedPreferences
                                .getString('plan_location_name');
                            if (!values[5] && values[6]) {
                              Navigator.of(context).pop();
                              Utils()
                                  .showInvalidScheduleAndServiceClone(context);
                            } else if (locationName != null) {
                              Navigator.of(context).pop();
                              Utils().handleAlreadyDraft(context, location!,
                                  locationName, true, widget.plan, values);
                            } else {
                              Utils().setUpDataClonePlan(widget.plan, values);
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: SelectStartLocationScreen(
                                        location: location!,
                                        isCreate: true,
                                        isClone: true,
                                      ),
                                      type: PageTransitionType.rightToLeft));
                            }
                          }
                        },
                        child: const Text('Xác nhận'))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
