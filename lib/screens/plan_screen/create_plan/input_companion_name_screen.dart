import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/core/constants/colors.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';
import 'package:sizer2/sizer2.dart';

class InputCompanionNameScreen extends StatefulWidget {
  const InputCompanionNameScreen(
      {super.key,
      required this.weight,
      required this.callback,
      required this.onJoin,
      this.initNames});
  final int weight;
  final void Function(List<String> names) callback;
  final List<String>? initNames;
  final void Function() onJoin;

  @override
  State<InputCompanionNameScreen> createState() =>
      _InputCompanionNameScreenState();
}

class _InputCompanionNameScreenState extends State<InputCompanionNameScreen> {
  List<String> names = [];
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Thông tin thành viên'),
        leading: BackButton(
          onPressed: () {
            if (names.isNotEmpty) {
              widget.callback(names);
            }
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (names.length < widget.weight)
            IconButton(
                onPressed: onAddName,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                )),
          SizedBox(
            width: 1.h,
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    style: elevatedButtonStyle.copyWith(
                        shape: const MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                side:
                                    BorderSide(color: primaryColor, width: 2))),
                        foregroundColor:
                            const MaterialStatePropertyAll(primaryColor),
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.white)),
                    onPressed: () {
                      if (names.isNotEmpty) {
                        widget.callback(names);
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Quay lại'))),
            SizedBox(
              width: 3.w,
            ),
            Expanded(
                child: ElevatedButton(
                    style: elevatedButtonStyle.copyWith(
                        foregroundColor: MaterialStatePropertyAll(
                            widget.weight == names.length
                                ? Colors.white
                                : Colors.grey),
                        backgroundColor: MaterialStatePropertyAll(
                            widget.weight == names.length
                                ? primaryColor
                                : lightPrimaryTextColor)),
                    onPressed: widget.weight == names.length
                        ? (){
                          widget.callback(names);
                          widget.onJoin();
                        }
                        : null,
                    child: const Text('Xuống tiền'))),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < names.length; i++)
              Container(
                width: 100.w,
                decoration: BoxDecoration(
                  color: i.isOdd
                      ? Colors.white
                      : lightPrimaryTextColor,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70.w,
                      child: Text(
                        '${i + 1}. ${names[i]}',
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_square,
                                color: Colors.blueAccent,
                                size: 32,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Cập nhật',
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 18),
                              )
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                                size: 32,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Xoá',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 18),
                              )
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.grey,
                      ),
                      onSelected: (value) {
                        if (value == 0) {
                          onUpdateName(i);
                        } else {
                          onDeleteName(i);
                        }
                      },
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    ));
  }

  onAddName() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: 100.w,
            child: Form(
              key: _formKey,
              child: defaultTextFormField(
                  maxline: 1,
                  maxLength: 30,
                  hinttext: 'Tên thành viên',
                  controller: _nameController,
                  onValidate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tên thành viên không được để trống';
                    } else if (value.length > 30) {
                      return 'Tên thành viên không quá 40 kí tự';
                    }
                    return null;
                  },
                  inputType: TextInputType.name),
            ),
          ),
          title: const Text(
            'Thêm thành viên:',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSans'),
          ),
          actions: [
            TextButton(
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(primaryColor)),
                onPressed: () {
                  _nameController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Huỷ')),
            TextButton(
                style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                        side: BorderSide(color: primaryColor))),
                    foregroundColor: MaterialStatePropertyAll(primaryColor)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (names.length < widget.weight) {
                      setState(() {
                        names.add(_nameController.text);
                      });
                      _nameController.clear();
                      Navigator.of(context).pop();
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
                  }
                },
                child: const Text('Thêm'))
          ],
        );
      },
    );
  }

  onUpdateName(int index) {
    _nameController.text = names[index];
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: SizedBox(
                width: 100.w,
                child: Form(
                  key: _formKey,
                  child: defaultTextFormField(
                      maxline: 1,
                      maxLength: 30,
                      hinttext: 'Tên thành viên',
                      controller: _nameController,
                      onValidate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên thành viên không được để trống';
                        } else if (value.length > 30) {
                          return 'Tên thành viên không quá 40 kí tự';
                        }
                        return null;
                      },
                      inputType: TextInputType.name),
                ),
              ),
              title: const Text(
                'Cập nhật thành viên:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSans'),
              ),
              actions: [
                TextButton(
                    style: const ButtonStyle(
                        foregroundColor:
                            MaterialStatePropertyAll(primaryColor)),
                    onPressed: () {
                      _nameController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Huỷ')),
                TextButton(
                    style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                            side: BorderSide(color: primaryColor))),
                        foregroundColor:
                            MaterialStatePropertyAll(primaryColor)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          names[index] = _nameController.text;
                        });
                        _nameController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Cập nhật'))
              ],
            ));
  }

  onDeleteName(int index) {
    AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            dialogType: DialogType.question,
            title: 'Xoá ${names[index]}?',
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSans',
            ),
            btnOkColor: Colors.deepOrangeAccent,
            btnOkOnPress: () {
              setState(() {
                names.removeAt(index);
              });
            },
            btnOkText: 'Xoá',
            btnCancelColor: Colors.blueAccent,
            btnCancelOnPress: () {},
            btnCancelText: 'Huỷ')
        .show();
  }
}
