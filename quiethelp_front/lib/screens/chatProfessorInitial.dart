// polling: permite actualizar automáticamente el chat cada pocos segundos
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../models/message_response.dart';

class ChatProfessorInitialPage extends StatefulWidget {
  final int conversacionId;
  final String category;
  final String status;
  final String dateText;
  final String schoolText;
  final String groupText;
  final String message;
  final bool urgente;
  final String revisorId;
  final String revisorNombre;

  const ChatProfessorInitialPage({
    super.key,
    required this.conversacionId,
    required this.category,
    this.status = 'Pendiente',
    required this.dateText,
    required this.schoolText,
    required this.groupText,
    required this.message,
    this.urgente = false,
    required this.revisorId,
    required this.revisorNombre,
  });

  @override
  State<ChatProfessorInitialPage> createState() =>
      _ChatProfessorInitialPageState();
}

class _ChatProfessorInitialPageState extends State<ChatProfessorInitialPage> {
  List<MessageResponse> _mensajes = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _respuestaController = TextEditingController();
  late String _status;

  // polling: temporizador que revisa mensajes nuevos automáticamente
  Timer? _pollingTimer;

  // polling: evita varias peticiones simultáneas
  bool _isRefreshing = false;

  static const bgSoft = Color(0xFFEFF7F6);

  String get _baseUrl {
    if (kIsWeb) {
      return 'https://quiethelp-back-production.up.railway.app';
    }
    return 'http://10.0.2.2:8080';
  }

