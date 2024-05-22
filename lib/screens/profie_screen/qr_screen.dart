
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';
import 'package:sizer2/sizer2.dart';
import '../plan_screen/detail_plan_screen.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  ScanController controller = ScanController();
  String qrcode = 'Unknown';
  bool isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white.withOpacity(0.94),
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text('Quét mã QR'),
            ),
            body: Stack(
              children: [
                ScanView(
                  controller: controller,
                  scanAreaScale: .7,
                  scanLineColor: primaryColor,
                  onCapture: (data) {
                    final jwt = JWT.decode(data);
                    if (jwt.payload['planId'] != null) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => DetailPlanNewScreen(
                                isEnableToJoin: true,
                                isFromHost: jwt.payload['isFromHost'],
                                planId: jwt.payload["planId"],
                                planType: 'SCAN',
                              )));
                    }
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4.h, left: 6.w),
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: const ButtonStyle(
                              padding:
                                  MaterialStatePropertyAll(EdgeInsets.all(15)),
                              shape: MaterialStatePropertyAll(CircleBorder()),
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.transparent),
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.white)),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 28,
                          ),
                          onPressed: () async {
                            XFile? res = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (res != null) {
                              String? str = await Scan.parse(res.path);
                              if (str != null) {
                                final jwt = JWT.decode(str);
                                if (jwt.payload['planId'] != null) {
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) => DetailPlanNewScreen(
                                            isEnableToJoin: true,
                                            isFromHost:
                                                jwt.payload['isFromHost'],
                                            planId: jwt.payload["planId"],
                                            planType: 'SCAN',
                                          )));
                                }
                              }
                            }
                          },
                        ),
                        SizedBox(
                          height: 0.5.h,
                        ),
                        const Text(
                          'Chọn ảnh QR',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'NotoSans'),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4.h, right: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                              padding: const MaterialStatePropertyAll(
                                  EdgeInsets.all(15)),
                              shape: const MaterialStatePropertyAll(
                                  CircleBorder()),
                              backgroundColor: MaterialStatePropertyAll(
                                  isFlashOn
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.transparent),
                              foregroundColor: MaterialStatePropertyAll(
                                  isFlashOn ? Colors.black : Colors.white)),
                          child: const Icon(
                            Icons.flashlight_on_outlined,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              isFlashOn = !isFlashOn;
                            });
                            controller.toggleTorchMode();
                          },
                        ),
                        SizedBox(
                          height: 0.5.h,
                        ),
                        const Text(
                          'Đèn pin',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'NotoSans'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }
}