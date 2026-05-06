import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static String get baseUrl => 'https://agrilink-backend-pusz.onrender.com/api';

  static String? _token;

  static void setToken(String? token) => _token = token;

  static String? get token => _token;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) headers['Authorization'] = 'Token $_token';
    return headers;
  }

  // ── Auth Section ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );

    final result = _handleResponse(response);

    if (result != null && result['token'] != null) {
      _token = result['token'];
    }

    return result;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String division,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'division': division,
      }),
    );

    final result = _handleResponse(response);

    if (result != null && result['token'] != null) {
      _token = result['token'];
    }

    return result;
  }

  static Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/auth/logout/'), headers: _headers);
    _token = null;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'), headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getUsers(
      {String? role, String? search, String? isVerified}) async {
    final params = <String, String>{};
    if (role != null) params['role'] = role;
    if (search != null) params['search'] = search;
    if (isVerified != null) params['is_verified'] = isVerified;

    final uri = Uri.parse('$baseUrl/auth/users/').replace(
        queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  // ── Products Section ──────────────────────────────────────────────
  static Future<List<dynamic>> getProducts(
      {String? search, String? category, String? farmerId}) async {
    final params = <String, String>{};
    if (search != null) params['search'] = search;
    if (category != null && category != 'All') params['category'] = category;
    if (farmerId != null) params['farmer_id'] = farmerId;

    final uri = Uri.parse('$baseUrl/products/').replace(
        queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    final result = _handleResponse(response);
    return result is List ? result : (result['data'] ?? []);
  }

  static Future<List<dynamic>> getPopularProducts(String division) async {
    final uri = Uri.parse('$baseUrl/products/popular/').replace(
      queryParameters: {'division': division},
    );
    final response = await http.get(uri, headers: _headers);
    final result = _handleResponse(response);
    return result is List ? result : (result['data'] ?? []);
  }

  static Future<Map<String, dynamic>> createProduct({
    required Map<String, String> fields,
    required List<int>? imageBytes,
    required String? imageName,
  }) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/products/'));

    if (_token != null) {
      request.headers['Authorization'] = 'Token $_token';
    }

    request.fields.addAll(fields);
    if (imageBytes != null && imageName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image', imageBytes, filename: imageName,
        contentType: MediaType('image', 'jpeg'),
      ));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProduct(int id,
      Map<String, dynamic> data) async {
    final response = await http.put(
        Uri.parse('$baseUrl/products/$id/'), headers: _headers,
        body: jsonEncode(data));
    return _handleResponse(response);
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
        Uri.parse('$baseUrl/products/$id/'), headers: _headers);
    if (response.statusCode != 204) _handleResponse(response);
  }

  // ── Cart Section ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCart() async {
    final response = await http.get(
        Uri.parse('$baseUrl/cart/'), headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> addToCart(int productId,
      {int quantity = 1}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add/'),
      headers: _headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateCartItem(int id,
      int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$id/update/'),
      headers: _headers,
      body: jsonEncode({'quantity': quantity}),
    );
    return _handleResponse(response);
  }

  static Future<void> removeCartItem(int id) async {
    final response = await http.delete(
        Uri.parse('$baseUrl/cart/$id/remove/'), headers: _headers);
    if (response.statusCode != 204) _handleResponse(response);
  }

  static Future<void> clearCart() async {
    await http.delete(Uri.parse('$baseUrl/cart/clear/'), headers: _headers);
  }

  // ── Orders Section ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getOrderStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/stats/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getOrders({
    String? status, String? paymentStatus, String? search, String? sort, String? dateFrom, String? dateTo,
  }) async {
    final params = <String, String>{};
    if (status != null && status != 'all') params['status'] = status;
    if (paymentStatus != null && paymentStatus != 'all')
      params['payment_status'] = paymentStatus;
    if (search != null) params['search'] = search;
    if (sort != null) params['sort'] = sort;
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;

    final uri = Uri.parse('$baseUrl/orders/').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> placeOrder({
    required String paymentMethod,
    required String shippingAddress,
    required List<dynamic> items,
    required double totalAmount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/add/'),
      headers: _headers, // Includes your Token
      body: jsonEncode({
        'payment_method': paymentMethod,
        'shipping_address': shippingAddress,
        'items': items,
        'total_amount': totalAmount,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(int orderId,
      String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/orders/$orderId/status/'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.headers['content-type']?.contains('text/html') ?? false) {
      throw Exception('Server Error (${response.statusCode}): Check Django terminal.');
    }

    final dynamic body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (body is Map) {
      if (body.containsKey('non_field_errors')) throw Exception(
          body['non_field_errors'][0]);
      if (body.containsKey('detail')) throw Exception(body['detail']);
      if (body.isNotEmpty) {
        final firstError = body.values.first;
        if (firstError is List && firstError.isNotEmpty) throw Exception(
            firstError[0]);
        throw Exception(firstError.toString());
      }
    }
    throw Exception('Server Error: ${response.statusCode}');
  }
}