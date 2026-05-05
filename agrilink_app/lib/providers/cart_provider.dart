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

      // Handle response safely regardless of whether it's a List or Map
      final itemsList = response is List ? response : (response['items'] ?? []);

      _items = (itemsList as List)
          .map((j) => CartItem.fromJson(j))
          .toList();

      notifyListeners();
    } catch (e) {
      print("DEBUG: Fetch Cart Error: $e");
    }
  }

  Future<void> addToCart(Product product, String userId) async {
    // 1. Local Stock Check first
    if (product.stockQty <= 0) return;

    try {
      await ApiService.addToCart(int.parse(product.id));
      await fetchCart();
    } catch (e) {
      print("DEBUG: API Add Failed, using local fallback: $e");

      final existingIndex = _items.indexWhere((item) => item.productId == product.id);
      if (existingIndex != -1) {
        // Only increment if local stock allows
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
          ),
        );
      }
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    // Optimistic Update: Remove locally first so UI is snappy
    final removedItem = _items.firstWhere((item) => item.id == cartItemId);
    final originalIndex = _items.indexOf(removedItem);

    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();

    try {
      await ApiService.removeCartItem(int.parse(cartItemId));
    } catch (e) {
      print("DEBUG: API Remove Failed: $e");
      // If API fails, you could optionally re-add it,
      // but usually users prefer the item stays gone.
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity, int maxStock) async {
    // 1. Strict Stock and Bounds Check
    if (quantity > maxStock || quantity < 1) {
      if (quantity <= 0) await removeFromCart(cartItemId);
      return;
    }

    // 2. Find the item locally
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;

    int oldQty = _items[index].quantity;

    try {
      // 3. Update UI Immediately (Optimistic Update)
      _items[index].quantity = quantity;
      notifyListeners();

      // 4. API Call - Use tryParse to avoid crashes and ensure correct ID type
      final apiId = int.tryParse(cartItemId);
      if (apiId != null) {
        await ApiService.updateCartItem(apiId, quantity);
      } else {
        // If the ID is a String/UUID (like from your fallback), we don't call API
        print("DEBUG: Local-only item, skipping API update");
      }
    } catch (e) {
      print("DEBUG: API Update Failed, reverting: $e");
      // 5. Revert ONLY if the API actually failed
      if (index != -1) {
        _items[index].quantity = oldQty;
        notifyListeners();
      }
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

// --- HELPER FUNCTIONS ---

double calculateDeliveryFee(String buyerDivision, String sellerDivision) {
  if (buyerDivision.trim().toLowerCase() == sellerDivision.trim().toLowerCase()) {
    return 80.0;
  } else {
    return 130.0;
  }
}

String getDeliveryLabel(String buyerDivision, String sellerDivision) {
  if (buyerDivision.toLowerCase().trim() == sellerDivision.toLowerCase().trim()) {
    return "(Inside Division)";
  } else {
    return "(Outside Division)";
  }
}