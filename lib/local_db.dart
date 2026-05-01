import 'package:hive_flutter/hive_flutter.dart';
import 'log_entry.dart';

class LocalDB {
  static const boxName = "logs";

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(LogEntryAdapter());
    await Hive.openBox<LogEntry>(boxName);
  }

  static Box<LogEntry> get box => Hive.box<LogEntry>(boxName);

  static Future<void> save(LogEntry entry) async {
    await box.put(entry.id, entry);
  }

  static List<LogEntry> getAll() {
    return box.values.toList();
  }

  static List<LogEntry> getUnsynced() {
    return box.values.where((e) => !e.isSynced).toList();
  }

  static Future<void> update(LogEntry entry) async {
    await entry.save();
  }

  static Future<void> delete(String id) async {
    await box.delete(id);
  }
}