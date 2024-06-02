import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phuot_app/core/constants/urls.dart';
import 'package:phuot_app/screens/main_screen/search_screen.dart';
import 'package:sizer2/sizer2.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return SizedBox(
      height: 35.h,
      child: Stack(
        children: [
          CachedNetworkImage(
            height: 35.h,
            width: double.infinity,
            fit: BoxFit.cover,
            imageUrl: defaultHomeImage,
            placeholder: (context, url) => Image.memory(kTransparentImage),
            errorWidget: (context, url, error) => FadeInImage.assetNetwork(
              height: 35.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: 'No Image',
              image: emptyPlan,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Text(
                  'Theo bạn trên mọi cung đường',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                RichText(
                    text: const TextSpan(
                        style: TextStyle(color: Colors.white, fontSize: 15),
                        children: [
                      TextSpan(
                          text: "GREENWHEELS",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " - đưa chuyến đi của bạn lên tầm cao mới")
                    ])),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to search screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const SearchScreen(
                                searchState: false,
                              )));
                    },
                    child: TextField(
                      enabled: false,
                      controller: searchController,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(width: 2),
                          ),
                          hintText: "Bạn muốn đi đâu?",
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 30,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                            },
                          )),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
