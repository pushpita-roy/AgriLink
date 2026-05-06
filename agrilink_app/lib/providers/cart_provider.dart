import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.lineTotal);
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  Future<void> fetchCart() async {
    try {
      final response = await ApiService.getCart();
      final itemsList = response is List ? response : (response['items'] ?? []);

      _items = (itemsList as List).map((j) {
        final item = CartItem.fromJson(j);
        if (item.stock > 0 && item.quantity > item.stock) {
          item.quantity = item.stock;

          // এপিআইকেও জানিয়ে দাও যে এটা কমিয়ে দেওয়া হয়েছে
          final apiId = int.tryParse(item.id);
          if (apiId != null) ApiService.updateCartItem(apiId, item.stock);
        }
        return item;
      }).toList();

      notifyListeners();
    } catch (e) {
      print("DEBUG: Fetch Cart Error: $e");
    }
  }

  Future<void> addToCart(Product product, String userId) async {
    if (product.stockQty <= 0) return;

    try {
      // এপিআই কল করার আগে চেক করুন অলরেডি কার্টে স্টকের সমান আছে কি না
      final existingIndex = _items.indexWhere((item) => item.productId == product.id);
      if (existingIndex != -1 && _items[existingIndex].quantity >= product.stockQty) {
        return; // আর অ্যাড হবে না
      }

      await ApiService.addToCart(int.parse(product.id));
      await fetchCart();
    } catch (e) {
      // অফলাইন/এরর হ্যান্ডলিং আগের মতোই
      final existingIndex = _items.indexWhere((item) => item.productId == product.id);
      if (existingIndex != -1) {
        if (_items[existingIndex].quantity < product.stockQty) {
          _items[existingIndex].quantity++;
        }
      } else {
        _items.add(
          CartItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            productId: product.id,
            productName: product.name,
            pricePerUnit: product.pricePerUnit,
            unitType: product.unitType,
            imagePath: product.imagePath,
            quantity: 1,
            location: product.location,
            stock: product.stockQty.toInt(),
          ),
        );
      }
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
    try {
      await ApiService.removeCartItem(int.parse(cartItemId));
    } catch (e) {
      print("DEBUG: Remove Failed: $e");
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity, int maxStock) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;

    // ডাটাবেজ থেকে আসা রিয়েল স্টক ব্যবহার করুন
    int availableStock = _items[index].stock > 0 ? _items[index].stock : maxStock;

    if (quantity > availableStock) {
      quantity = availableStock; // ডাইনামিক লক
    }

    if (quantity < 1) {
      await removeFromCart(cartItemId);
      return;
    }

    _items[index].quantity = quantity;
    notifyListeners();

    try {
      final apiId = int.tryParse(cartItemId);
      if (apiId != null) {
        await ApiService.updateCartItem(apiId, quantity);
      }
    } catch (e) {
      print("API Error: $e");
      fetchCart();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    try {
      await ApiService.clearCart();
    } catch (_) {}
  }
}