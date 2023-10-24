import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/constants/constant.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:sizer2/sizer2.dart';

class CustomPlanItem extends StatefulWidget {
  const CustomPlanItem({super.key , required this.title});
  final String title;

  @override
  State<CustomPlanItem> createState() => _CustomPlanItemState();
}

class _CustomPlanItemState extends State<CustomPlanItem> {
  bool isExpanded = false;

  List<String> planDetail = ["Check in", "Đi bơi", "Đi câu cá"];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Container(
            height: 6.h,
            decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.title, style: TextStyle(fontSize: 18),),
                      AnimatedSwitcher(
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns:
                                Tween(begin: 0.8, end: 1.0).animate(animation),
                            child: child,
                          );
                        },
                        duration: const Duration(microseconds: 300),
                        child: Image.asset(
                          isExpanded ? upIcon : downIcon,
                          height: 3.h,
                          fit: BoxFit.cover,
                          key: ValueKey(isExpanded),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              alignment: Alignment.center,
              height: (planDetail.length * 5.7).h,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12))),
              child: ReorderableListView.builder(
                itemCount: planDetail.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    
                    key: ValueKey(planDetail[index]),
                    padding: const EdgeInsets.only(
                        left: 32, top: 2.5, bottom: 2.5, right: 8),
                    child: Container(
                      
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.black26, width: 1.5))),
                      height: 5.h,
                      child: Dismissible(
                        key: ValueKey(planDetail[index]),
                        background: Container(
                          padding: const EdgeInsets.only(left: 16),
                          alignment: Alignment.centerLeft,
                          height: 5.h,
                          color: redColor,
                          child: const Icon(Icons.delete),
                        ),
                        secondaryBackground: Container(
                          padding: const EdgeInsets.only(right: 16),
                          alignment: Alignment.centerRight,
                          height: 5.h,
                          color: redColor,
                          child: const Icon(Icons.delete),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            planDetail.remove(planDetail[index]);
                          });
                        },
                        child: ListTile(
                          title: Text(
                            planDetail[index],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                    final item = planDetail.removeAt(oldIndex);
                    planDetail.insert(index, item);
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
