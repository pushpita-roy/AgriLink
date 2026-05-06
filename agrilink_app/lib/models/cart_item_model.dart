class CartItem {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final double pricePerUnit;
  final String unitType;
  final String imagePath;
  int quantity;
  final DateTime createdAt;
  final String location;
  final int stock;

  CartItem({
    required this.id,
    this.userId = '',
    required this.productId,
    required this.productName,
    required this.pricePerUnit,
    this.unitType = 'kg',
    this.imagePath = '',
    this.quantity = 1,
    required this.location,
    this.stock = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get lineTotal => pricePerUnit * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      productName: json['product_name'] ?? '',
      location: json['location']?.toString() ?? '',
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
      unitType: json['unit_type'] ?? '',
      imagePath: json['image_path'] ?? '',
      quantity: json['quantity'] ?? 1,
      stock: json['stock'] ?? json['product_stock'] ?? 0,
    );
  }
}