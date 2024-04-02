import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/models/menu_item_cart.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/models/session.dart';
import 'package:greenwheel_user_app/screens/loading_screen/service_menu_loading_screen.dart';
import 'package:greenwheel_user_app/screens/main_screen/cart.dart';
import 'package:greenwheel_user_app/service/plan_service.dart';
import 'package:greenwheel_user_app/service/product_service.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/product.dart';
import 'package:greenwheel_user_app/view_models/supplier.dart';
import 'package:greenwheel_user_app/widgets/order_screen_widget/menu_item_card.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class ServiceMenuScreen extends StatefulWidget {
  const ServiceMenuScreen(
      {super.key,
      required this.supplier,
      required this.serviceType,
      this.currentCart = const [],
      this.iniPickupDate,
      this.iniReturnDate,
      this.iniNote = "",
      required this.numberOfMember,
      required this.endDate,
      required this.startDate,
      this.session,
      this.period,
      this.isOrder,
      this.isFromTempOrder,
      this.initCart,
      this.orderGuid,
      this.availableGcoinAmount,
      required this.callbackFunction});
  final Session? session;
  final DateTime startDate;
  final DateTime endDate;
  final SupplierViewModel supplier;
  final ServiceType serviceType;
  final List<ItemCart> currentCart;
  final List<ItemCart>? initCart;
  final DateTime? iniPickupDate;
  final DateTime? iniReturnDate;
  final String iniNote;
  final int numberOfMember;
  final bool? isOrder;
  final String? period;
  final bool? isFromTempOrder;
  final int? availableGcoinAmount;
  final void Function() callbackFunction;
  final String? orderGuid;

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
  List<List<ProductViewModel>> _listResult = [];

  var currencyFormat = NumberFormat.currency(symbol: 'VND', locale: 'vi_VN');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  void findSumCombinations(List<ProductViewModel> roomList, int targetSum,
      {List<ProductViewModel> combination = const [], int startIndex = 0}) {
    int currentSum = 0;
    combination.forEach((element) => currentSum += element.partySize!);
    if (currentSum == targetSum) {
      _listResult.add(combination);
      return;
    }

    if (currentSum > targetSum) {
      return;
    }

    for (int i = startIndex; i < roomList.length; i++) {
      List<ProductViewModel> newCombination = List.from(combination)
        ..add(roomList[i]);
      findSumCombinations(roomList, targetSum,
          combination: newCombination, startIndex: i);
    }
  }

  List<ProductViewModel> getResult(List<List<ProductViewModel>> list) {
    List<ProductViewModel> listRoomsCheapest = [];
    double minPriceRooms = 0;
    list[0].forEach((element) {
      minPriceRooms += element.price;
    });
    for (final rooms in list) {
      double price = 0;
      rooms.forEach((element) {
        price += element.price;
      });
      if (price <= minPriceRooms) {
        minPriceRooms = price;
        listRoomsCheapest = rooms;
      }
    }
    return listRoomsCheapest;
  }

  setUpData() async {
    list = await productService.getProductsBySupplierId(widget.supplier.id,
        widget.session == null ? widget.period! : widget.session!.name);

    if (list.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }

    // if (widget.currentCart.isNotEmpty) {
    //   double tmp = 0;
    //   if (widget.currentCart.isNotEmpty) {}
    //   for (var cartItem in widget.currentCart) {
    //     tmp += cartItem.product.price * cartItem.qty!;
    //   }
    //   setState(() {
    //     items = widget.currentCart;
    //     total = tmp;
    //   });
    // }
    pickupDate = widget.iniPickupDate;
    returnDate = widget.iniReturnDate;
    note = widget.iniNote;

    if (widget.serviceType.id == 1) {
      title = "Món ăn";
      if (widget.isFromTempOrder != null && widget.isFromTempOrder!) {
        List<int> qtys= [];
        for (final item in widget.currentCart) {
          int index = widget.currentCart.indexOf(item);
          // if (list
          //             .firstWhere((element) => element.id == item.product.id)
          //             .partySize! *
          //         item.qty! >
          //     widget.numberOfMember) {
            // setState(() {
            //   item.qty = (widget.numberOfMember /
            //           list
            //               .firstWhere(
            //                   (element) => element.id == item.product.id)
            //               .partySize!)
            //       .ceil();
            // });
            qtys.add(item.qty = (widget.numberOfMember /
                      list
                          .firstWhere(
                              (element) => element.id == item.product.id)
                          .partySize!)
                  .ceil());
          // }
          updateCart(
              list.firstWhere((element) => element.id == item.product.id),
              qtys[index]);
        }
      }
    } else {
      title = "Phòng nghỉ";
      findSumCombinations(list, widget.numberOfMember);
      List<ProductViewModel> rs = getResult(_listResult);
      Map gr = rs.groupListsBy((element) => element.id);
      for (final item in gr.keys) {
        updateCart(list.firstWhere((element) => element.id == item),
            rs.where((element) => element.id == item).toList().length);
      }
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
                        Navigator.of(context).pop();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        widget.supplier.name!,
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
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        SizedBox(
                          height: 30.h,
                          width: double.infinity,
                          child: Image.network(
                            '$baseBucketImage${widget.supplier.thumbnailUrl!}',
                            fit: BoxFit.fitWidth,
                            height: 30.h,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 20.h),
                            width: 90.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  color: Colors.black12,
                                  offset: Offset(2, 4),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                      top: 2.h,
                                      right: 2.h,
                                      left: 2.h,
                                      bottom: 1.h),
                                  child: Text(
                                    widget.supplier.name!,
                                    style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.h, vertical: 1.5.h),
                                  child: Row(
                                    children: [
                                      Text(
                                        '0${widget.supplier.phone!.substring(3)}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                      left: 2.h,
                                      right: 2.h,
                                      top: 1.5.h,
                                      bottom: 2.h),
                                  child: Text(
                                    widget.supplier.address!,
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.black54),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
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
                    (widget.serviceType.id == 5)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 14, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Check-in ${widget.session!.name.toLowerCase()}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'NotoSans',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                if (widget.isFromTempOrder == null ||
                                    !widget.isFromTempOrder!)
                                  const Text(
                                    "Chúng tôi đã đề xuất cho bạn combo phòng có giá hợp lý nhất ứng với số lượng thành viên của chuyến đi.",
                                    style: TextStyle(color: Colors.grey),
                                  )
                              ],
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      width: 8,
                    ),
                    (widget.serviceType.id == 1)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 14, top: 10),
                            child: Text(
                              "Phục vụ vào ${widget.session!.name.toLowerCase()}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'NotoSans',
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(),
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
                          // setState(() {
                            qty = itemCart.qty;
                          // });
                        }
                        return MenuItemCard(
                          product: list[index],
                          quantity: qty,
                          serviceType: widget.serviceType,
                          numberOfMember: widget.numberOfMember,
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => CartScreen(
                            isFromTempOrder: widget.isFromTempOrder,
                            startDate: widget.startDate,
                            endDate: widget.endDate,
                            numberOfMember: widget.numberOfMember,
                            supplier: widget.supplier,
                            list: items,
                            total: total,
                            updateCart: updateCart,
                            serviceType: widget.serviceType,
                            note: note,
                            orderGuid: widget.orderGuid,
                            isOrder: widget.isOrder,
                            session: widget.session!,
                            callbackFunction: widget.callbackFunction,
                            availableGcoinAmount: widget.availableGcoinAmount,
                            isChangeCart: !compareTwoCart()!,
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
                            currencyFormat.format(total),
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
      return items.firstWhere((cart) => cart.product.id == selectId);
    } catch (e) {
      return null;
    }
  }

  void updateCart(ProductViewModel prod, int qty) {
    setState(() {
      final existingItemIndex =
          items.indexWhere((cartItem) => cartItem.product.id == prod.id);

      if (existingItemIndex != -1) {
        final existingItem = items[existingItemIndex];
        total -= existingItem.product.price * existingItem.qty!;

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

  bool? compareTwoCart() {
    List<int> currentIds = [];
    List<String>? ids = sharedPreferences.getStringList('initCartIds');
    if (ids != null) {
      for (final curItem in items) {
        if (!currentIds.contains(curItem.product.id)) {
          currentIds.add(curItem.product.id);
        }
      }
      currentIds.sort();
      bool isEqual = ids.length == currentIds.length &&
          ids.every(
              (String element) => currentIds.contains(int.parse(element)));
      return isEqual;
    } else {
      return true;
    }
  }
}
