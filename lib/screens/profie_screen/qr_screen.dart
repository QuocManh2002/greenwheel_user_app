import 'dart:io';
import 'dart:ui';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greenwheel_user_app/config/token_generator.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/screens/plan_screen/detail_plan_screen.dart';
import 'package:greenwheel_user_app/widgets/button_style.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer2/sizer2.dart';

class QRScreen extends StatefulWidget {
  QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final GlobalKey _qrkey = GlobalKey();

  Future<Uint8List> convertQRToBytes() async {
    RenderRepaintBoundary boundary =
        _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 3);
    final whietPaint = Paint()..color = Colors.white;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
    canvas.drawRect(
        Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
        whietPaint);
    canvas.drawImage(image, Offset.zero, Paint());
    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }

  Future<void> onScan() async {
    try {
      final qrCorde = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      if (qrCorde.isNotEmpty) {
        final jwt = JWT.decode(qrCorde);
        if (jwt.payload['planId'] != null) {
          print("Payload: ${jwt.payload}");
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => DetailPlanScreen(
                    isEnableToJoin: true,
                    locationName: jwt.payload["locationName"],
                    planId: jwt.payload["planId"],
                  )));
        } else {
          print('Payload for travelerId!');
        }
      }
    } on PlatformException {
      print("exception");
    }
  }

  onSend() async {
    Uint8List? pngBytes = await convertQRToBytes();
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(pngBytes);
    await Share.shareXFiles([XFile(path)],
        text:
            "Chào bạn, hi vọng là chúng ta sẽ có khoảng thời gian khám phá thật vui vẻ cùng nhau.");
  }

  onSave() async {
    try {
      Uint8List? uint8list = await convertQRToBytes();
      final result = await ImageGallerySaver.saveImage(uint8list);
      if (result['isSuccess']) {
        Fluttertoast.showToast(
          msg: 'Lưu hình ảnh thành công!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1, // Duration in seconds
        );
        print('Image saved!');
        String deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
        sharedPreferences.setString('deviceToken', deviceToken);
        print(deviceToken);
      } else {
        print('Something wrong when saving image!');
        print('${result['error']}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white.withOpacity(0.94),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('QR của tôi'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
                onPressed: onScan,
                icon: const Icon(
                  Icons.qr_code_scanner_outlined,
                  size: 35,
                )),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Padding(
            //   padding: const EdgeInsets.all(32),
            //   child: TextField(
            //     cursorColor: primaryColor,
            //     controller: phoneSearch,
            //     onChanged: (value) {
            //       setState(() {
            //         _isSearch = true;
            //       });
            //       if (value.isEmpty) {
            //         setState(() {
            //           _isSearch = false;
            //         });
            //       }
            //     },
            //     style: const TextStyle(fontSize: 18),
            //     keyboardType: TextInputType.phone,
            //     decoration: const InputDecoration(
            //       suffixIcon: Icon(Icons.search),
            //       suffixIconColor: primaryColor,
            //       hintText: "Tìm số điện thoại",
            //       focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(14)),
            //           borderSide: BorderSide(color: primaryColor, width: 1.8)),
            //       enabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(14)),
            //           borderSide: BorderSide(color: primaryColor)),
            //     ),
            //   ),
            // ),
            SizedBox(height: 10.h,),
            RepaintBoundary(
              key: _qrkey,
              child: QrImageView(
                data: TokenGenerator.generateToken("quoc manh1", "plan"),
                version: QrVersions.auto,
                size: 80.w,
                gapless: true,
                errorStateBuilder: (context, error) {
                  return const Text(
                    "Something went wrong! please try again!",
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButton.icon(
                          style: elevatedButtonStyle.copyWith(
                              minimumSize:
                                  const MaterialStatePropertyAll(Size(0, 50))),
                          onPressed: onSave,
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text("Tải xuống"))),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                      child: ElevatedButton.icon(
                          style: elevatedButtonStyleNoSize.copyWith(
                              minimumSize:
                                  const MaterialStatePropertyAll(Size(0, 50))),
                          onPressed: onSend,
                          icon: const Icon(Icons.share),
                          label: const Text("Gửi mã")))
                ],
              ),
            )
          ]),
        ],
      ),
    ));
  }
}
