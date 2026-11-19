import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class LocalWorkerService {
  LocalWorkerService._({http.Client? client, String? baseUrlOverride})
      : _client = client ?? http.Client(),
        _baseUrlOverride = baseUrlOverride;

  factory LocalWorkerService.forTesting({
    required http.Client client,
    required String baseUrl,
  }) => LocalWorkerService._(client: client, baseUrlOverride: baseUrl);

  static final LocalWorkerService instance = LocalWorkerService._();
  final http.Client _client;
  final String? _baseUrlOverride;
  static const Duration _timeout = Duration(minutes: 20);

  String get baseUrl {
    if (_baseUrlOverride != null) return _baseUrlOverride!;
    final url = SettingsService.instance.baseUrl.trim();
    if (SettingsService.instance.provider == 'jarvis_local' && url.isNotEmpty) {
      return url.replaceFirst(RegExp(r'/v1/?$'), '');
    }
    return 'http://127.0.0.1:9000';
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{'detail': body};
    } on FormatException {
      return <String, dynamic>{'detail': body};
    } catch (_) {
      return <String, dynamic>{'detail': body};
    }
  }

  String _httpError(Map<String, dynamic> data, int statusCode) =>
      "${data['detail'] ?? 'Local worker error'} (HTTP $statusCode)";

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse(baseUrl + path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);
      final data = _decodeBody(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_httpError(data, response.statusCode));
      }
      return data;
    } catch (error) {
      if (error is Exception && error.toString().contains('(HTTP ')) rethrow;
      throw Exception('Local worker request failed: $error');
    }
  }

  Future<Map<String, dynamic>> health() async {
    try {
      final response = await _client.get(Uri.parse(baseUrl + '/health'))
          .timeout(const Duration(seconds: 5));
      final data = _decodeBody(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_httpError(data, response.statusCode));
      }
      return data;
    } catch (error) {
      if (error is Exception && error.toString().contains('(HTTP ')) rethrow;
      throw Exception('Local worker health check failed: $error');
    }
  }

  Future<Map<String, dynamic>> browse(String query) =>
      _post('/browse', {'query': query});
  Future<Map<String, dynamic>> generateImage(String prompt) =>
      _post('/generate-image', {'prompt': prompt});
  Future<Map<String, dynamic>> editVideo(String inputPath) =>
      _post('/edit-video', {'input_path': inputPath});
  Future<Map<String, dynamic>> generateStoryboardVideo(String prompt) =>
      _post('/generate-storyboard-video', {'prompt': prompt, 'scenes': 4});
}
