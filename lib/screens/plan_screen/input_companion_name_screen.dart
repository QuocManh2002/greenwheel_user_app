import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/constants/colors.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:sizer2/sizer2.dart';

class InputCompanionNameScreen extends StatefulWidget {
  const InputCompanionNameScreen(
      {super.key,
      required this.weight,
      required this.callback,
      this.initNames});
  final int weight;
  final void Function(List<String> names) callback;
  final List<String>? initNames;

  @override
  State<InputCompanionNameScreen> createState() =>
      _InputCompanionNameScreenState();
}

class _InputCompanionNameScreenState extends State<InputCompanionNameScreen> {
  List<String> names = [];
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.initNames!.isNotEmpty) {
      names = widget.initNames!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOn = MediaQuery.of(context).viewInsets.bottom != 0;
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Thông tin thành viên'),
        leading: BackButton(onPressed: (){
          AwesomeDialog(context: context,
          animType: AnimType.rightSlide,
          dialogType: DialogType.warning,
            title: 'Thông tin thành viên chưa được lưu',
            titleTextStyle:const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            desc: 'Vẫn rời khỏi màn hình này chứ?',
            descTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
            btnOkColor: Colors.amber,
            btnOkOnPress: (){Navigator.of(context).pop();},
            btnOkText: 'Rời khỏi',
            btnCancelColor: Colors.blue,
            btnCancelOnPress: (){},
            btnCancelText: 'Huỷ'
          ).show();
        },),
        actions: [
          IconButton(
              onPressed: () {
                widget.callback(names);
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              )),
          SizedBox(
            width: 1.h,
          )
        ],
      ),
      body: Column(
        children: [
          if (names.isNotEmpty)
            SizedBox(
              height: isKeyboardOn ? 40.h : 75.h,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: names.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Container(
                      width: 100.w,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12))),
                      child: Text(
                        names[index],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  );
                },
              ),
            ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              SizedBox(
                width: 80.w,
                child: defaultTextFormField(
                    maxline: 1,
                    maxLength: 40,
                    hinttext: 'Tên thành viên',
                    controller: _nameController,
                    inputType: TextInputType.name),
              ),
              IconButton(
                  onPressed: () {
                    if (names.length < widget.weight) {
                      setState(() {
                        names.add(_nameController.text);
                      });
                      _nameController.clear();
                    } else {
                      AwesomeDialog(
                        context: context,
                        animType: AnimType.leftSlide,
                        dialogType: DialogType.warning,
                        title: 'Đã đủ số lượng thành viên của nhóm',
                        titleTextStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        btnOkColor: Colors.amber,
                        btnOkText: 'Ok',
                        btnOkOnPress: () {},
                      ).show();
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    color: primaryColor,
                    size: 35,
                  )),
              const Spacer(),
            ],
          ),
          SizedBox(
            height: 2.h,
          )
        ],
      ),
    ));
  }
}
