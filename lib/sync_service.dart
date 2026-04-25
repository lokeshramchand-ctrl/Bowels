import 'local_db.dart';
import 'api_service.dart';

class SyncService {
  final ApiService api;

  SyncService(this.api);

  Future<void> sync(String deviceId) async {
    final unsynced = LocalDB.getUnsynced();

    for (var log in unsynced) {
      try {
        await api.createLog(deviceId, log.id, log.timestamp);
        log.isSynced = true;
        await LocalDB.update(log);
      } catch (_) {
        // ignore, retry later
      }
    }
  }
}