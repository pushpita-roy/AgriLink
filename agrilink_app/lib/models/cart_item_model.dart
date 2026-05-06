class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double pricePerUnit; // Name matches constructor
  final String unitType;
  final String imagePath;    // Name matches constructor
  int quantity;
  final String location;
  final double stock;        // Changed from int to double to match "5.00"

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.pricePerUnit,
    this.unitType = 'kg',
    this.imagePath = '',
    this.quantity = 1,
    this.location = '',
    this.stock = 0.0,
  });

  double get lineTotal => pricePerUnit * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      productId: (json['product_id'] ?? json['product'] ?? '').toString(),
      productName: json['product_name'] ?? '',

      // Fixed: Use pricePerUnit to match the variable name above
      pricePerUnit: double.tryParse(json['price'].toString()) ?? 0.0,

      unitType: json['unit_type'] ?? 'kg',

      // Fixed: Use imagePath to match the variable name above
      imagePath: json['product_image'] ?? json['image_url'] ?? '',

      quantity: int.tryParse(json['quantity'].toString()) ?? 1,

      location: json['location'] ?? '',

      // Fixed: Stock is a double to handle "5.00"
      stock: double.tryParse(json['product_stock'].toString()) ?? 0.0,
    );
  }
}