import 'package:app_ieducar/models/ponto.dart';
import 'package:app_ieducar/repositories/ponto_repository.dart';
import 'package:app_ieducar/widgets/ponto_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PontosScreen extends StatefulWidget {
  const PontosScreen({super.key});

  @override
  State<PontosScreen> createState() => _PontosScreenState();
}

class _PontosScreenState extends State<PontosScreen> {
  List<Ponto> pontos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPontos();
  }

  Future<void> _carregarPontos() async {
    setState(() => isLoading = true);
    pontos = await PontoRepository.carregarPontos();
    setState(() => isLoading = false);
  }

  Future<void> _adicionarPonto(Ponto novoPonto) async {
    await PontoRepository.salvarPonto(novoPonto);
    await _carregarPontos();
  }

  Future<void> _editarPonto(Ponto pontoEditado) async {
    await PontoRepository.salvarPonto(pontoEditado);
    await _carregarPontos();
  }

  Future<void> _excluirPonto(int id) async {
    await PontoRepository.excluirPonto(id);
    await _carregarPontos();
  }

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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : pontos.isEmpty
              ? const Center(child: Text('Nenhum ponto cadastrado'))
              : ListView.separated(
                itemCount: pontos.length,
                separatorBuilder:
                    (context, index) => const Divider(
                      color: Colors.grey,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(pontos[index].nome),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pontos[index].descricao),
                          Text(
                            'Lat: ${pontos[index].latitude.toStringAsFixed(4)}, '
                            'Long: ${pontos[index].longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(pontos[index].data)}',
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
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _mostrarFormulario(
                                  context,
                                  ponto: pontos[index],
                                ),
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
                                _excluirPonto(pontos[index].id!);
                              }
                            },
                          ),
                        ],
                      ),
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
                  _adicionarPonto(pontoEditado);
                } else {
                  _editarPonto(pontoEditado);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
