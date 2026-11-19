import 'package:flutter/services.dart';
class LocalIndexService {
  LocalIndexService._();
  static final LocalIndexService instance = LocalIndexService._();
  static const MethodChannel _channel = MethodChannel('com.mokshith.jarvis/accessibility');
  Future<int?> indexDocument({required String source, required String packageName, required String content}) async {
    if (content.trim().isEmpty) return null;
    return _channel.invokeMethod<int>('indexDocument', {'source': source, 'packageName': packageName, 'content': content});
  }
  Future<List<Map<String, dynamic>>> search(String query, {int limit = 8}) async {
    final rows = await _channel.invokeMethod<List<dynamic>>('searchLocalIndex', {'query': query, 'limit': limit});
    return (rows ?? const []).whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
  }
  Future<String> buildContext(String query, {int limit = 5}) async {
    final rows = await search(query, limit: limit);
    return rows.map((row) => '[' + (row['source'] ?? '').toString() + ' / ' +
      (row['packageName'] ?? '').toString() + '] ' + (row['content'] ?? '').toString()).join('\n');
  }
  Future<Map<String, dynamic>> getStats() async => Map<String, dynamic>.from(
    await _channel.invokeMapMethod<String, dynamic>('getLocalIndexStats') ?? const {});
  Future<void> clear() => _channel.invokeMethod<void>('clearLocalIndex');
  Future<void> setSocialIndexingEnabled(bool enabled) =>
    _channel.invokeMethod<void>('setSocialIndexingEnabled', {'enabled': enabled});
  Future<bool> isSocialIndexingEnabled() async =>
    await _channel.invokeMethod<bool>('isSocialIndexingEnabled') ?? false;
}