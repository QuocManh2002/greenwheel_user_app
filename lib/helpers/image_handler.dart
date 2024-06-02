import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/helpers/util.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

class ImageHandler {
  Future<String?> handlePickImage(BuildContext context) async {
    XFile? myImage;
    final ImagePicker picker = ImagePicker();
    String? imagePath ;
    myImage = await picker.pickImage(source: ImageSource.gallery);
    if (myImage != null) {
      var headers = {
        'Content-Type': 'application/json',
      };
      final bytes = await File(myImage.path).readAsBytes();
      final encodedImage = base64Encode(bytes);
      var response = await http.post(
          Uri.parse(
              'https://oafr1w3y52.execute-api.ap-southeast-2.amazonaws.com/default/btss-getPresignedUrl'),
          headers: headers,
          body: encodedImage);
      if (response.statusCode == 200) {
        imagePath = json
              .decode(response.body)['fileName']
              .split(baseBucketImage)
              .last;
      } else {
        imagePath = null;
        // ignore: use_build_context_synchronously
        Utils().handleServerException('Tải hình ảnh lên thất bại', context);
      }
    }
    return imagePath;
  }
}
