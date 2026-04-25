import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'log_entry.dart';
import 'local_db.dart';
import 'api_service.dart';
import 'sync_service.dart';

class HomeScreen extends StatefulWidget {
  final String deviceId;

  const HomeScreen({super.key, required this.deviceId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();
  late SyncService sync;

  bool doneToday = false;
  DateTime? lastTime;

  @override
  void initState() {
    super.initState();
    sync = SyncService(api);
    load();
  }

  Future<void> load() async {
    final logs = LocalDB.getAll();

    if (logs.isNotEmpty) {
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      lastTime = logs.first.timestamp;
    }

    final today = DateTime.now();
    doneToday = logs.any((e) =>
        e.timestamp.day == today.day &&
        e.timestamp.month == today.month &&
        e.timestamp.year == today.year);

    setState(() {});

    // background sync
    await sync.sync(widget.deviceId);
  }

  Future<void> addLog() async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    final entry = LogEntry(id: id, timestamp: now);

    await LocalDB.save(entry);

    setState(() {
      doneToday = true;
      lastTime = now;
    });

    await sync.sync(widget.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              doneToday ? "Done today ✅" : "Not yet ❌",
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 20),
            if (lastTime != null)
              Text("Last: ${lastTime!.hour}:${lastTime!.minute}"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: doneToday ? null : addLog,
              child: const Text("I did it"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: const Text("History"),
            ),
          ],
        ),
      ),
    );
  }
}