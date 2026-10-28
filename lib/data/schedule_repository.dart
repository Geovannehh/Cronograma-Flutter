import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule_item.dart';

/// Persistência simples e offline. Para sincronização ou dados críticos,
/// substitua por SQLite/Isar + backend e mecanismos de backup.
class ScheduleRepository {
  ScheduleRepository([SharedPreferencesAsync? preferences])
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;
  static const storageKey = 'cronograma_flow_v1';

  Future<List<ScheduleItem>?> load() async {
    final raw = await _preferences.getString(storageKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Arquivo de cronograma inválido');
    return decoded.map((entry) => ScheduleItem.fromJson(
      Map<String, dynamic>.from(entry as Map),
    )).toList();
  }

  Future<void> save(List<ScheduleItem> items) async {
    final content = jsonEncode(items.map((item) => item.toJson()).toList());
    await _preferences.setString(storageKey, content);
  }
}
