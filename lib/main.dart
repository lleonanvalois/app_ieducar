import 'package:app_ieducar/PontoScreen.dart';
import 'package:app_ieducar/RouteScreen.dart';
import 'package:app_ieducar/controllers/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'LoginScreen.dart';
import 'database/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseHelper();
  final user = await db.getUser('a');
  if (user == null) {
    await db.insertUser('a', 'a');
  }

  runApp(
    GetMaterialApp(
      home: LoginScreen(),
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(
          name: '/mapa',
          page: () => RouteScreen(),
          binding: BindingsBuilder(() {
            Get.put(MapController());
          }),
        ),

        GetPage(name: '/pontos', page: () => PontosScreen()),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iEducar-Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
