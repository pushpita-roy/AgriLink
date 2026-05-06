import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.lineTotal);

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  Future<void> fetchCart() async {
    try {
      final response = await ApiService.getCart();
      debugPrint("SERVER DATA: $response");

      final itemsList = response is List ? response : (response['items'] ?? []);
      _items = (itemsList as List).map((j) => CartItem.fromJson(j)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch Cart Error: $e");
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity, int maxStock) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;

    // Use the model's stock if maxStock isn't provided
    final double availableStock = maxStock > 0
        ? maxStock.toDouble()
        : _items[index].stock;

    if (newQuantity > availableStock) {
      notifyListeners(); // Triggers UI logic (like SnackBars)
      return;
    }

    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    // Optimistic Update
    _items[index].quantity = newQuantity;
    notifyListeners();

    try {
      final apiId = int.tryParse(cartItemId);
      if (apiId != null) {
        await ApiService.updateCartItem(apiId, newQuantity);
      }
    } catch (e) {
      await fetchCart(); // Revert on failure
    }
  }

  Future<void> addToCart(Product product, String userId) async {
    try {
      final existingIndex = _items.indexWhere((item) => item.productId == product.id);
      if (existingIndex != -1) {
        if (_items[existingIndex].quantity >= product.stockQty) {
          throw Exception("You already have all available stock in your cart.");
        }
      }

      await ApiService.addToCart(int.parse(product.id));
      await fetchCart();
    } catch (e) {
      debugPrint("CartProvider Error: $e");
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
    try {
      await ApiService.removeCartItem(int.parse(cartItemId));
    } catch (e) {
      debugPrint("DEBUG: Remove Failed: $e");
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