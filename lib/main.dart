import 'package:flutter/material.dart';
import 'package:popper/mock_data.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_db.dart';
import 'homescreen.dart';
import 'history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDB.init();
  await MockData.seed();
  final prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');

  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await prefs.setString('device_id', deviceId);
  }

  runApp(MyApp(deviceId));
}

class MyApp extends StatelessWidget {
  final String deviceId;

  const MyApp(this.deviceId, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => HomeScreen(deviceId: deviceId),
        '/history': (_) => const HistoryScreen(),
      },
    );
  }
}