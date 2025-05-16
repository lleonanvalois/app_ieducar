import 'package:app_ieducar/RouteScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'PontoScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _pontos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PontosScreen()),
    );
  }

  void _sincronizar() {
    // Ação de sincronização
  }

  void _rotas() {
    Get.to(() => RouteScreen());
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmação"),
            content: const Text("Deseja sair do sistema?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Sair"),
              ),
            ],
          ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'iEducar - Transporte',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent, // Fundo transparente
          elevation: 0, // Remove a sombra
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 0, 68, 146),
                  Color.fromARGB(255, 18, 87, 167),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 18, 87, 167), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildActionButton(
                    icon: Icons.map,
                    label: "Rotas",
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    onPressed: () => Get.toNamed('/routas'),
                  ),
                  const SizedBox(width: 20),

                  _buildActionButton(
                    icon: Icons.location_on,
                    label: "Pontos",
                    iconColor: Colors.red,
                    textColor: Colors.white,
                    onPressed: () => Get.toNamed('/pontos'),
                  ),
                  const SizedBox(width: 20),

                  _buildActionButton(
                    icon: Icons.sync,
                    label: "Sync",
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    onPressed: _sincronizar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          iconSize: 40,
          icon: Icon(icon, color: iconColor),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
