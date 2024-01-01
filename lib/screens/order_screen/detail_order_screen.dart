import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final OrderViewModel order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
TextEditingController noteController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.order.note == null){
      noteController.text = 'Không có ghi chú';
    }else{
      noteController.text = widget.order.note!;
    }
  }
  @override
  Widget build(BuildContext context) {
    

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                SizedBox(
                  height: 30.h,
                  width: double.infinity,
                  child: Image.network(
                    widget.order.supplierThumbnailUrl,
                    fit: BoxFit.fitWidth,
                    height: 30.h,
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 20.h),
                    width: 90.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
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
                              top: 2.h, right: 2.h, left: 2.h, bottom: 1.h),
                          child: Text(
                            widget.order.supplierName,
                            style: const TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.7),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12))),
                            height: 0.2.h,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.h, vertical: 1.5.h),
                          child: Text(
                            widget.order.supplierPhone,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.black54),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.7),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12))),
                            height: 0.2.h,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              left: 2.h, right: 2.h, top: 1.5.h, bottom: 2.h),
                          child: Text(
                            widget.order.supplierAddress,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black54),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(2.h),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.purple,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text(
                          'Ngày đặt: ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: primaryColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Ngày phục vụ: ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '10/3/2023',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: yellowColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Ghi chú:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      height: 10.h,
                      margin:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            10.0), // Set the border radius
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      child: TextField(
                        readOnly: true,
                        controller: noteController,
                        maxLines: null, // Allow for multiple lines of text
                        decoration: const InputDecoration(
                          hintText: 'Thêm ghi chú',
                          border: InputBorder.none, // Remove the bottom border
                          contentPadding:
                              EdgeInsets.all(8.0), // Set the padding
                        ),
                        style: const TextStyle(
                          height:
                              1.8, // Adjust the line height (e.g., 1.5 for 1.5 times the font size)
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.7),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      height: 0.5.h,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Text(
                      'Sản phẩm',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    for(final detail in widget.order.details!)


                     Column(
                       children: [
                         Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Text(
                                '${detail.quantity}x',
                                style:const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                               Text(
                                detail.productName,
                                style:const TextStyle(fontSize: 18),
                              ),
                              const Spacer(),
                              Text(
                                NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(detail.price),
                                style:const TextStyle(fontSize: 14),
                              )
                            ],
                          ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.7),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      height: 0.2.h,
                    ),
                       ],
                     ),
                    const SizedBox(
                      height: 12,
                    ),
                     Row(
                      children: [
                        const Text(
                          'Tổng',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(widget.order.total)} VND',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ]),
            ),
          ],
        ),
      ),
    ));
  }
}
