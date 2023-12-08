import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class TestScreen1 extends StatelessWidget {
  const TestScreen1({super.key});
  

  @override
  Widget build(BuildContext context) {
    List<int> numbers = [1,2,1,2];
    int target = 3;
    printSumCombinations(numbers, target);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("App bar"),
          leading: BackButton(
            onPressed: (){
              AwesomeDialog(context: context,
              dialogType: DialogType.warning,
              body: Text("Hello, its me"),
              btnOkOnPress: () {
                Navigator.of(context).pop();
              },
              ).show();
            },
          ),
        ),
        body: Center(
          child: Text('Page'),
        ),
        ));
  }
}

void printSumCombinations(List<int> numbers, int targetSum) {
  List<int> combination = [];
  _findSumCombinations(numbers, targetSum, 0, combination);
}

void _findSumCombinations(
    List<int> numbers, int targetSum, int startIndex, List<int> combination) {
  if (targetSum == 0) {
    // In ra một cách cộng phù hợp
    print(combination);
    return;
  }

  for (int i = startIndex; i < numbers.length; i++) {
    if (numbers[i] <= targetSum) {
      // Thử các phần tử trong mảng
      combination.add(numbers[i]);
      _findSumCombinations(
          numbers, targetSum - numbers[i], i, combination);
      combination.removeLast(); // Xóa phần tử cuối của combination để thử các phần tử khác
    }
  }
}