  @override
  void initState() {
    super.initState();

    _status = _normalizarEstado(widget.status);
    _cargarConversacionCompleta();

    // polling: actualiza la conversación cada 2 segundos sin recargar la página
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _cargarConversacionCompleta(silencioso: true);
    });
  }

  @override
  void dispose() {
    // polling: cancela el temporizador al salir del chat
    _pollingTimer?.cancel();

    _respuestaController.dispose();
    super.dispose();
  }

  DateTime? _parseFecha(String? fecha) {
    if (fecha == null || fecha.trim().isEmpty) return null;

    final iso = DateTime.tryParse(fecha);
    if (iso != null) return iso;

    final formatos = [
      'dd/MM/yyyy HH:mm:ss:ss',
      'dd/MM/yyyy HH:mm:ss',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
    ];

    for (final formato in formatos) {
      try {
        return DateFormat(formato).parse(fecha);
      } catch (_) {}
    }

    return null;
  }

  String _normalizarEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'EN_REVISION':
        return 'En revisión';
      case 'RESUELTO':
        return 'Resuelto';
      case 'Pendiente':
      case 'En revisión':
      case 'Resuelto':
        return estado;
      default:
        return 'Pendiente';
    }
  }

  Future<void> _marcarMensajesAlumnoComoLeidos() async {
    final uri = Uri.parse(
      '$_baseUrl/api/conversaciones/${widget.conversacionId}/leidos',
    ).replace(queryParameters: {'emisor': 'alumno'});

    try {
      final response = await http.post(uri);

      print('Marcando leídos alumno: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('No se pudieron marcar como leídos: ${response.body}');
      }
    } catch (e) {
      print('Error marcando mensajes del alumno como leídos: $e');
    }
  }

  Future<void> _cargarConversacionCompleta({bool silencioso = false}) async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    final uri =
        Uri.parse(
          '$_baseUrl/api/conversaciones/${widget.conversacionId}',
        ).replace(
          queryParameters: {
            '_ts': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );

    try {
      final response = await http.get(
        uri,
        headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      );

      print('PROFESOR GET status: ${response.statusCode}');
      print('PROFESOR GET body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final mensajesOrdenados = <MessageResponse>[];

        if (json['conversacion'] != null &&
            json['conversacion']['mensajes'] != null) {
          for (final msgJson in json['conversacion']['mensajes']) {
            mensajesOrdenados.add(MessageResponse.fromJson(msgJson));
          }
        } else if (json['mensajes'] != null) {
          for (final msgJson in json['mensajes']) {
            mensajesOrdenados.add(MessageResponse.fromJson(msgJson));
          }
        }

        mensajesOrdenados.sort((a, b) {
          final fechaA = _parseFecha(a.fecha);
          final fechaB = _parseFecha(b.fecha);

          if (fechaA != null && fechaB != null) {
            final comparacionFecha = fechaA.compareTo(fechaB);

            if (comparacionFecha != 0) {
              return comparacionFecha;
            }
          }

          return a.id.compareTo(b.id);
        });

        String? estadoBackend;

        if (json['estado'] != null) {
          estadoBackend = json['estado'].toString();
        } else if (json['conversacion'] != null &&
            json['conversacion']['estado'] != null) {
          estadoBackend = json['conversacion']['estado'].toString();
        }

        if (!mounted) return;

        setState(() {
          _mensajes = mensajesOrdenados;
          _isLoading = false;
          _error = null;

          if (estadoBackend != null) {
            _status = _normalizarEstado(estadoBackend);
          }
        });

        await _marcarMensajesAlumnoComoLeidos();
      } else {
        if (!mounted) return;

        if (!silencioso) {
          setState(() {
            _error = 'Error al cargar la conversación (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      if (!silencioso) {
        setState(() {
          _error = 'Error de conexión: $e';
          _isLoading = false;
        });
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _asignarYRevisar() async {
    setState(() {
      _isLoading = true;
    });

    final uri =
        Uri.parse(
          '$_baseUrl/api/conversaciones/${widget.conversacionId}/asignar',
        ).replace(
          queryParameters: {
            'revisorId': widget.revisorId,
            'revisorNombre': widget.revisorNombre,
          },
        );

    try {
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          _status = 'En revisión';
        });

        await _cargarConversacionCompleta(silencioso: true);
      } else {
        throw Exception('Error al asignar: ${response.body}');
      }
    } catch (e) {
      print('Error al asignar: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _marcarResuelto() async {
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse(
      '$_baseUrl/api/conversaciones/${widget.conversacionId}/estado',
    ).replace(queryParameters: {'nuevoEstado': 'RESUELTO'});

    try {
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          _status = 'Resuelto';
        });
      } else {
        throw Exception('Error al marcar resuelto: ${response.body}');
      }
    } catch (e) {
      print('Error al marcar resuelto: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _enviarRespuesta() async {
    final contenido = _respuestaController.text.trim();

    if (contenido.isEmpty) {
      return;
    }

    if (!_isReview) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url =
        '$_baseUrl/api/conversaciones/${widget.conversacionId}/responder';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contenido': contenido,
          'revisorId': widget.revisorId,
          'revisorNombre': widget.revisorNombre,
        }),
      );

      if (response.statusCode == 200) {
        _respuestaController.clear();

        await _cargarConversacionCompleta(silencioso: true);
      } else {
        throw Exception('Error al enviar: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/images/quiethelp_logo.svg', height: 28),
          const SizedBox(width: 8),
          const Text(
            'QuietHelp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  bool get _isPending => _status == 'Pendiente';
  bool get _isReview => _status == 'En revisión';
  bool get _isSolved => _status == 'Resuelto';

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _mensajes.isEmpty) {
      return Scaffold(
        backgroundColor: bgSoft,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _mensajes.isEmpty) {
      return Scaffold(
        backgroundColor: bgSoft,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _cargarConversacionCompleta();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgSoft,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pad = constraints.maxWidth >= 900 ? 64.0 : 22.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _DetailCard(
                  category: widget.category,
                  status: _status,
                  dateText: widget.dateText,
                  schoolText: widget.schoolText,
                  groupText: widget.groupText,
                  mensajes: _mensajes,
                  isPending: _isPending,
                  isReview: _isReview,
                  isSolved: _isSolved,
                  isLoading: _isLoading,
                  respuestaController: _respuestaController,
                  onSend: _enviarRespuesta,
                  urgente: widget.urgente,
                  onStatusTap: (nuevoEstado) async {
                    if (_isPending && nuevoEstado == 'En revisión') {
                      await _asignarYRevisar();
                    } else if (_isReview && nuevoEstado == 'Resuelto') {
                      await _marcarResuelto();
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 360),
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 30,
                                  color: Color(0xFFFF5A5F),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No se puede cambiar de $_status a $nuevoEstado',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 175, 175, 175),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      'Entendido',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String category;
  final String status;
  final String dateText;
  final String schoolText;
  final String groupText;
  final List<MessageResponse> mensajes;
  final bool isPending;
  final bool isReview;
  final bool isSolved;
  final bool isLoading;
  final TextEditingController respuestaController;
  final VoidCallback onSend;
  final bool urgente;
  final ValueChanged<String> onStatusTap;

  const _DetailCard({
    required this.category,
    required this.status,
    required this.dateText,
    required this.schoolText,
    required this.groupText,
    required this.mensajes,
    required this.isPending,
    required this.isReview,
    required this.isSolved,
    required this.isLoading,
    required this.respuestaController,
    required this.onSend,
    required this.urgente,
    required this.onStatusTap,
  });

  static const selectedBlue = Color(0xFF0C6F8A);
  static const urgentRed = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              _InfoRow(icon: Icons.access_time, text: dateText),
              _InfoRow(icon: Icons.location_on_outlined, text: schoolText),
              if (groupText.isNotEmpty)
                _InfoRow(icon: Icons.group_outlined, text: groupText),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.08), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Chat',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              if (urgente)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: urgentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: urgentRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: urgentRed,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'URGENTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: urgentRed,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                if (mensajes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay mensajes en esta conversación'),
                  ),
                ...mensajes.map((msg) {
                  final esProfesor = msg.emisor == 'profesor';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Align(
                      alignment: esProfesor
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: _ChatBubble(
                        fromProfessor: esProfesor,
                        text: msg.mensaje,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                if (isReview) ...[
                  _ProfessorInputBox(
                    controller: respuestaController,
                    onSend: onSend,
                    isLoading: isLoading,
                  ),
                ] else if (isSolved) ...[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Conversación resuelta',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Asigna la conversación para poder responder',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.black.withOpacity(0.08), height: 1),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    _StateButton(
                      text: 'Pendiente',
                      icon: Icons.access_time,
                      selected: isPending,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('Pendiente'),
                    ),
                    const SizedBox(height: 8),
                    _StateButton(
                      text: 'En revisión',
                      icon: Icons.chat_bubble_outline,
                      selected: isReview,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('En revisión'),
                    ),
                    const SizedBox(height: 8),
                    _StateButton(
                      text: 'Resuelto',
                      icon: Icons.check_circle_outline,
                      selected: isSolved,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('Resuelto'),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _StateButton(
                      text: 'Pendiente',
                      icon: Icons.access_time,
                      selected: isPending,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('Pendiente'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StateButton(
                      text: 'En revisión',
                      icon: Icons.chat_bubble_outline,
                      selected: isReview,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('En revisión'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StateButton(
                      text: 'Resuelto',
                      icon: Icons.check_circle_outline,
                      selected: isSolved,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('Resuelto'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black.withOpacity(0.45)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.black.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool fromProfessor;
  final String text;

  const _ChatBubble({required this.fromProfessor, required this.text});

  @override
  Widget build(BuildContext context) {
    final bg = fromProfessor
        ? const Color(0xFF98CFEA)
        : const Color(0xFFDDEAF0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: Colors.black.withOpacity(0.78),
        ),
      ),
    );
  }
}

class _ProfessorInputBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const _ProfessorInputBox({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              enabled: !isLoading,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (!isLoading) {
                  onSend();
                }
              },
              decoration: InputDecoration(
                hintText: 'Mensaje...',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.25),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 38,
            width: 42,
            child: IconButton(
              onPressed: isLoading ? null : onSend,
              icon: Icon(
                Icons.send_rounded,
                size: 18,
                color: isLoading
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pendiente';
    final isReview = status == 'En revisión';
    final isSolved = status == 'Resuelto';

    Color pillBg;
    Color pillText;

    if (isPending) {
      pillBg = const Color(0xFFFFF2DE);
      pillText = const Color(0xFFE09B2D);
    } else if (isReview) {
      pillBg = const Color(0xFFE3F2FD);
      pillText = const Color(0xFF0C6F8A);
    } else if (isSolved) {
      pillBg = const Color(0xFFE8F5E9);
      pillText = const Color(0xFF2E7D32);
    } else {
      pillBg = Colors.black.withOpacity(0.06);
      pillText = Colors.black.withOpacity(0.65);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending
                ? Icons.access_time
                : isReview
                ? Icons.chat_bubble_outline
                : isSolved
                ? Icons.check_circle_outline
                : Icons.folder_outlined,
            size: 14,
            color: pillText,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: pillText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _StateButton({
    required this.text,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedColor : Colors.transparent;
    final border = selected ? selectedColor : selectedColor.withOpacity(0.8);
    final fg = selected ? Colors.white : selectedColor;

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: fg),
        label: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
