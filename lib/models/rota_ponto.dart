class RotaPonto {
  final int idItinerario;
  final int nuSequencia;
  final String hrPonto;
  final String dsRotaTipo;

  RotaPonto({
    required this.idItinerario,
    required this.nuSequencia,
    required this.hrPonto,
    required this.dsRotaTipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_itinerario': idItinerario,
      'nu_sequencia': nuSequencia,
      'hr_ponto': hrPonto,
      'ds_rota_tipo': dsRotaTipo,
    };
  }
}
