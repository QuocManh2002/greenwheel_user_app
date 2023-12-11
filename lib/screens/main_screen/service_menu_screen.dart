import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/screens/loading_screen/service_menu_loading_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/cart.dart';
import 'package:greenwheel_user_app/screens/main_screen/service_main_screen.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:greenwheel_user_app/view_models/location.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/order_plan.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/menu_item_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class ServiceMenuScreen extends StatefulWidget {
  const ServiceMenuScreen({
    super.key,
    required this.supplier,
    required this.serviceType,
    this.currentCart = const [],
    this.iniPickupDate,
    this.iniReturnDate,
    this.iniNote = "",
    required this.location,
    required this.numberOfMember,
    required this.endDate,
    required this.startDate
  });
  final DateTime startDate;
  final DateTime endDate;
  final SupplierViewModel supplier;
  final ServiceType serviceType;
  final List<ItemCart> currentCart;
  final DateTime? iniPickupDate;
  final DateTime? iniReturnDate;
  final String iniNote;
  final LocationViewModel location;
  final int numberOfMember;

  @override
  State<ServiceMenuScreen> createState() => _ServiceMenuScreenState();
}

class _ServiceMenuScreenState extends State<ServiceMenuScreen> {
  ProductService productService = ProductService();
  PlanService planService = PlanService();

  PlanDetail? plan;
  List<ProductViewModel> list = [];
  List<ItemCart> items = [];
  DateTime? pickupDate;
  DateTime? returnDate;
  String note = "";
  String title = "";
  bool isLoading = true;
  double total = 0;

  var currencyFormat = NumberFormat.currency(symbol: 'GCOIN', locale: 'vi_VN');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  setUpData() async {
    list = await productService.getProductsBySupplierId(widget.supplier.id);

    if (list.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }

    if (widget.currentCart.isNotEmpty) {
      double tmp = 0;
      if (widget.currentCart.isNotEmpty) {}
      for (var cartItem in widget.currentCart) {
        tmp += cartItem.product.price * cartItem.qty;
      }
      setState(() {
        items = widget.currentCart;
        total = tmp;
      });
    }
    // int? id = sharedPreferences.getInt("planId");
    // List<ItemCart> tmpList = [];
    // if (id != null) {
    //   plan = await planService.GetPlanById(id);
    //   for (var item in list) {
    //     if (item.partySize == plan!.memberLimit) {
    //       setState(() {
    //         tmpList.add(ItemCart(product: item, qty: 1));
    //         total += item.originalPrice;
    //       });
    //       break;
    //     }
    //   }
    //   setState(() {
    //     items = tmpList;
    //     print(items[0].product.name);
    //     print(items[0].qty);
    //     total;
    //   });
    // }
    pickupDate = widget.iniPickupDate;
    returnDate = widget.iniReturnDate;
    note = widget.iniNote;

    if (widget.serviceType.id == 1) {
      title = "Món ăn";
    } else if (widget.serviceType.id == 2) {
      title = "Phòng nghỉ";
    } else if (widget.serviceType.id == 3) {
      title = "Phương tiện";
    } else if (widget.serviceType.id == 4) {
      title = "Hàng hóa";
    } else if (widget.serviceType.id == 5) {
      title = "Dịch vụ";
    } else {
      title = "Vật dụng";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(15.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the current page
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ServiceMainScreen(
                              startDate: widget.startDate,
                              endDate: widget.endDate,
                              serviceType: widget.serviceType,
                              location: widget.location,
                              numberOfMember: widget.numberOfMember,
                              callbackFunction:
                                  (List<OrderCreatePlan> orderList) {},
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        widget.supplier.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              onPressed: () {},
                            ),
                            hintText: "Bạn đang cần gì?",
                            contentPadding: EdgeInsets.all(4.w),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: isLoading
            ? const ServiceMenuLoadingScreen()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14, top: 14),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        int? qty;
                        ItemCart? itemCart =
                            getItemCartByMenuItemId(list[index].id);
                        if (itemCart != null) {
                          qty = itemCart.qty;
                        }
                        return MenuItemCard(
                          product: list[index],
                          quantity: qty,
                          updateCart: updateCart,
                        );
                      },
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: Visibility(
          visible: total != 0,
          child: Container(
            height: 10.h,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 90.w,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => CartScreen(
                            startDate: widget.startDate,
                            endDate: widget.endDate,
                            numberOfMember: widget.numberOfMember,
                            location: widget.location,
                            supplier: widget.supplier,
                            list: items,
                            total: total,
                            serviceType: widget.serviceType,
                            note: note,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Giỏ hàng',
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                              width:
                                  10), // Add a space between the text and dot
                          const Icon(
                            Icons.fiber_manual_record,
                            color: Colors.white, // Dot color
                            size: 10,
                          ),
                          const SizedBox(
                              width:
                                  10), // Add a space between the dot and the price
                          Text(
                            currencyFormat.format(total / 1000),
                            style: const TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ItemCart? getItemCartByMenuItemId(int selectId) {
    try {
      print(items.length);
      return items.firstWhere((cart) => cart.product.id == selectId);
    } catch (e) {
      // Handle the case when no matching item is found
      return null;
    }
  }

  void updateCart(ProductViewModel prod, int qty) {
    setState(() {
      final existingItemIndex =
          items.indexWhere((cartItem) => cartItem.product.id == prod.id);

      if (existingItemIndex != -1) {
        final existingItem = items[existingItemIndex];
        total -= existingItem.product.price * existingItem.qty;

        if (qty != 0) {
          total += prod.price * qty;
          items[existingItemIndex] = ItemCart(product: prod, qty: qty);
        } else {
          items.removeAt(existingItemIndex);
        }
      } else if (qty != 0) {
        items.add(ItemCart(product: prod, qty: qty));
        total += prod.price * qty;
      }

      if (items.isEmpty) {
        pickupDate = null;
        returnDate = null;
        note = "";
      }
    });
  }
}
