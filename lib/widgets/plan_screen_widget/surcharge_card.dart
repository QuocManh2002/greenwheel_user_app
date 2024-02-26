import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/urls.dart';
import 'package:intl/intl.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class SurchargeCard extends StatelessWidget {
  const SurchargeCard({super.key, required this.amount, required this.note});
  final String amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black12,
              offset: Offset(1, 3),
            )
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        height: 15.h,
        width: double.infinity,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: Row(children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(14)),
              child: Hero(
                  tag: UniqueKey(),
                  child: FadeInImage(
                    height: 15.h,
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage('https://th.bing.com/th/id/R.e61db6eda58d4e57acf7ef068cc4356d?rik=oXCsaP5FbsFBTA&pid=ImgRaw&r=0'),
                    fit: BoxFit.cover,
                    width: 15.h,
                    filterQuality: FilterQuality.high,
                  )),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Text(note,
                      overflow: TextOverflow.clip,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 8,
                  ),
                  // Text("Đã đặt ${order.details!.length.toString()} sản phẩm"),
                  // const SizedBox(
                  //   height: 8,
                  // ),
                  Text(
                    "Tổng: ${NumberFormat.simpleCurrency(locale: 'en-US', decimalDigits: 0, name: "").format(int.parse(amount))} GCOIN",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ]),
        ),
      );
  }
}