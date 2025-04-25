import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'database/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseHelper();
  final user = await db.getUser('admin');
  if (user == null) {
    await db.insertUser('admin', 'teste');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iEducar-Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
