class MessageResponse {
  final int id;
  final String emisor;
  final String mensaje;
  final String fecha;
  final bool leido;

  MessageResponse({
    required this.id,
    required this.emisor,
    required this.mensaje,
    required this.fecha,
    required this.leido,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      emisor: json['emisor']?.toString() ?? 'alumno',
      mensaje: json['mensaje']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      leido: _parseBool(json['leido']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value?.toString().toLowerCase().trim();

    return text == 'true' || text == '1';
  }
}