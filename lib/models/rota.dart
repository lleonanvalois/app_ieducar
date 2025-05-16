class Rota {
  final int idRota;
  final String dhRota;
  final int cdRota;
  final String dsRota;
  final String dsDestino;

  Rota({
    required this.idRota,
    required this.dhRota,
    required this.cdRota,
    required this.dsRota,
    required this.dsDestino,
  });
  // Mapeamento para o banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id_rota': idRota,
      'dh_rota': dhRota,
      'cd_rota': cdRota,
      'ds_rota': dsRota,
      'ds_destino': dsDestino,
    };
  }
}
