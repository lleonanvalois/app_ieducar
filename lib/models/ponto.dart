class Ponto {
  final int? id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;
  final DateTime data;

  Ponto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'data': data.toIso8601String(),
    };
  }

  factory Ponto.fromMap(Map<String, dynamic> map) {
    return Ponto(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      data: DateTime.parse(map['data']),
    );
  }
}
