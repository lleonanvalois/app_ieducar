// lib/settings_screen.dart
import 'package:flutter/material.dart';

import 'package:app_ieducar/database/db.dart';
import 'services/api_services.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    final savedUrl = await _dbHelper.fnRetParametro('DS_base_url', '');
    _urlController.text = savedUrl;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    String baseUrl = _urlController.text;

    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      _urlController.text = baseUrl;
    }

    await _dbHelper.fnAddParametro('DS_base_url', baseUrl);
    await _dbHelper.fnAddParametro('IS_URL_validado', 'false');

    print('DEBUG: Attempting to save and test base URL: "$baseUrl"');

    bool connectionSuccessful = false;

    try {
      final apiResponse = await _apiService.testConnection();

      if (apiResponse.containsKey('status') &&
          apiResponse['status'] == 'success') {
        connectionSuccessful = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Validação da API bem-sucedida!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
          'Resposta da API de validação não indica sucesso: ${jsonEncode(apiResponse)}',
        );
      }

      await _dbHelper.fnAddParametro('IS_URL_validado', 'true');
    } catch (e) {
      connectionSuccessful = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Falha na validação da URL base da API: $e. URL não será considerada válida para sincronização.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      await _dbHelper.fnAddParametro('IS_URL_validado', 'false');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          connectionSuccessful
              ? 'URL base salva e validada com sucesso!'
              : 'URL base salva, mas validação falhou.',
        ),
      ),
    );
    // Navigator.pop(context);

    setState(() => _isLoading = false);
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'A URL base não pode ser vazia.';
    }

    // Regex ajustada para ser mais flexível com IPs e portas opcionais
    final uriRegExp = RegExp(
      r'^(http|https):\/\/([a-zA-Z0-9\-\.]+|((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))'
      r'(:\d+)?'
      r'(\/[\w\-\.]*)*'
      r'\/?$',
      caseSensitive: false,
      multiLine: false,
    );

    if (!uriRegExp.hasMatch(value)) {
      return 'Por favor, insira uma URL base válida (ex: http://api.exemplo.com, http://192.168.1.100, ou http://192.168.1.100:3000).';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 18, 87, 167),
        centerTitle: false,
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 18, 87, 167), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _urlController,
                              decoration: InputDecoration(
                                labelText: 'URL Base da API',
                                hintText: 'Ex: http://api.meusistema.com:8080',
                                prefixIcon: const Icon(Icons.link),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: _validateUrl,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          'SALVAR E VALIDAR API',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
