import 'package:flutter/material.dart';
import 'local_db.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = LocalDB.getAll()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (_, i) {
          final log = logs[i];

          return ListTile(
            title: Text(
                "${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}"),
            subtitle:
                Text("${log.timestamp.hour}:${log.timestamp.minute}"),
            trailing: Icon(
              log.isSynced ? Icons.cloud_done : Icons.cloud_off,
            ),
          );
        },
      ),
    );
  }
}