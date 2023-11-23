import 'package:flutter/material.dart';

class LoginSuccessScreen extends StatelessWidget {
  const LoginSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // backgroundColor: ,
      body:Stack(
        children: [
          Column(
            children: [
                Text("Đăng nhập thành công", style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'NotoSans',
              ),),
              SizedBox(height: 12,),
              Text("Sau khi đăng nhập, bạn có thể khám phá mọi địa điểm tuyệt đẹp!")
            ],
          ),
        ],
      ),
    );
  }
}