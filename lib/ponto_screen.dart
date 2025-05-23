import 'package:app_ieducar/models/ponto.dart';
import 'package:app_ieducar/repositories/ponto_repository.dart';
import 'package:app_ieducar/widgets/ponto_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Crie um Controller para gerenciar o estado da tela de pontos
class PontosController extends GetxController {
  final RxList<Ponto> pontos = <Ponto>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    carregarPontos();
  }

  Future<void> carregarPontos() async {
    try {
      isLoading.value = true;
      final data = await PontoRepository.carregarPontos();
      pontos.assignAll(data);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar pontos: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> adicionarPonto(Ponto novoPonto) async {
    try {
      await PontoRepository.salvarPonto(novoPonto);
      await carregarPontos();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao adicionar ponto: ${e.toString()}');
    }
  }

  Future<void> editarPonto(Ponto pontoEditado) async {
    try {
      await PontoRepository.salvarPonto(pontoEditado);
      await carregarPontos();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao editar ponto: ${e.toString()}');
    }
  }

  Future<void> excluirPonto(int id) async {
    try {
      await PontoRepository.excluirPonto(id);
      await carregarPontos();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao excluir ponto: ${e.toString()}');
    }
  }
}

class PontosScreen extends StatelessWidget {
  final PontosController pontosController = Get.put(PontosController());

  PontosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Pontos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarFormulario(context),
          ),
        ],
      ),
      body: Obx(
        () =>
            pontosController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : pontosController.pontos.isEmpty
                ? const Center(child: Text('Nenhum ponto cadastrado'))
                : ListView.separated(
                  itemCount: pontosController.pontos.length,
                  separatorBuilder:
                      (context, index) => const Divider(
                        color: Colors.grey,
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  itemBuilder: (context, index) {
                    final ponto = pontosController.pontos[index];
                    return ListTile(
                      title: Text(ponto.noPonto),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lat: ${ponto.nuLatitude.toStringAsFixed(4)}, '
                            'Long: ${ponto.nuLongitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(ponto.dhPonto))}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.map),
                            onPressed: () => _mostrarNoMapa(ponto),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _mostrarFormulario(context, ponto: ponto),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text("Confirmar exclusão"),
                                      content: const Text(
                                        "Deseja realmente excluir este ponto?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            "Excluir",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text("Cancelar"),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                pontosController.excluirPonto(ponto.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, {Ponto? ponto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PontoForm(
              ponto: ponto,
              onSave: (pontoEditado) {
                if (pontoEditado.id == null) {
                  pontosController.adicionarPonto(pontoEditado);
                } else {
                  pontosController.editarPonto(pontoEditado);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _mostrarNoMapa(Ponto ponto) {
    Get.toNamed(
      '/mapa',
      arguments: {
        'editarPontoId': ponto.id,
        'latitude': ponto.nuLatitude,
        'longitude': ponto.nuLongitude,
      },
    );
  }
}
