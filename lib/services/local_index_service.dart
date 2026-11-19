import 'package:flutter/services.dart';

/// Android SQLite/FTS4 bridge. Gracefully degrades in Dart-only tests and non-Android hosts.
class LocalIndexService {
  LocalIndexService._();
  static final LocalIndexService instance = LocalIndexService._();
  static const MethodChannel _channel = MethodChannel('com.mokshith.jarvis/accessibility');

  Future<int?> indexDocument({required String source, required String packageName, required String content}) async {
    if (content.trim().isEmpty) return null;
    try {
      return await _channel.invokeMethod<int>('indexDocument', {
        'source': source, 'packageName': packageName, 'content': content,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> search(String query, {int limit = 8}) async {
    try {
      final rows = await _channel.invokeMethod<List<dynamic>>('searchLocalIndex', {
        'query': query, 'limit': limit,
      });
      return (rows ?? const []).whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  Future<String> buildContext(String query, {int limit = 5}) async {
    final rows = await search(query, limit: limit);
    return rows.map((row) => '[' + (row['source'] ?? '').toString() + ' / ' +
      (row['packageName'] ?? '').toString() + '] ' + (row['content'] ?? '').toString()).join('\n');
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      return Map<String, dynamic>.from(
        await _channel.invokeMapMethod<String, dynamic>('getLocalIndexStats') ?? const {});
    } on MissingPluginException {
      return const {};
    } on PlatformException {
      return const {};
    }
  }

  Future<void> clear() async {
    try { await _channel.invokeMethod<void>('clearLocalIndex'); }
    on MissingPluginException { }
    on PlatformException { }
  }

  Future<void> setSocialIndexingEnabled(bool enabled) async {
    try { await _channel.invokeMethod<void>('setSocialIndexingEnabled', {'enabled': enabled}); }
    on MissingPluginException { }
    on PlatformException { }
  }

  Future<bool> isSocialIndexingEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isSocialIndexingEnabled') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
