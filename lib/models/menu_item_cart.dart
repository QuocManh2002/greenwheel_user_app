import 'package:greenwheel_user_app/view_models/product.dart';

class ItemCart {
  const ItemCart({
    required this.product,
    required this.qty,
  });
  final ProductViewModel product;
  final int qty;
}
