import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _popularProducts = [];
  bool _isLoading = false;
  bool _isPopularLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  List<Product> get popularProducts => _popularProducts;
  bool get isLoading => _isLoading;
  bool get isPopularLoading => _isPopularLoading;
  String? get error => _error;

  // --- Helper Methods (Fixes UI Errors) ---

  // FIX: Error: The method 'getProductsByFarmer' isn't defined
  List<Product> getProductsByFarmer(String farmerId) {
    return _products.where((p) => p.farmerId == farmerId).toList();
  }

  // FIX: Error: The getter 'categories' isn't defined
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    if (!cats.contains('All')) cats.insert(0, 'All');
    return cats;
  }

  // FIX: Error: The method 'getProductsByCategory' isn't defined
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  // FIX: Error: The method 'searchProducts' isn't defined
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    final lower = query.toLowerCase();
    return _products.where((p) =>
    p.name.toLowerCase().contains(lower) ||
        p.category.toLowerCase().contains(lower)
    ).toList();
  }

  Product? getProductById(String id) {
    return _products.where((p) => p.id == id).firstOrNull;
  }

  // --- API Calls ---

  Future<void> fetchPopularProducts(String division) async {
    _isPopularLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getPopularProducts(division);
      _popularProducts = data.map((j) => Product.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Fetch Popular Products Error: $e');
    } finally {
      _isPopularLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getProducts(search: search);
      _products = data.map((json) => Product.fromJson(json)).toList();

    } catch (e) {
      debugPrint("Fetch Products Error: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product, {List<int>? imageBytes, String? imageName}) async {
    try {
      final Map<String, String> fields = product.toJson().map(
            (key, value) => MapEntry(key, value.toString()),
      );
      final response = await ApiService.createProduct(
        fields: fields,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      final newProduct = Product.fromJson(response);
      _products.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      debugPrint('Add Product Error: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await ApiService.updateProduct(
        int.parse(product.id),
        product.toJson(),
      );
      final updated = Product.fromJson(response);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await ApiService.deleteProduct(int.parse(id));
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}