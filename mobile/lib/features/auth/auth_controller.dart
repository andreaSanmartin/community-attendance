import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../models/menu_item_model.dart';
import '../../models/user_model.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._apiClient, this._storage);
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  UserModel? user;
  List<MenuItemModel> menu = [];
  bool isLoading = false;
  String? error;
  bool get isAuthenticated => user != null;

  Future<void> restoreSession() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return;
    try {
      await _loadSessionData();
    } catch (_) {
      await _storage.clearToken();
      user = null;
      menu = [];
    }
  }

  Future<bool> login(String username, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/api/auth/login', data: {'username': username.trim(), 'password': password});
      await _storage.saveToken(response.data['access_token'] as String);
      await _loadSessionData();
      return true;
    } on DioException catch (e) {
      error = _detail(e) ?? 'No se pudo iniciar sesión.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSessionData() async {
    final me = await _apiClient.dio.get('/api/auth/me');
    user = UserModel.fromJson(Map<String, dynamic>.from(me.data));
    try {
      final menuResponse = await _apiClient.dio.get('/api/auth/menu');
      menu = (menuResponse.data as List).map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      // Backward-compatible fallback while upgrading an older backend.
      menu = _fallbackMenu(user!.isSuperAdmin);
    }
  }

  List<MenuItemModel> _fallbackMenu(bool superAdmin) {
    final items = <MenuItemModel>[
      const MenuItemModel(key: 'manual_attendance', label: 'Asistencia manual', icon: 'checklist'),
      const MenuItemModel(key: 'youth', label: 'Jóvenes', icon: 'groups'),
      const MenuItemModel(key: 'tribes', label: 'Tribus', icon: 'diversity_3'),
      const MenuItemModel(key: 'projects', label: 'Proyectos', icon: 'sports_soccer'),
      const MenuItemModel(key: 'reports', label: 'Reportes', icon: 'bar_chart'),
    ];
    if (superAdmin) items.add(const MenuItemModel(key: 'users', label: 'Usuarios', icon: 'manage_accounts'));
    return items;
  }

  Future<void> logout() async {
    await _storage.clearToken();
    user = null;
    menu = [];
    notifyListeners();
  }

  String? _detail(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) return data['detail'].toString();
    return null;
  }
}
