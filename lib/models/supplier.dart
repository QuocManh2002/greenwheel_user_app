import 'package:phuot_app/models/menu_item.dart';

class Supplier {
  const Supplier(
      {required this.id,
      required this.name,
      required this.imgUrl,
      required this.address,
      required this.numberOfReviews,
      required this.rating,
      required this.items});

  final int id;
  final String name;
  final String imgUrl;
  final String address;
  final int numberOfReviews;
  final double rating;
  final List<MenuItem> items;
}
