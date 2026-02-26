import '../models/message_response.dart';

// Para recibir la conversación completa (QhDto)
class ConversacionResponse {
  final int id;
  final String? estado;
  final String? revisorId;
  final String? revisorNombre;
  final String? fechaRecibido;
  final String? fechaAsignacion;
  final String? fechaResolucion;
  final EmisorData emisor;           // datos del alumno
  final List<MessageResponse> mensajes;

  ConversacionResponse({
    required this.id,
    this.estado,
    this.revisorId,
    this.revisorNombre,
    this.fechaRecibido,
    this.fechaAsignacion,
    this.fechaResolucion,
    required this.emisor,
    required this.mensajes,
  });

  factory ConversacionResponse.fromJson(Map<String, dynamic> json) {
    // Datos del emisor
    final emisorJson = json['emisor'] ?? {};
    
    // Mensajes (vienen dentro de conversacion.mensajes)
    List<MessageResponse> mensajesList = [];
    if (json['conversacion'] != null && 
        json['conversacion']['mensajes'] != null) {
      mensajesList = List<MessageResponse>.from(
        json['conversacion']['mensajes'].map(
          (x) => MessageResponse.fromJson(x)
        )
      );
    }

    return ConversacionResponse(
      id: json['id'] ?? 0,
      estado: json['estado'],
      revisorId: json['revisorId'],
      revisorNombre: json['revisorNombre'],
      fechaRecibido: json['fechaRecibido'],
      fechaAsignacion: json['fechaAsignacion'],
      fechaResolucion: json['fechaResolucion'],
      emisor: EmisorData.fromJson(emisorJson),
      mensajes: mensajesList,
    );
  }

  // Getter útil para saber si tiene mensajes
  bool get tieneMensajes => mensajes.isNotEmpty;
  
  // Getter para el primer mensaje (dashboard)
  MessageResponse? get primerMensaje => tieneMensajes ? mensajes.first : null;
}

// Datos del emisor (alumno)
class EmisorData {
  final String? curso;
  final String? grupo;
  final String tarjeta;
  final bool urgente;

  EmisorData({
    this.curso,
    this.grupo,
    required this.tarjeta,
    required this.urgente,
  });

  factory EmisorData.fromJson(Map<String, dynamic> json) {
    return EmisorData(
      curso: json['curso'],
      grupo: json['grupo'],
      tarjeta: json['tarjeta'] ?? 'Otro',
      urgente: json['urgente'] ?? false,
    );
  }
}