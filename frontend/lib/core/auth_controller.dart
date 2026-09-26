import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import 'models.dart';

/// Session state: JWT, current user, login/register/logout.
///
/// Persisted with flutter_secure_storage, which on web encrypts values with a
/// WebCrypto key before they reach localStorage.
class AuthController extends ChangeNotifier {
  AuthController({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage() {
    api = ApiClient(tokenProvider: () => _token);
  }

  static const _tokenKey = 'access_token';
  static const _userKey = 'user_profile';

  final FlutterSecureStorage _storage;
  late final ApiClient api;

  String? _token;
  AppUser? _user;

  AppUser? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;

  /// Restores the saved session from the cached profile so the first frame
  /// doesn't wait on the network; the token is verified in the background.
  Future<void> restore() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      final cached = await _storage.read(key: _userKey);
      if (_token == null || cached == null) return await _clear();
      _user = AppUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } catch (_) {
      return await _clear();
    }
    _verifyInBackground();
  }

  Future<void> _verifyInBackground() async {
    try {
      final fresh = AppUser.fromJson(await api.get('/auth/me') as Map<String, dynamic>);
      _user = fresh;
      await _storage.write(key: _userKey, value: jsonEncode(fresh.toJson()));
      notifyListeners();
    } on ApiException catch (e) {
      // Only a definite rejection ends the session; network errors keep it.
      if (e.isUnauthorized) await logout();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final res = await api.post('/auth/login', {'email': email, 'password': password});
    await _startSession(res as Map<String, dynamic>);
  }

  /// Creates the account only; the user signs in afterwards.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await api.post('/auth/register', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  Future<void> logout() async {
    await _clear();
    notifyListeners();
  }

  Future<void> _startSession(Map<String, dynamic> res) async {
    _token = res['accessToken'] as String;
    _user = AppUser.fromJson(res['user'] as Map<String, dynamic>);
    await _storage.write(key: _tokenKey, value: _token);
    await _storage.write(key: _userKey, value: jsonEncode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> _clear() async {
    _token = null;
    _user = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
