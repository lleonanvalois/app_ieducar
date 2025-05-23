// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'package:app_ieducar/database/db.dart';
import 'dart:convert';

class ApiService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Método para obter a URL base salva no banco de dados
  Future<String> _getBaseUrl() async {
    final baseUrl = await _dbHelper.fnRetParametro('DS_base_url', '');
    if (baseUrl.isEmpty) {
      throw Exception(
        'URL base da API não configurada. Por favor, configure-a nas configurações.',
      );
    }

    return baseUrl;
  }

  Future<Map<String, dynamic>> testConnection() async {
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse(
      baseUrl,
    ); // A URL de teste é a própria baseUrl digitada pelo usuário

    print('DEBUG API: Tentando conectar a URL de validação (baseUrl): $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 7));

      print(
        'DEBUG API: Resposta da validação - Status: ${response.statusCode}',
      );
      print('DEBUG API: Resposta da validação - Corpo: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> responseBody = json.decode(
              response.body,
            );
            // VALIDAÇÃO CRÍTICA: Espera 'status: "success"' ou 'code: 200, status: "success"'

            if (responseBody.containsKey('status') &&
                responseBody['status'] == 'success') {
              return responseBody; // Retorna o JSON completo que indica sucesso
            } else {
              throw Exception(
                'API de validação respondeu com status 200, mas o corpo da resposta não indica sucesso (esperado {"status": "success"}). Corpo: ${response.body}',
              );
            }
          } catch (e) {
            throw Exception(
              'API de validação respondeu com status 200, mas o corpo da resposta não é um JSON válido ou não contém a estrutura esperada. Erro: $e',
            );
          }
        } else {
          throw Exception(
            'API de validação respondeu com status 200, mas o corpo da resposta está vazio. Não foi possível validar.',
          );
        }
      } else {
        throw Exception(
          'API de validação respondeu com erro. Status: ${response.statusCode}, Corpo: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Erro de rede ao testar conexão com API de validação: Não foi possível conectar ao servidor. Verifique sua conexão e a URL base. Erro: $e',
      );
    } on Exception catch (e) {
      throw Exception(
        'Erro inesperado ao testar conexão com API de validação: $e',
      );
    }
  }

  Future<Map<String, dynamic>> get(String fullPathEndpoint) async {
    final url = Uri.parse(fullPathEndpoint);
    print('DEBUG API: Fazendo requisição GET para: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print(
        'DEBUG API: Resposta GET de $fullPathEndpoint - Status: ${response.statusCode}',
      );
      print(
        'DEBUG API: Resposta GET de $fullPathEndpoint - Corpo: ${response.body}',
      );
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'message': 'Resposta da API vazia.'};
        }
        return json.decode(response.body);
      } else {
        throw Exception(
          'Falha ao carregar dados do $fullPathEndpoint. Status: ${response.statusCode}, Corpo: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Erro de rede: Não foi possível conectar ao servidor. Verifique sua conexão e a URL base. Erro: $e',
      );
    } on Exception catch (e) {
      throw Exception(
        'Erro inesperado ao fazer requisição GET para $fullPathEndpoint: $e',
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String fullPathEndpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(fullPathEndpoint);
    print('DEBUG API: Fazendo requisição POST para: $url');
    print('DEBUG API: Corpo da requisição POST: ${json.encode(data)}');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));
      print(
        'DEBUG API: Resposta POST de $fullPathEndpoint - Status: ${response.statusCode}',
      );
      print(
        'DEBUG API: Resposta POST de $fullPathEndpoint - Corpo: ${response.body}',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        } else {
          return {
            'message': 'Operação POST bem-sucedida, sem conteúdo de resposta.',
          };
        }
      } else {
        throw Exception(
          'Falha ao enviar dados para $fullPathEndpoint. Status: ${response.statusCode}, Corpo: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Erro de rede: Não foi possível conectar ao servidor. Verifique sua conexão e a URL base. Erro: $e',
      );
    } on Exception catch (e) {
      throw Exception(
        'Erro inesperado ao fazer requisição POST para $fullPathEndpoint: $e',
      );
    }
  }
}
