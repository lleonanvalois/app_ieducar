class Ponto {
  final int? id;
  final String noPonto; // Nome do ponto
  final String dsPonto; // Descrição
  final double nuLatitude;
  final double nuLongitude;
  final String dhPonto; // Data/hora

  Ponto({
    this.id,
    required this.noPonto,
    required this.dsPonto,
    required this.nuLatitude,
    required this.nuLongitude,
    required this.dhPonto,
  });

  // Mapeamento CORRETO para o banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id_ponto': id,
      'no_ponto': noPonto,
      'ds_ponto': dsPonto,
      'nu_latitude': nuLatitude,
      'nu_longitude': nuLongitude,
      'dh_ponto': dhPonto,
    };
  }

  factory Ponto.fromMap(Map<String, dynamic> map) {
    return Ponto(
      id: map['id_ponto'],
      noPonto: map['no_ponto'],
      dsPonto: map['ds_ponto'],
      nuLatitude: map['nu_latitude'],
      nuLongitude: map['nu_longitude'],
      dhPonto: map['dh_ponto'],
    );
  }
}
