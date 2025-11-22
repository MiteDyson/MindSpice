import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const _fileName = 'mindspice_data.json';

  // Memory cache to prevent read-write race conditions
  static Map<String, dynamic> _cache = {};
  static bool _isInitialized = false;

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // Load data once at startup
  static Future<void> _init() async {
    if (_isInitialized) return;
    try {
      final f = await _file();
      if (await f.exists()) {
        final content = await f.readAsString();
        if (content.isNotEmpty) {
          _cache = jsonDecode(content) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      // On error, start with empty cache
      print("Error initializing storage: $e");
    }
    _isInitialized = true;
  }

  // Get data (reads from RAM, super fast & safe)
  static Future<Map<String, dynamic>> readAll() async {
    await _init();
    return _cache;
  }

  // Save specific key (Updates RAM -> Writes to Disk)
  static Future<void> save(String key, dynamic value) async {
    await _init();
    _cache[key] = value; // Update memory immediately

    // Persist to disk
    try {
      final f = await _file();
      await f.writeAsString(jsonEncode(_cache), flush: true);
    } catch (e) {
      print("Error saving data: $e");
    }
  }
}
