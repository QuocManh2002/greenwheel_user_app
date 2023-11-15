import 'package:flutter/material.dart';

class DraftPlanScreen extends StatefulWidget {
  const DraftPlanScreen({super.key});

  @override
  State<DraftPlanScreen> createState() => _DraftPlanScreenState();
}

class _DraftPlanScreenState extends State<DraftPlanScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Bản nháp kế hoạch",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ));
  }
}