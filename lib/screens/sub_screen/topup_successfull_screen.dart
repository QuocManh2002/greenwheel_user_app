import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/screens/main_screen/tabscreen.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';

class TopupSuccessfulScreen extends StatefulWidget {
  const TopupSuccessfulScreen({super.key, required this.data});
  final String? data;

  @override
  State<TopupSuccessfulScreen> createState() => _TopupSuccessfulScreenState();
}

class _TopupSuccessfulScreenState extends State<TopupSuccessfulScreen> {
  TextEditingController noteController = TextEditingController();
  var currencyFormat = NumberFormat.currency(symbol: 'đ', locale: 'vi_VN');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  setUpdata() async {
    // Extracting values using regular expressions
    RegExp exp = RegExp(r"vnp_Amount: (\d+)");
    String vnpAmount = exp.firstMatch(widget.data!)?.group(1) ?? "";

    exp = RegExp(r"vnp_BankCode: (\w+)");
    String vnpBankCode = exp.firstMatch(widget.data!)?.group(1) ?? "";

    exp = RegExp(r"vnp_BankTranNo: (\w+)");
    String vnpBankTranNo = exp.firstMatch(widget.data!)?.group(1) ?? "";

    exp = RegExp(r"vnp_PayDate: (\d+)");
    String vnpPayDate = exp.firstMatch(widget.data!)?.group(1) ?? "";

    exp = RegExp(r"vnp_CardType: (\w+)");
    String vnpCardType = exp.firstMatch(widget.data!)?.group(1) ?? "";

    exp = RegExp(r"vnp_OrderInfo: (.*?),");
    String vnpOrderInfo = exp.firstMatch(widget.data!)?.group(1) ?? "";

    // Print the extracted values
    print("vnp_Amount: $vnpAmount");
    print("vnp_BankCode: $vnpBankCode");
    print("vnp_BankTranNo: $vnpBankTranNo");
    print("vnp_PayDate: $vnpPayDate");
    print("vnp_CardType: $vnpCardType");
    print("vnp_OrderInfo: $vnpOrderInfo");

    // Convert vnp_PayDate to DateTime
    DateTime payDateTime = DateTime(
      int.parse(vnpPayDate.substring(0, 4)), // Year
      int.parse(vnpPayDate.substring(4, 6)), // Month
      int.parse(vnpPayDate.substring(6, 8)), // Day
      int.parse(vnpPayDate.substring(8, 10)), // Hour
      int.parse(vnpPayDate.substring(10, 12)), // Minute
      int.parse(vnpPayDate.substring(12, 14)), // Second
    );

    // Print the converted DateTime
    print("vnp_PayDate as DateTime: $payDateTime");
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
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Kết quả giao dịch",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const TabScreen(pageIndex: 0),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        success_icon,
                        height: 8.h,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "Nạp tiền thành công",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        currencyFormat.format(100000),
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        "MGD: AOJFSJJGS234123",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'NotoSans',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.2.h, horizontal: 4.w),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thời gian giao dịch', // Replace with your first text
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSans',
                          color: Colors.grey),
                    ),
                    Text(
                      "03/02/2021 11:54", // Replace with your second text
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 28,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.2.h, horizontal: 4.w),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngân hàng liên kết', // Replace with your first text
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSans',
                          color: Colors.grey),
                    ),
                    Text(
                      "NCB", // Replace with your second text
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 28,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.2.h, horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Số tiền nạp', // Replace with your first text
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSans',
                          color: Colors.grey),
                    ),
                    Text(
                      currencyFormat
                          .format((10000)), // Replace with your second text
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 28,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.2.h, horizontal: 4.w),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phí giao dịch', // Replace with your first text
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSans',
                          color: Colors.grey),
                    ),
                    Text(
                      "Miễn phí", // Replace with your second text
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 13.h,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 90.w,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const TabScreen(pageIndex: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                  ),
                  child: const Center(
                    child: Text(
                      'Tiếp tục nạp tiền',
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
