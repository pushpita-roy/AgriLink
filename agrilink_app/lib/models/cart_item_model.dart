import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double pricePerUnit;
  final String unitType;
  final String imagePath;
  int quantity;
  final String location;
  final double stock;

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
    debugPrint("SERVER SENT THIS ITEM: $json");

    // Fix: Removed the 'ly' typo and mapped correct keys from your server logs
    final double price = double.tryParse(json['price_per_unit']?.toString() ?? '') ?? 0.0;
    final String image = json['image_path'] ?? '';

    return CartItem(
      id: json['id'].toString(),
      productId: (json['product_id'] ?? '').toString(),
      productName: json['product_name'] ?? 'Product',
      pricePerUnit: price,
      unitType: json['unit_type'] ?? 'kg',
      imagePath: image,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      location: json['location'] ?? '',

      // STOCK REMINDER: Kept exactly as you wanted (using stock_qty)
      stock: double.tryParse(json['stock_qty']?.toString() ?? '') ??
          double.tryParse(json['product_stock']?.toString() ?? '') ?? 0.0,
    );
  }
}