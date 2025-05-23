import 'package:app_ieducar/models/ponto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_ieducar/controllers/map_controller.dart';

class RouteScreen extends StatelessWidget {
  final MapController mapController = Get.put(MapController());

  RouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rotas')),
      body: Obx(() {
        if (mapController.rotas.isEmpty) {
          return const Center(child: Text('Nenhuma rota encontrada.'));
        } else {
          return ListView.builder(
            itemCount: mapController.rotas.length,
            itemBuilder: (context, index) {
              final rota = mapController.rotas[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(''),
                  subtitle: Text('Pontos: ${rota.pontos.length}'),
                  onTap: () {
                    Get.toNamed(
                      '/mapa',
                      arguments: {
                        'rota': rota, // Passa a rota selecionada como argumento
                      },
                    );
                  },
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateRouteDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateRouteDialog(BuildContext context) {
    String nomeRota = '';
    List<Ponto> pontosSelecionados = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Criar Nova Rota'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nome da Rota',
                      ),
                      onChanged: (value) {
                        nomeRota = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: mapController.pontos.length,
                        itemBuilder: (context, index) {
                          final ponto = mapController.pontos[index];
                          return CheckboxListTile(
                            title: Text(ponto.noPonto),
                            value: pontosSelecionados.contains(ponto),
                            onChanged: (bool? value) {
                              if (value != null) {
                                setState(() {
                                  if (value) {
                                    pontosSelecionados.add(ponto);
                                  } else {
                                    pontosSelecionados.remove(ponto);
                                  }
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeRota.isNotEmpty && pontosSelecionados.isNotEmpty) {
                  mapController.criarRotas();
                  Navigator.of(context).pop();
                } else {
                  Get.snackbar(
                    'Atenção',
                    'Preencha o nome e selecione os pontos.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }
}
