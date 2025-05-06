class Coordenada {
  final int id;
  final double latitude;
  final double longitude;
  final DateTime timeSrtamp;
  final int usuarioId;

  Coordenada({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timeSrtamp,
    required this.usuarioId,
  });

  factory Coordenada.fromMap(Map<String, dynamic> map) {
    return Coordenada(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timeSrtamp: DateTime.fromMillisecondsSinceEpoch(map['timeSrtamp']),
      usuarioId: map['usuario_id'],
    );
  }
}
