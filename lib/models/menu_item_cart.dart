import 'package:greenwheel_user_app/view_models/product.dart';

class ItemCart {
  ItemCart({
    required this.product,
    this.qty,
  });
  final ProductViewModel product;
  int? qty;
}
