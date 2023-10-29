import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/orders.dart';
import 'package:greenwheel_user_app/constants/service_types.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/widgets/order_card.dart';
import 'package:greenwheel_user_app/widgets/service_type_card.dart';
import 'package:sizer2/sizer2.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key, required this.serviceType});
  final ServiceType serviceType;

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  ServiceType? currentService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentService = widget.serviceType;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the current page
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Lịch sử đặt hàng",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 14, bottom: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 4.h,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: services.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ServiceTypeCard(
                              serviceType: services[index],
                              changeService: changeService,
                              isPress: services[index].id == currentService?.id
                                  ? true
                                  : false,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 1.8,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              Container(
                height: 80.h,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return OrderCard(
                      order: orders[index],
                      serviceType: widget.serviceType,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeService(ServiceType type) {
    setState(() {
      currentService = type;
    });
  }
}
