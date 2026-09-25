import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base URL is injected at build time:
///   flutter build web --dart-define=API_BASE_URL=https://api.example.com/api
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);

/// Mirrors the backend's error shape: { statusCode, error, message, details? }.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.details = const []});

  final String message;
  final int? statusCode;
  final List<String> details;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Thin JSON-over-HTTP wrapper. [tokenProvider] is read on every request so a
/// fresh login is picked up without rebuilding the client.
class ApiClient {
  ApiClient({required this.tokenProvider, http.Client? client})
      : _http = client ?? http.Client();

  final String? Function() tokenProvider;
  final http.Client _http;

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _send('POST', path, body);

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final token = tokenProvider();
    final req = http.Request(method, Uri.parse('$apiBaseUrl$path'))
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'application/json';
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    if (body != null) req.body = jsonEncode(body);

    final http.Response res;
    try {
      res = await http.Response.fromStream(
          await _http.send(req).timeout(const Duration(seconds: 60)));
    } catch (_) {
      // Network failure, CORS rejection or timeout (free Render instances cold-start slowly).
      throw ApiException('Could not reach the server. Check your connection and try again.');
    }

    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

    final map = decoded is Map<String, dynamic> ? decoded : const <String, dynamic>{};
    throw ApiException(
      map['message']?.toString() ?? 'Something went wrong (${res.statusCode})',
      statusCode: res.statusCode,
      details: (map['details'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

/// Render's free tier sleeps idle services (~50s cold start). Pinging /health
/// as soon as the app boots starts that wake-up while the user is still typing,
/// so sign in / sign up don't pay the delay. Fire-and-forget; errors ignored.
void wakeBackend() {
  http.get(Uri.parse('$apiBaseUrl/health')).timeout(const Duration(seconds: 90)).ignore();
}
