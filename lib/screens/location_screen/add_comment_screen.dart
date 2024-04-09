import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/core/constants/urls.dart';
import 'package:greenwheel_user_app/helpers/util.dart';
import 'package:greenwheel_user_app/service/location_service.dart';
import 'package:greenwheel_user_app/view_models/location_viewmodels/comment.dart';
import 'package:greenwheel_user_app/widgets/style_widget/rating_bar.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:vn_badwords_filter/vn_badwords_filter.dart';

class AddCommentScreen extends StatefulWidget {
  const AddCommentScreen({super.key, required this.callback, this.comments, required this.destinationId,required this.destinationImageUrl,required this.destinationName, required this.destinationDescription});
  final List<CommentViewModel>? comments;
  final int destinationId;
  final void Function() callback;
  final String destinationDescription;
  final String destinationImageUrl;
  final String destinationName;


  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _commentController = TextEditingController();
    LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Thêm bình luận'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 25.w,
                        width: 25.w,
                        clipBehavior: Clip.hardEdge,
                        decoration:const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),

                        ),
                        child: CachedNetworkImage(
                  key: UniqueKey(),
                  height: 20.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl:
                      '$baseBucketImage/${25.w.ceil()}x${25.w.ceil()}${widget.destinationImageUrl}',
                  placeholder: (context, url) =>
                      Image.memory(kTransparentImage),
                  errorWidget: (context, url, error) =>
                      FadeInImage.assetNetwork(
                    height: 15.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: '',
                    image: defaultHomeImage,
                  ),
                ),
                      ),
                      SizedBox(width: 2.h),
                      SizedBox(
                        width: 60.w,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.destinationName,
                              overflow: TextOverflow.clip,
                              style:const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold,
                              ),
                            ),
                            RatingBar(rating: 4),
                            ReadMoreText(
                                    widget.destinationDescription,
                                    trimLines: 3,
                                    textAlign: TextAlign.justify,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: "Xem thêm",
                                    trimExpandedText: "Thu gọn",
                                    lessStyle: const TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                    moreStyle: const TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  )
                          ],
                        ),
                      )
                    ],
                  )
                ]),
              ),
            ),
            Row(
              children: [
                Form(
                      key: _formKey,
                      child: SizedBox(
                        width: 80.w,
                        child: TextFormFieldWithLength(
                          controller: _commentController,
                          inputType: TextInputType.text,
                          isAutoFocus: true,
                          hinttext: 'Để lại bình luận, góp ý của bạn cho địa điểm này...',
                          maxline: 3,
                          minline: 3,
                          maxLength: 95,
                          onValidate: (value) {
                            if (value!.length < 10) {
                              return "Bình luận của bạn phải từ 10 - 120 ký tự";
                            } else if (VNBadwordsFilter.isProfane(value)) {
                              return "Bình luận của bạn chứa từ ngữ không hợp lệ";
                            } else if (!Utils().IsValidSentence(value)) {
                              return "Bình luận của bạn chứa quá nhiều từ ngữ trùng lặp";
                            }
                          },
                        ),
                      )),
                      const Spacer(),
                      IconButton(onPressed: ()async{
                        if(_formKey.currentState!.validate()){
                          final rs = await _locationService.commentOnDestination(_commentController.text, widget.destinationId);
                        if(rs){
                          widget.callback();
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                        }
                      }, icon:const Icon(Icons.send, color: primaryColor,size: 30,))

              ],
            )
          ],
        ),
      ),
    ));
  }
}
