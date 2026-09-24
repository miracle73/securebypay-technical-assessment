import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import 'models.dart';

/// Owns the session: the JWT, the current user, and login/register/logout.
///
/// The token lives in flutter_secure_storage. On web that encrypts the value
/// with a WebCrypto key before writing it to localStorage, so it is never
/// stored in plain text. The router listens to this notifier to gate routes.
class AuthController extends ChangeNotifier {
  AuthController({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    api = ApiClient(tokenProvider: () => _token);
  }

  static const _tokenKey = 'access_token';

  final FlutterSecureStorage _storage;
  late final ApiClient api;

  String? _token;
  AppUser? _user;

  AppUser? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;

  /// Restores a saved session on startup. An expired/invalid token is dropped.
  Future<void> restore() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      if (_token == null) return;
      _user = AppUser.fromJson(await api.get('/auth/me') as Map<String, dynamic>);
    } catch (_) {
      await _clear();
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final res = await api.post('/auth/login', {'email': email, 'password': password});
    await _startSession(res as Map<String, dynamic>);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await api.post('/auth/register', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    });
    await _startSession(res as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _clear();
    notifyListeners();
  }

  Future<void> _startSession(Map<String, dynamic> res) async {
    _token = res['accessToken'] as String;
    _user = AppUser.fromJson(res['user'] as Map<String, dynamic>);
    await _storage.write(key: _tokenKey, value: _token);
    notifyListeners();
  }

  Future<void> _clear() async {
    _token = null;
    _user = null;
    await _storage.delete(key: _tokenKey);
  }
}
