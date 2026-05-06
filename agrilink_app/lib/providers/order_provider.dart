import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  List<Order> getOrdersByBuyer(String buyerId) {
    return _orders.where((o) => o.buyerId.toString() == buyerId.toString()).toList();
  }

  List<Order> getOrdersByFarmer(String farmerId) {
    return _orders
        .where((o) => o.items.any((item) =>
    item.farmerId.toString() == farmerId.toString()))
        .toList();
  }

  // FIXED: Logic now handles Buyer, Farmer, and Admin based on Role
  int getTotalOrderCount(String userId, String role) {
    final normalizedRole = role.toLowerCase();

    if (normalizedRole == 'admin') {
      return _orders.length; // Admin sees all system orders
    }

    if (normalizedRole == 'farmer' || normalizedRole == 'seller') {
      // Farmer sees orders where their products are included
      return _orders.where((o) => o.items.any((item) =>
      item.farmerId.toString() == userId.toString())).length;
    }

    // Default for Buyer (purchases)
    return _orders.where((o) => o.buyerId.toString() == userId.toString()).length;
  }

  // FIXED: Logic now handles Pending status for all roles
  int getPendingOrderCount(String userId, String role) {
    final normalizedRole = role.toLowerCase();

    if (normalizedRole == 'admin') {
      return _orders.where((o) => o.status == OrderStatus.pending).length;
    }

    if (normalizedRole == 'farmer' || normalizedRole == 'seller') {
      return _orders.where((o) =>
      o.status == OrderStatus.pending &&
          o.items.any((item) => item.farmerId.toString() == userId.toString())
      ).length;
    }

    // Default for Buyer
    return _orders.where((o) =>
    o.buyerId.toString() == userId.toString() &&
        o.status == OrderStatus.pending
    ).length;
  }

  Future<void> fetchOrders({
    String? status,
    String? paymentStatus,
    String? search,
    String? sort,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.getOrders(
        status: status,
        paymentStatus: paymentStatus,
        search: search,
        sort: sort,
      );

      final results = response is List ? response : (response['results'] ?? response['data'] ?? []);

      _orders = (results as List)
          .map((j) => Order.fromJson(j))
          .toList();
    } catch (e) {
      debugPrint('Fetch Orders Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> placeOrder({
    required String paymentMethod,
    required String shippingAddress,
    required String buyerDivision,
    required String farmerDivision,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // 1. Delivery Charge Calculation
      double deliveryCharge = (buyerDivision.trim().toLowerCase() == farmerDivision.trim().toLowerCase())
          ? 80.0
          : 130.0;

      // 2. Safe Total Calculation (This stops the '*' error)
      double itemsTotal = 0.0;
      for (var item in items) {
        // Look for 'price_per_unit' (matching your logs) or 'price'
        double price = double.tryParse(item['price_per_unit']?.toString() ?? '') ??
            double.tryParse(item['price']?.toString() ?? '') ?? 0.0;

        int qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

        itemsTotal += (price * qty);
      }

      double finalTotal = itemsTotal + deliveryCharge;

      // 3. Call Service
      final response = await ApiService.placeOrder(
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        items: items,
        totalAmount: finalTotal,
      );

      final newOrder = Order.fromJson(response);
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (e) {
      debugPrint("Order Placement Error: $e");
      rethrow;
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await ApiService.updateOrderStatus(orderId, status);

      final index = _orders.indexWhere((o) => int.parse(o.id.toString()) == orderId);
      if (index != -1) {
        _orders[index] = Order.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Provider Error: $e');
      rethrow;
    }
  }
}