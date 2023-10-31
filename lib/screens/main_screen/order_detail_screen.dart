import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/models/order.dart';
import 'package:greenwheel_user_app/models/service_type.dart';
import 'package:greenwheel_user_app/widgets/order_detail_card.dart';
import 'package:greenwheel_user_app/widgets/rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.serviceType,
  });
  final Order order;
  final ServiceType serviceType;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  TextEditingController noteController = TextEditingController();
  var currencyFormat = NumberFormat.currency(symbol: 'VND', locale: 'vi_VN');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noteController.text = widget.order.note;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    widget.order.supplier.name,
                    style: const TextStyle(
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
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.purple,
                  ), // Add the calendar icon
                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Text(
                      "Ngày đặt:",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(widget.order.orderDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 1.8,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: primaryColor,
                  ), // Add the calendar icon
                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Text(
                      "Ngày nhận:",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(widget.order.pickupDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 1.8,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              widget.order.returnDate == null
                  ? Container()
                  : Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.redAccent,
                            ), // Add the calendar icon
                            const Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Text(
                                "Ngày trả:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(
                                    widget.order.returnDate ?? DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 1.8,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.note_add,
                    color: Colors.orange,
                  ), // Add the calendar icon
                  Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Text(
                      "Ghi chú",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                height: 10.h,
                width: 90.w,
                margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey.withOpacity(0.4),
                ),
                child: Text(
                  noteController.text, // Display the text from the controller
                  style: const TextStyle(
                    height: 1.8, // Adjust the line height if needed
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                height: 8,
                color: Colors.grey.withOpacity(0.2),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 14, top: 6, bottom: 12),
                child: Row(
                  children: [
                    Text(
                      "Danh sách đặt",
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(), // Add space between the two elements
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
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 40.h, minHeight: 20.h),
                child: Container(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.order.items.length,
                    itemBuilder: (context, index) {
                      return OrderDetailCard(
                        cartItem: widget.order.items[index],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                ),
                child: const Row(
                  children: [
                    Text(
                      "Thông tin hóa đơn",
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Tổng",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      currencyFormat.format(widget.order.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              const SizedBox(
                height: 16,
              ),
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Phương thức",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.money,
                          color: Colors.green,
                        ), // Add the calendar icon
                        Padding(
                          padding: EdgeInsets.only(left: 14),
                          child: Text(
                            "Thanh toán trực tiếp",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'NotoSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Mã GD",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      widget.order.transactionId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 8,
                color: Colors.grey.withOpacity(0.2),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Đánh giá:",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Row(
                      children: [
                        RatingBar(
                          rating: widget.order.rating,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color
                        minimumSize: const Size(100, 50),
                      ),
                      onPressed: () {
                        // Add your button action here
                      },
                      child: const Text(
                        'Gửi',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
