import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/screens/main_screen/search_screen.dart';

class RecentCard extends StatelessWidget {
  const RecentCard({super.key, required this.recent});
  final String recent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SearchScreen(
                    search: recent,
                    searchState: false,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Row(
                children: [
                  // Icon at the start
                  const Icon(
                    Icons.history,
                    size: 25,
                    color: Colors.grey,
                  ),
                  // Text
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      recent,
                      style:
                          const TextStyle(fontFamily: 'NotoSans', fontSize: 16),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Add your onTap functionality here
          },
          child: const Icon(
            Icons.clear,
            size: 25,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}
