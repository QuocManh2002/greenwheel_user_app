import 'package:greenwheel_user_app/models/menu_item.dart';

class ItemCart {
  const ItemCart({
    required this.item,
    required this.qty,
  });
  final MenuItem item;
  final int qty;
}
