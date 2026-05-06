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
      // Fallback for product_id vs product
      productId: (json['product_id'] ?? json['product'] ?? '').toString(),
      productName: json['product_name'] ?? 'Product',

      // SAFE PARSING: Check all possible price keys
      pricePerUnit: double.tryParse(json['price'].toString()) ??
          double.tryParse(json['product_price'].toString()) ?? 0.0,

      unitType: json['unit_type'] ?? 'kg',

      // IMAGE FIX: Django usually sends 'product_image' or 'image'
      imagePath: json['product_image'] ?? json['image_url'] ?? json['image'] ?? '',

      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      location: json['location'] ?? '',

      // STOCK FIX: This is why your button says "Only 0 available"
      stock: double.tryParse(json['product_stock'].toString()) ??
          double.tryParse(json['stock_qty'].toString()) ??
          double.tryParse(json['stock'].toString()) ?? 0.0,
    );
  }
}