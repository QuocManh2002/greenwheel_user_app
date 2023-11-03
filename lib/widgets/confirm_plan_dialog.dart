import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/location.dart';
import 'package:greenwheel_user_app/models/plan_item.dart';
import 'package:greenwheel_user_app/models/supplier_order.dart';
import 'package:greenwheel_user_app/view_models/location.dart';

class ConfirmPlan extends StatefulWidget {
  const ConfirmPlan(
      {super.key,
      required this.duration,
      required this.endDate,
      required this.location,
      required this.numberOfMember,
      required this.startDate,
      required this.planDetail,
      required this.orders});

  final LocationViewModel location;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfMember;
  final int duration;
  final List<PlanItem> planDetail;
  final List<SupplierOrder> orders;

  @override
  State<ConfirmPlan> createState() => _ConfirmPlanState();
}

class _ConfirmPlanState extends State<ConfirmPlan> {
  List<String> listDetail = [];
  List<String> listFood = [];
  List<String> listLuuTru = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() {
    for (var item in widget.planDetail) {
      String str = "";
      for (int index = 0; index < item.details.length; index++) {
        str += item.details[index];
        if (index != item.details.length - 1) {
          str += ", ";
        }
      }
      listDetail.add(str);
    }

    for (var item in widget.orders) {
      if (item.type == 0) {
        listLuuTru.add(
            "- ${item.supplierName} - ${item.quantity} sản phẩm - ${item.price}VND");
      } else {
        listFood.add(
            "- ${item.supplierName} - ${item.quantity} sản phẩm - ${item.price}VND");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            alignment: Alignment.topCenter,
            child: const Text(
              "Chi tiết kế hoạch",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Chuyến đi ${widget.location.name}",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: 12,
          ),
          RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: "Khởi hành:  ",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text:
                            '${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ])),
          const SizedBox(
            height: 12,
          ),
          RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: "Kết thúc:     ",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text:
                            '${widget.endDate.day}/${widget.endDate.month}/${widget.endDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ])),
          const SizedBox(
            height: 12,
          ),
          RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: "Thành viên: ",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text: '${widget.numberOfMember} người',
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ])),
          const SizedBox(
            height: 12,
          ),
          const Text(
            "Lịch trình: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          for (int i = 0; i < widget.planDetail.length; i++)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("${widget.planDetail[i].title}: ${listDetail[i]}"),
            ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            "Dịch vụ đã đặt: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (listLuuTru.isNotEmpty)
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Lưu trú: ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          if (listLuuTru.isNotEmpty)
            for (var detail in listLuuTru)
              Padding(
                padding:
                    const EdgeInsets.only(left: 20, top: 4, bottom: 4,),
                child: Text(detail),
              ),

              if(listFood.isNotEmpty)
              const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Ăn uống: ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            if (listLuuTru.isNotEmpty)
            for (var detail in listFood)
              Padding(
                padding:
                    const EdgeInsets.only(left: 20, top: 4, bottom: 4,),
                child: Text(detail),
              ),
        ]),
      ),
    );
  }
}
