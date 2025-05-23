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
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  bool _isGettingLocation = false;
  late FocusNode _nomefocusNode;

  @override
  void initState() {
    super.initState();

    if (widget.ponto != null) {
      _nomeController.text = widget.ponto!.noPonto;
      _latController.text = widget.ponto!.nuLatitude.toStringAsFixed(4);
      _longController.text = widget.ponto!.nuLongitude.toStringAsFixed(4);
    } else {
      _getCurrentLocation();
    }

    _nomefocusNode = FocusNode();
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_nomefocusNode);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final position = await LocationService.getCurrentLocation();
      _updateCoordinateFields(position);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  void _updateCoordinateFields(Position position) {
    setState(() {
      _latController.text = position.latitude.toStringAsFixed(4);
      _longController.text = position.longitude.toStringAsFixed(4);
    });
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                focusNode: _nomefocusNode,

                decoration: const InputDecoration(labelText: 'Nome do Ponto'),
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 20),

              // Campos de coordenadas manuais
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: Icon(Icons.north),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateCoordinate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _longController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: Icon(Icons.east),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateCoordinate,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Botão de captura + coordenadas atuais
              ElevatedButton.icon(
                icon:
                    _isGettingLocation
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(Icons.location_on),
                label: Text(
                  _isGettingLocation ? 'Capturando...' : 'Localização Atual',
                ),
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
              ),

              const SizedBox(height: 20),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.black,
                          ),

                          child: const Text("Cancelar"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: _salvar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Salvar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateCoordinate(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    final numValue = double.tryParse(value);
    if (numValue == null) return 'Valor inválido';

    // Verifica se é latitude
    if (value == _latController.text && (numValue < -90 || numValue > 90)) {
      return 'Latitude deve ser entre -90 e 90';
    }

    // Verifica se é longitude
    if (value == _longController.text && (numValue < -180 || numValue > 180)) {
      return 'Longitude deve ser entre -180 e 180';
    }
    return null;
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final novoPonto = Ponto(
        id: widget.ponto?.id,
        noPonto: _nomeController.text,
        nuLatitude: double.parse(_latController.text),
        nuLongitude: double.parse(_longController.text),
        dhPonto: DateTime.now().toIso8601String(),
      );
      widget.onSave(novoPonto);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _longController.dispose();
    _nomefocusNode.dispose();
    super.dispose();
  }
}
