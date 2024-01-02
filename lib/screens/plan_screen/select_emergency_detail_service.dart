import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/service/supplier_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/order_screen_widget/supplier_card.dart';

class SelectEmergencyDetailService extends StatefulWidget {
  const SelectEmergencyDetailService(
      {super.key,
      required this.type,
      required this.location,
      required this.planId,
      required this.callback});
  final int type;
  final LocationViewModel location;
  final int planId;
  final void Function() callback;

  @override
  State<SelectEmergencyDetailService> createState() =>
      _SelectEmergencyDetailServiceState();
}

class _SelectEmergencyDetailServiceState
    extends State<SelectEmergencyDetailService> {
  bool isLoading = true;
  List<SupplierViewModel> listDiLai = [];
  List<SupplierViewModel> listTapHoa = [];
  List<SupplierViewModel> totalList = [];
  SupplierService _supplierService = SupplierService();
  PlanDetail? planDetail;
  PlanService _planService = PlanService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    planDetail = await _planService.GetPlanById(widget.planId);
    if (widget.type == 0) {
      listDiLai = await _supplierService.getSuppliers(
          widget.location.longitude, widget.location.latitude, ["REPAIR_SHOP","TAXI","VEHICLE_SHOP"]);
      if (listDiLai.isNotEmpty && planDetail != null) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      listTapHoa = await _supplierService.getSuppliers(
          widget.location.longitude, widget.location.latitude, ["GROCERY"]);
      if (listTapHoa.isNotEmpty && planDetail != null) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết dịch vụ'),
        leading: BackButton(
          onPressed: (){
            Navigator.of(context).pop();
            widget.callback();
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: Text('Loading...'),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:widget.type == 0
                            ? listDiLai.length : listTapHoa.length,
                    itemBuilder: (context, index) {
                      return SupplierCard(
                        location: widget.location,
                        startDate: planDetail!.startDate,
                        endDate: planDetail!.endDate,
                        serviceType:
                            widget.type == 0 ? services[4] : services[3],
                        numberOfMember: planDetail!.memberLimit,
                        supplier: widget.type == 0
                            ? listDiLai[index]
                            : listTapHoa[index],
                      );
                    },
                  )
                ],
              ),
            ),
    ));
  }
}
