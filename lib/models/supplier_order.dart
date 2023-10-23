class SupplierOrder {
  const SupplierOrder(
      {required this.id,
      required this.imgUrl,
      required this.price,
      required this.quantity,
      required this.supplierName,
      required this.type});

  final String imgUrl;
  final int id;
  final int quantity;
  final String supplierName;
  final double price;
  final int type;
}
