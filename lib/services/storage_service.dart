import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const _fileName = 'mindspice_data.json';

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<Map<String, dynamic>?> readAll() async {
    try {
      final f = await _file();
      if (!await f.exists()) return null;
      final s = await f.readAsString();
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> writeAll(Map<String, dynamic> data) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(data), flush: true);
  }
}
