import 'local_db.dart';
import 'api_service.dart';

class SyncService {
  final ApiService api;

  SyncService(this.api);

  /// Syncs all unsynced local entries to the server.
  /// Returns the number of successfully synced entries.
  Future<int> sync(String deviceId) async {
    final unsynced = LocalDB.getUnsynced();
    int synced = 0;

    for (var log in unsynced) {
      try {
        await api.createLog(deviceId, log.id, log.timestamp);
        log.isSynced = true;
        await LocalDB.update(log);
        synced++;
      } catch (_) {
        // ignore individual failures — retry on next sync
      }
    }

    return synced;
  }
}