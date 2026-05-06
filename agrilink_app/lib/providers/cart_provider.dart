import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.lineTotal);

  // FIXED: Added back missing method for ProductDetailScreen
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  Future<void> fetchCart() async {
    try {
      final response = await ApiService.getCart();

      print("SERVER DATA: $response");

      final itemsList = response is List ? response : (response['items'] ?? []);
      _items = (itemsList as List).map((j) => CartItem.fromJson(j)).toList();
      notifyListeners();
    } catch (e) {
      print("Fetch Cart Error: $e");
    }
  }

  // FIXED: Only one declaration of updateQuantity now
  Future<void> updateQuantity(String cartItemId, int quantity, int maxStock) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;

    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    int availableStock = maxStock > 0 ? maxStock : _items[index].stock.toInt();

    if (availableStock <= 0) {
      availableStock = 999;
    }

    if (quantity > availableStock) {
      notifyListeners();
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
      await fetchCart();
    }
  }

  Future<void> addToCart(Product product, String userId) async {
    try {
      // 1. Local check
      final existingIndex = _items.indexWhere((item) => item.productId == product.id);
      if (existingIndex != -1) {
        if (_items[existingIndex].quantity >= product.stockQty) {
          throw Exception("You already have all available stock in your cart.");
        }
      }

      // 2. Call API
      await ApiService.addToCart(int.parse(product.id));

      // 3. REFRESH is key - it gets the fresh data from server
      await fetchCart();

    } catch (e) {
      // This allows the SnackBar in your UI to show the actual error
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
      print("DEBUG: Remove Failed: $e");
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