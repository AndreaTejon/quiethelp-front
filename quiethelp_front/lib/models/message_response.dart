// Para recibir mensajes (QhMensajeDto)
class MessageResponse {
  final String emisor;    // "alumno" o "profesor"
  final String mensaje;   // contenido
  final String fecha;     // fecha formateada
  final bool leido;

  MessageResponse({
    required this.emisor,
    required this.mensaje,
    required this.fecha,
    required this.leido,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      emisor: json['emisor'] ?? 'alumno',
      mensaje: json['mensaje'] ?? '',
      fecha: json['fecha'] ?? '',
      leido: json['leido'] ?? false,
    );
  }
}