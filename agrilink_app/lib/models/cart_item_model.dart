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

    // Dig into the nested product data
    final p = json['product'] ?? json['product_details'] ?? json;

    // --- PICTURE FIX ---
    // Change this URL to match your Django server (e.g., http://10.0.2.2:8000 or http://localhost:8000)
    String baseUrl = "http://127.0.0.1:8000";
    String rawImage = p['image'] ?? p['product_image'] ?? json['product_image'] ?? '';

    // If Django sends a relative path like "/media/...", we add the server URL
    String finalImage = rawImage.startsWith('http')
        ? rawImage
        : rawImage.isNotEmpty ? "$baseUrl$rawImage" : "";

    return CartItem(
      id: json['id'].toString(),
      productId: (json['product_id'] ?? p['id'] ?? '').toString(),
      productName: json['product_name'] ?? p['name'] ?? 'Product',

      // --- PRICE FIX ---
      // We look in 'p' (the product folder) specifically
      pricePerUnit: double.tryParse(p['price']?.toString() ?? '') ??
          double.tryParse(json['price']?.toString() ?? '') ??
          double.tryParse(p['product_price']?.toString() ?? '') ?? 0.0,

      unitType: json['unit_type'] ?? p['unit_type'] ?? 'kg',
      imagePath: finalImage, // Using the fixed full URL
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      location: json['location'] ?? p['location'] ?? '',

      // --- STOCK (DO NOT CHANGE) ---
      stock: double.tryParse(p['product_stock']?.toString() ?? '') ??
          double.tryParse(p['stock']?.toString() ?? '') ??
          double.tryParse(p['stock_qty']?.toString() ?? '') ??
          double.tryParse(json['product_stock']?.toString() ?? '') ?? 0.0,
    );
  }
}