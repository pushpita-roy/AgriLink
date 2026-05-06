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

      _items = (itemsList as List)
          .map((j) => CartItem.fromJson(j))
          .toList();

      notifyListeners();
    } catch (e) {
      print("DEBUG: Fetch Cart Error: $e");
    }
  }

  Future<void> addToCart(Product product, String userId) async {
    if (product.stockQty <= 0) return;

    try {
      await ApiService.addToCart(int.parse(product.id));
      await fetchCart();
    } catch (e) {
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

  // --- এই মেথডটি এখন একদম নিরাপদ ---
  Future<void> updateQuantity(String cartItemId, int quantity, int maxStock) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;

    // ১. আসল স্টক নির্ধারণ (মডেল থেকে অথবা স্ক্রিন থেকে আসা maxStock)
    // যদি মডেলে ০ বা ৯৯৯ থাকে, তবে স্ক্রিন থেকে পাঠানো maxStock ব্যবহার করো
    int currentItemStock = _items[index].stock;
    int limit = (currentItemStock == 0 || currentItemStock == 999) ? maxStock : currentItemStock;

    // ২. হার্ড লক: কোয়ান্টিটি যেন লিমিটের বেশি না হয়
    int finalQuantity = quantity;
    if (finalQuantity > limit) {
      finalQuantity = limit;
    }

    // ৩. যদি ১ এর নিচে নামাতে চায় (০ হয়ে যায়), তবে রিমুভ করো
    if (finalQuantity < 1) {
      await removeFromCart(cartItemId);
      return;
    }

    // ৪. আপডেট লজিক
    int oldQty = _items[index].quantity;
    _items[index].quantity = finalQuantity;
    notifyListeners();

    try {
      final apiId = int.tryParse(cartItemId);
      if (apiId != null) {
        await ApiService.updateCartItem(apiId, finalQuantity);
      }
    } catch (e) {
      print("DEBUG: API Update Failed: $e");
      // এরর হলে আগের কোয়ান্টিটিতে ফিরে যাও
      _items[index].quantity = oldQty;
      notifyListeners();
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