import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:sizer2/sizer2.dart';

class TabIconButton extends StatelessWidget {
  const TabIconButton(
      {super.key,
      required this.index,
      required this.isSelected,
      required this.iconDefaultUrl,
      required this.iconSelectedUrl,
      this.hasHeight,
      required this.text});
  final String text;
  final bool isSelected;
  final int index;
  final String iconDefaultUrl;
  final String iconSelectedUrl;
  final bool? hasHeight;


  @override
  Widget build(BuildContext context) {
    return Container(
      // height: hasHeight != null ? 13.h : 10.h,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            color: Colors.black12,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12,),
          SvgPicture.asset(
            isSelected ? iconSelectedUrl : iconDefaultUrl,
            height: 32,
          ),
          const SizedBox(height: 4,),
          Text(
            text,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10.9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : primaryColor),
          ),
          const SizedBox(height: 12,)
        ],
      ),
    );
  }
}
