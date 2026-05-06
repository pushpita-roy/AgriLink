class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double pricePerUnit;
  final String unitType;
  final String imagePath;
  int quantity;
  final String location;
  final int stock;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.pricePerUnit,
    this.unitType = 'kg',
    this.imagePath = '',
    this.quantity = 1,
    required this.location,
    this.stock = 0,
  });

  double get lineTotal => pricePerUnit * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      productId: (json['product_id'] ?? '').toString(),
      productName: json['product_name'] ?? '',
      location: json['location']?.toString() ?? '',
      price_per_unit: double.parse((json['price_per_unit'] ?? '0').toString()),
      unitType: json['unit_type'] ?? '',
      imagePath: json['image_path'] ?? '',
      quantity: json['quantity'] ?? 1,
      // Fixed parsing: converts 5.00 to 5
      stock: json['stock_qty'] != null ? (json['stock_qty'] as num).toInt() : 0,
    );
  }
}