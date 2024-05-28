import 'package:flutter/material.dart';

import '../../core/constants/urls.dart';
import 'tab_icon_button.dart';

// ignore: must_be_immutable
class DetailPlanTabButton extends StatefulWidget {
  DetailPlanTabButton(
      {super.key, required this.selectedTab, required this.onChangeTab});
  int selectedTab;
  final void Function(int selectedTab) onChangeTab;

  @override
  State<DetailPlanTabButton> createState() => _DetailPlanTabButtonState();
}

class _DetailPlanTabButtonState extends State<DetailPlanTabButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              onTap: () {
                widget.onChangeTab(0);
                setState(() {
                  widget.selectedTab = 0;
                });
              },
              child: TabIconButton(
                iconDefaultUrl: basicInformationGreen,
                iconSelectedUrl: basicInformationWhite,
                text: 'Thông tin',
                isSelected: widget.selectedTab == 0,
                index: 0,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              onTap: () {
                widget.onChangeTab(1);
                setState(() {
                  widget.selectedTab = 1;
                });
              },
              child: TabIconButton(
                iconDefaultUrl: scheduleGreen,
                iconSelectedUrl: scheduleWhite,
                text: 'Lịch trình',
                isSelected: widget.selectedTab == 1,
                index: 1,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              onTap: () {
                widget.onChangeTab(2);
                setState(() {
                  widget.selectedTab = 2;
                });
              },
              child: TabIconButton(
                iconDefaultUrl: serviceGreen,
                iconSelectedUrl: serviceWhite,
                text: 'Dịch vụ',
                isSelected: widget.selectedTab == 2,
                index: 2,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              onTap: () {
                widget.onChangeTab(3);
                setState(() {
                  widget.selectedTab = 3;
                });
              },
              child: TabIconButton(
                iconDefaultUrl: surchargeGreen,
                iconSelectedUrl: surchargeWhite,
                text: 'Phụ thu & ghi chú',
                isSelected: widget.selectedTab == 3,
                index: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
