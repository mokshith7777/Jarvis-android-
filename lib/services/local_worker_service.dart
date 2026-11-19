import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settings_service.dart';
class LocalWorkerService {
  LocalWorkerService._();
  static final LocalWorkerService instance = LocalWorkerService._();
  static const Duration _timeout = Duration(minutes: 20);
  String get baseUrl {
    final url = SettingsService.instance.baseUrl.trim();
    if (SettingsService.instance.provider == 'jarvis_local' && url.isNotEmpty) {
      return url.replaceFirst(RegExp(r'/v1/?$'), '');
    }
    return 'http://127.0.0.1:9000';
  }
  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await http.post(Uri.parse(baseUrl + path),
      headers: const {'Content-Type': 'application/json'}, body: jsonEncode(body)).timeout(_timeout);
    final data = response.body.isEmpty ? <String, dynamic>{} : Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception((data['detail'] ?? 'Local worker HTTP ') .toString() + response.statusCode.toString());
    }
    return data;
  }
  Future<Map<String, dynamic>> health() async {
    final response = await http.get(Uri.parse(baseUrl + '/health')).timeout(const Duration(seconds: 5));
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }
  Future<Map<String, dynamic>> browse(String query) => _post('/browse', {'query': query});
  Future<Map<String, dynamic>> generateImage(String prompt) => _post('/generate-image', {'prompt': prompt});
  Future<Map<String, dynamic>> editVideo(String inputPath) => _post('/edit-video', {'input_path': inputPath});
  Future<Map<String, dynamic>> generateStoryboardVideo(String prompt) =>
    _post('/generate-storyboard-video', {'prompt': prompt, 'scenes': 4});
}