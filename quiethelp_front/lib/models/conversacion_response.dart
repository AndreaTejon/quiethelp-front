import '../models/message_response.dart';

class ConversacionResponse {
  final int id;
  final String? estado;
  final String? revisorId;
  final String? revisorNombre;
  final String? fechaInicio;
  final String? fechaAsignacion;
  final String? fechaResolucion;
  final EmisorData emisor;
  final List<MessageResponse> mensajes;
  final bool cadenaVerificada;

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
    required this.cadenaVerificada
  });

  factory ConversacionResponse.fromJson(Map<String, dynamic> json) {
    final conversacionJson =
        Map<String, dynamic>.from(json['conversacion'] ?? {});

    final emisorJson =
        Map<String, dynamic>.from(json['emisor'] ?? {});

    final mensajesJson = conversacionJson['mensajes'];

    final mensajesList = mensajesJson is List
        ? mensajesJson
            .map(
              (x) => MessageResponse.fromJson(
                Map<String, dynamic>.from(x),
              ),
            )
            .toList()
        : <MessageResponse>[];

    return ConversacionResponse(
      id: _parseInt(conversacionJson['id']),
      estado: conversacionJson['estado']?.toString(),
      revisorId: conversacionJson['revisorId']?.toString(),
      revisorNombre: conversacionJson['revisorNombre']?.toString(),
      fechaInicio: conversacionJson['fechaInicio']?.toString(),
      fechaAsignacion: conversacionJson['fechaAsignacion']?.toString(),
      fechaResolucion: conversacionJson['fechaResolucion']?.toString(),
      emisor: EmisorData.fromJson(emisorJson),
      mensajes: mensajesList,
      cadenaVerificada: json['conversacion']?['cadenaVerificada'] ?? false,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool get tieneMensajes => mensajes.isNotEmpty;

  MessageResponse? get primerMensaje {
  if (!tieneMensajes) return null;

  final mensajesOrdenados = [...mensajes];

  mensajesOrdenados.sort((a, b) {
    final fechaA = _parseFecha(a.fecha);
    final fechaB = _parseFecha(b.fecha);

    if (fechaA == null && fechaB == null) return 0;
    if (fechaA == null) return 1;
    if (fechaB == null) return -1;

    return fechaB.compareTo(fechaA);
  });

  return mensajesOrdenados.first;
}

static DateTime? _parseFecha(String fecha) {
  final partes = fecha.split(' ');
  if (partes.length != 2) return DateTime.tryParse(fecha);

  final fechaPartes = partes[0].split('/');
  final horaPartes = partes[1].split(':');

  if (fechaPartes.length != 3 || horaPartes.length < 2) {
    return DateTime.tryParse(fecha);
  }

  return DateTime.tryParse(
    '${fechaPartes[2]}-${fechaPartes[1]}-${fechaPartes[0]} '
    '${horaPartes[0]}:${horaPartes[1]}:00',
  );
}
}

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
      curso: json['curso']?.toString(),
      grupo: json['grupo']?.toString(),
      tarjeta: json['tarjeta']?.toString() ?? 'Otro',
      urgente: json['urgente'] == true,
    );
  }
}