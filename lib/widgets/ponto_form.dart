import 'package:app_ieducar/services/location_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_ieducar/models/ponto.dart';

class PontoForm extends StatefulWidget {
  final Ponto? ponto;
  final Function(Ponto) onSave;

  const PontoForm({super.key, this.ponto, required this.onSave});

  @override
  State<PontoForm> createState() => _PontoFormState();
}

class _PontoFormState extends State<PontoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    if (widget.ponto != null) {
      _nomeController.text = widget.ponto!.nome;
      _descricaoController.text = widget.ponto!.descricao;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Localização capturada: ${position.latitude.toStringAsFixed(4)}, '
            '${position.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Ponto'),
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Capturar Localização Atual'),
              onPressed: _getCurrentLocation,
            ),
            if (_currentPosition != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Coordenadas: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                  '${_currentPosition!.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvar,
              child: const Text('Salvar Ponto'),
            ),
          ],
        ),
      ),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate() && _currentPosition != null) {
      final novoPonto = Ponto(
        id: widget.ponto?.id,
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        data: widget.ponto?.data ?? DateTime.now(),
      );
      widget.onSave(novoPonto);
      Navigator.pop(context);
    } else if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, capture a localização primeiro'),
        ),
      );
    }
  }
}
