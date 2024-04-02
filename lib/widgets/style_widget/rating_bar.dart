import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';

// ignore: must_be_immutable
class RatingBar extends StatelessWidget {
  RatingBar({super.key, required this.rating, this.ratingCount, this.size = 18});

  final double rating;
  final double size;
  int? ratingCount;

  @override
  Widget build(BuildContext context) {
    List<Widget> _starList = [];
    int realNumber = rating.floor();
    int partNumber = ((rating - realNumber) * 10).ceil();

    for(int i = 0; i < 5; i ++){
      if(i < realNumber){
        _starList.add(Icon(Icons.star, color: yellowColor, size: size,));
      }
      else if(i == realNumber){
        _starList.add(SizedBox(
          height: size,
          width: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Icon(Icons.star, color: yellowColor, size: size,),
              ClipRect(
                clipper: _Clipper(part: partNumber),
                child: Icon(Icons.star, color: Colors.grey, size: size,),
              )
            ],
          ),
        ));
      }else{
        _starList.add(Icon(Icons.star, color: Colors.grey, size: size,));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _starList,
    );
  }
}

class _Clipper extends CustomClipper<Rect>{
  final int part;
  _Clipper({required this.part});
  
  @override
  Rect getClip(Size size) {
    // TODO: implement getClip
    return Rect.fromLTRB((size.width/10)*part, 0.0, size.width, size.height);
  }
  
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}