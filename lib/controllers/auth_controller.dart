import 'package:app_ieducar/HomeScreen.dart';
import 'package:app_ieducar/database/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final obscurePassword = true.obs;

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    final isValid = await DatabaseHelper().validateUser(username, password);
    isLoading.value = false;

    if (isValid) {
      Get.offAll(const HomeScreen());
    } else {
      Get.snackbar(
        'Erro',
        'Credenciais invalidas! Usuáario ou senha incorretos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
}
