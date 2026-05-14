import '../models/message_response.dart';

// Para recibir la conversación completa (QhDto)
class ConversacionResponse {
  final int id;
  final String? estado;
  final String? revisorId;
  final String? revisorNombre;
  final String? fechaInicio;
  final String? fechaAsignacion;
  final String? fechaResolucion;
  final EmisorData emisor;           // datos del alumno
  final List<MessageResponse> mensajes;

  ConversacionResponse({
    required this.id,
    this.estado,
    this.revisorId,
    this.revisorNombre,
    this.fechaInicio,
    this.fechaAsignacion,
    this.fechaResolucion,
    required this.emisor,
    required this.mensajes,
  });

factory ConversacionResponse.fromJson(Map<String, dynamic> json) {
  print('📥 JSON recibido: $json');
  
  // El ID está dentro de conversacion, no al mismo nivel
  final conversacionJson = json['conversacion'] ?? {};
  
  final emisorJson = json['emisor'] ?? {};
  
  List<MessageResponse> mensajesList = [];
  if (conversacionJson['mensajes'] != null) {
    mensajesList = List<MessageResponse>.from(
      conversacionJson['mensajes'].map(
        (x) => MessageResponse.fromJson(x)
      )
    );
  }

  return ConversacionResponse(
    id: int.tryParse(conversacionJson['id'] ?? '0') ?? 0,  // ← TOMAR EL ID DE CONVERSACION
    estado: conversacionJson['estado'],                    // ← Estado también está en conversacion
    revisorId: conversacionJson['revisorId'],
    revisorNombre: conversacionJson['revisorNombre'],
    fechaInicio: conversacionJson['fechaInicio'],        // ← En el DTO se llama fechaInicio
    fechaAsignacion: conversacionJson['fechaAsignacion'],
    fechaResolucion: conversacionJson['fechaResolucion'],
    emisor: EmisorData.fromJson(emisorJson),
    mensajes: mensajesList,
  );
}

  // Para saber si tiene mensajes
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