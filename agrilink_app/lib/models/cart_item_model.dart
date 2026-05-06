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

    // Dig into 'product' or 'product_details'
    final p = json['product_details'] ?? json['product'] ?? json;

    // IMAGE LOGIC: Django sometimes gives a relative path like /media/products/mango.jpg
    // We need to make sure it's a full URL if possible.
    String rawImage = json['product_image'] ?? p['image'] ?? p['product_image'] ?? '';

    // If your image doesn't start with http, you might need to prepend your BASE_URL
    // Example: if (!rawImage.startsWith('http')) rawImage = "http://127.0.0.1:8000$rawImage";

    return CartItem(
      id: json['id'].toString(),
      productId: (json['product_id'] ?? p['id'] ?? '').toString(),
      productName: json['product_name'] ?? p['name'] ?? 'Mango',

      pricePerUnit: double.tryParse(json['price']?.toString() ?? '') ??
          double.tryParse(p['price']?.toString() ?? '') ?? 0.0,

      unitType: json['unit_type'] ?? p['unit_type'] ?? 'kg',

      imagePath: rawImage,

      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      location: json['location'] ?? p['location'] ?? '',

      stock: double.tryParse(p['product_stock']?.toString() ?? '') ??
          double.tryParse(p['stock']?.toString() ?? '') ??
          double.tryParse(p['stock_qty']?.toString() ?? '') ??
          double.tryParse(json['product_stock']?.toString() ?? '') ?? 0.0,
    );
  }
}