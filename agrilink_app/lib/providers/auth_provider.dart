import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // FIXED: Unified to one list using your existing UserModel
  List<UserModel> _allUsers = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;
  List<UserModel> get allUsers => List.unmodifiable(_allUsers);

  // FIXED: Standardized fetch logic to populate the admin list
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.getAllUsers();
      final results = response is List ? response : (response['results'] ?? response['data'] ?? []);

      _allUsers = (results as List)
          .map((u) => UserModel.fromJson(u))
          .toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final roleStr = role.name;
      final response = await ApiService.login(email, password, roleStr);
      ApiService.setToken(response['token']);
      _currentUser = UserModel.fromJson(response['user']);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String division,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        role: role.name,
        division: division,
      );
      ApiService.setToken(response['token']);
      _currentUser = UserModel.fromJson(response['user']);
      return true;
    } catch (e) {
      String errorStr = e.toString().replaceAll('Exception:', '').trim();
      _errorMessage = errorStr.contains('email') ? "Email already in use." : errorStr;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (_) {}
    _currentUser = null;
    _errorMessage = null;
    ApiService.setToken(null);
    notifyListeners();
  }

  // Keep your existing fetchUsers for filtered queries if needed
  Future<void> fetchUsers({String? role, String? search, String? isVerified}) async {
    try {
      final response = await ApiService.getUsers(
        role: role,
        search: search,
        isVerified: isVerified,
      );
      final results = response['results'] ?? response['data'] ?? [];
      _allUsers = (results as List)
          .map((j) => UserModel.fromJson(j))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}