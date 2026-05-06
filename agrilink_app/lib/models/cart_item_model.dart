import 'package:flutter/foundation.dart';

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
    debugPrint("SERVER SENT THIS ITEM: $json");

    // This looks for a nested product object which usually holds price/image
    final p = json['product_details'] ?? json['product'] ?? json;

    return CartItem(
      id: json['id'].toString(),
      productId: (json['product_id'] ?? p['id'] ?? '').toString(),

      // Look for name in top level OR inside product object
      productName: json['product_name'] ?? p['name'] ?? p['product_name'] ?? 'Mango',

      // PRICE: Check inside 'p' for 'price' or 'price_per_unit'
      pricePerUnit: double.tryParse(json['price']?.toString() ?? '') ??
          double.tryParse(p['price']?.toString() ?? '') ??
          double.tryParse(p['price_per_unit']?.toString() ?? '') ?? 0.0,

      unitType: json['unit_type'] ?? p['unit_type'] ?? 'kg',

      // IMAGE: Check inside 'p' for 'image' or 'product_image'
      imagePath: json['product_image'] ??
          p['product_image'] ??
          p['image'] ??
          json['image'] ?? '',

      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      location: json['location'] ?? p['location'] ?? '',

      // STOCK: Matches your working logic but checks nesting too
      stock: double.tryParse(json['product_stock']?.toString() ?? '') ??
          double.tryParse(p['product_stock']?.toString() ?? '') ??
          double.tryParse(p['stock']?.toString() ?? '') ?? 0.0,
    );
  }
}