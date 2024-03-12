import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:greenwheel_user_app/main.dart';
import 'package:greenwheel_user_app/widgets/style_widget/button_style.dart';

import 'package:greenwheel_user_app/widgets/style_widget/shimmer_widget.dart';
import 'package:greenwheel_user_app/widgets/test_screen1.dart';
import 'package:sizer2/sizer2.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _controller = QuillController.basic();
final jsonText = sharedPreferences.getString('plan_note_editor');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    if(jsonText !=null){
      final json = jsonDecode(jsonText!);
      _controller.document = Document.fromJson(json); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                children: [
                  // if(jsonText == null)
                  QuillToolbar.simple(
                    configurations: QuillSimpleToolbarConfigurations(
                      controller: _controller,
                      sharedConfigurations: const QuillSharedConfigurations(
                        locale: Locale('de'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        controller: _controller,
                        readOnly: false,
                        customStyles:const DefaultStyles(
                          sizeSmall: TextStyle(fontSize: 25),
                          italic: TextStyle(fontSize: 20),
                          small: TextStyle(fontSize: 20)
                        ),
                        sharedConfigurations: const QuillSharedConfigurations(
                          locale: Locale('de'),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: elevatedButtonStyle,
                    onPressed: (){
                      final json = jsonEncode(_controller.document.toDelta().toJson());
                      sharedPreferences.setString('plan_note_editor', json);
                      Navigator.of(context).pop();
                    }, 
                    child:const Text('Lưu')),
                    const SizedBox(height: 24,)
                ],
              ),
            )));
  }
}
