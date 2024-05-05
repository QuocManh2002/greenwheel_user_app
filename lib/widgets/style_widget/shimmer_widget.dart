import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {

  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({super.key, 
    required this.width,
    required this.height,
  }): shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.circular({super.key, 
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder()
  });

  const ShimmerWidget.rectangularWithBorderRadius({super.key, 
    required this.width,
    required this.height,
  }): shapeBorder = const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14))
  );

  @override
  Widget build(BuildContext context) =>
  Shimmer.fromColors(
    
    baseColor: Colors.grey[300]!, 
    highlightColor: Colors.grey[200]!,
    child: Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        shape: shapeBorder,
        color: Colors.grey[300]!
      ),
    ), 
    );
}