import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/widgets/style_widget/text_form_field_widget.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();

  getSearchData(){
    
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white.withOpacity(0.94),
            appBar: AppBar(),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                defaultTextFormField(
                    controller: _searchController,
                    inputType: TextInputType.name),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(onPressed: () {}, child: Text('Get search'))
              ],
            )));
  }
}
