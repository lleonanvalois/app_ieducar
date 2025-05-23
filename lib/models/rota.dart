import 'ponto.dart';

class Rota {
  final int idRota;
  final String nuAno;
  final String noRota;
  final String dsRota;
  final String dsDestino;
  List<Ponto> pontos;

  Rota({
    required this.idRota,
    required this.nuAno,
    required this.noRota,
    required this.dsRota,
    required this.dsDestino,
    this.pontos = const [],
  });
  // Mapeamento para o banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id_rota': idRota,
      'nu_ano': nuAno,
      'no_rota': noRota,
      'ds_rota': dsRota,
      'ds_destino': dsDestino,
    };
  }
}
