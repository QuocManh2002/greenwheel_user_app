import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/view_models/location.dart';

class Emergency extends StatelessWidget {
  const Emergency({super.key, required this.location});
  final LocationViewModel location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                const Text(
                  "Hotline: ",
                  style: TextStyle(
                      color: redColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  location.hotline,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.call,
                      color: redColor,
                    ))
              ],
            ),
          ),
          const Padding(
            padding:  EdgeInsets.symmetric(horizontal: 40),
            child:  Text(
              "Cứu hộ: ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8,),
          Padding(padding: const EdgeInsets.only(left: 50, right: 40),
          child: Text(location.emergencyContacts![0].name!, style: const TextStyle(fontSize: 16),),),
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 40),
            child: Row(
              children: [
                  Text(
                    '0${location.emergencyContacts![0].phone!.substring(3)}',
                    style: const TextStyle(
                        fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.call,
                        color: primaryColor,
                      ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 40),
            child: Text(location.emergencyContacts![0].address!, style: const TextStyle(fontSize: 16),),
          ),
          const SizedBox(height: 8,),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 40),
          //   child: Row(
          //     children: [
          //       const Text(
          //         "Trạm xá: ",
          //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //       ),
          //       const Spacer(),
          //       Text(
          //         location.clinicPhone!,
          //         style: const TextStyle(
          //             fontSize: 17, fontWeight: FontWeight.bold),
          //       ),
          //       const Spacer(),
          //       IconButton(
          //           onPressed: () {},
          //           icon: const Icon(
          //             Icons.call,
          //             color: primaryColor,
          //           ))
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 50),
          //   child: Text(location.clinicAddress!, style: const TextStyle(fontSize: 16),),
          // ),
      ],
    );
  }
}