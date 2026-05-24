// chatPageStudent.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'chatHistoryStudent.dart';

class _MessageResponse {
  final int id;
  final String emisor;
  final String mensaje;
  final String fecha;
  final bool leido;

  _MessageResponse({
    required this.id,
    required this.emisor,
    required this.mensaje,
    required this.fecha,
    required this.leido,
  });

  factory _MessageResponse.fromJson(Map<String, dynamic> json) {
    return _MessageResponse(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      emisor: json['emisor'] ?? 'alumno',
      mensaje: json['mensaje'] ?? '',
      fecha: json['fecha'] ?? '',
      leido: json['leido'] == true,
    );
  }
}

class ChatPageStudent extends StatefulWidget {
  final int conversacionId;
  final String token;
  final String title;
  final String tag;
  final String dateText;
  final String placeText;
  final String courseText;
  final String estado;

  const ChatPageStudent({
    super.key,
    required this.conversacionId,
    required this.token,
    required this.title,
    required this.tag,
    required this.dateText,
    required this.placeText,
    required this.courseText,
    required this.estado,
  });

  @override
  State<ChatPageStudent> createState() => _ChatPageStudentState();
}

class _ChatPageStudentState extends State<ChatPageStudent> {
  static const bgSoft = Color(0xFFEFF7F6);

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    return 'http://10.0.2.2:8080';
  }

  final TextEditingController _ctrl = TextEditingController();

  List<_MessageResponse> _mensajes = [];

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isCheckingOtherChats = false;
  bool _hasUnreadMessagesInOtherChats = false;

  String? _error;

  Timer? _pollingTimer;
  Timer? _otherChatsNotificationTimer;

  @override
  void initState() {
    super.initState();

    _cargarConversacion();
    _checkOtherChatsNotifications();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _cargarConversacion(silencioso: true),
    );

    _otherChatsNotificationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkOtherChatsNotifications(),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _otherChatsNotificationTimer?.cancel();

    _ctrl.dispose();
    super.dispose();
  }

  DateTime? _parseFecha(String fecha) {
    if (fecha.trim().isEmpty) return null;

    final iso = DateTime.tryParse(fecha);
    if (iso != null) return iso;

    final formatos = [
      'dd/MM/yyyy HH:mm:ss',
      'dd/MM/yyyy HH:mm',
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

  Future<void> _marcarMensajesProfesorComoLeidos() async {
    final uri = Uri.parse(
      '$_baseUrl/api/conversaciones/${widget.conversacionId}/leidos',
    ).replace(queryParameters: {
      'emisor': 'profesor',
    });

    try {
      final response = await http.post(uri);

      print('Marcando leídos profesor: ${response.statusCode}');
      print('Respuesta: ${response.body}');
    } catch (e) {
      print('Error marcando mensajes como leídos: $e');
    }
  }

  Future<void> _checkOtherChatsNotifications() async {
    if (_isCheckingOtherChats) return;

    _isCheckingOtherChats = true;

    final uri = Uri.parse(
      '$_baseUrl/api/conversaciones/alumno',
    ).replace(queryParameters: {
      'token': widget.token,
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) return;

      final List<dynamic> jsonList = jsonDecode(response.body);

      final hayNoLeidosEnOtrosChats = jsonList.any((conv) {
        final id = int.tryParse(conv['id']?.toString() ?? '');

        if (id == widget.conversacionId) return false;

        final mensajes = conv['conversacion']?['mensajes'] ?? conv['mensajes'];

        if (mensajes is! List) return false;

        return mensajes.any((msg) {
          return msg['emisor'] == 'profesor' && msg['leido'] == false;
        });
      });

      if (!mounted) return;

      setState(() {
        _hasUnreadMessagesInOtherChats = hayNoLeidosEnOtrosChats;
      });
    } catch (e) {
      print('Error revisando otros chats: $e');
    } finally {
      _isCheckingOtherChats = false;
    }
  }

  Future<void> _cargarConversacion({bool silencioso = false}) async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    final uri = Uri.parse(
      '$_baseUrl/api/conversaciones/alumno/${widget.conversacionId}',
    ).replace(queryParameters: {
      'token': widget.token,
    });

    print('Cargando conversación alumno: $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final mensajesList = <_MessageResponse>[];

        if (json['conversacion'] != null &&
            json['conversacion']['mensajes'] != null) {
          for (var msgJson in json['conversacion']['mensajes']) {
            mensajesList.add(_MessageResponse.fromJson(msgJson));
          }
        }

        mensajesList.sort((a, b) {
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

        await _marcarMensajesProfesorComoLeidos();

        if (!mounted) return;

        setState(() {
          _mensajes = mensajesList;
          _isLoading = false;
          _error = null;
        });

        await _checkOtherChatsNotifications();

        print('Cargados ${_mensajes.length} mensajes');
      } else {
        if (!mounted) return;

        if (!silencioso) {
          setState(() {
            _error = 'Error al cargar la conversación';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');

      if (!mounted) return;

      if (!silencioso) {
        setState(() {
          _error = 'Error de conexión';
          _isLoading = false;
        });
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _enviarRespuesta() async {
    final contenido = _ctrl.text.trim();

    if (contenido.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final url =
        '$_baseUrl/api/conversaciones/${widget.conversacionId}/alumno-responder';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': widget.token,
          'contenido': contenido,
        }),
      );

      if (response.statusCode == 200) {
        _ctrl.clear();

        await _cargarConversacion(silencioso: true);

        print('Respuesta enviada');
      } else {
        throw Exception('Error al enviar');
      }
    } catch (e) {
      print('Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar mensaje'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToChatHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatHistoryStudent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _goToChatHistory,
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/quiethelp_logo.svg',
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'QuietHelp',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: _goToChatHistory,
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
                if (_hasUnreadMessagesInOtherChats)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final horizontalPadding = isDesktop ? 64.0 : 22.0;

          if (_isLoading && _mensajes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_error != null && _mensajes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarConversacion,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                14,
                horizontalPadding,
                18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tag,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildEstadoPill(),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          _MetaChip(
                            icon: Icons.access_time,
                            text: widget.dateText,
                          ),
                          _MetaChip(
                            icon: Icons.location_on_outlined,
                            text: widget.placeText,
                          ),
                          if (widget.courseText.isNotEmpty)
                            _MetaChip(
                              icon: Icons.school_outlined,
                              text: widget.courseText,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                          ),
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
                            ..._mensajes.map((msg) {
                              final esAlumno = msg.emisor == 'alumno';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Align(
                                  alignment: esAlumno
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: _Bubble(
                                    fromStudent: esAlumno,
                                    text: msg.mensaje,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            if (widget.estado == 'EN_REVISION') ...[
                              _InputBox(
                                controller: _ctrl,
                                onSend: _enviarRespuesta,
                                isLoading: _isLoading,
                              ),
                            ] else if (widget.estado == 'RESUELTO') ...[
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Esta conversación está resuelta',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ] else ...[
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Esperando respuesta del profesor...',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 42),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadoPill() {
    Color bgColor;
    Color textColor;
    String texto;

    switch (widget.estado) {
      case 'EN_REVISION':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF0C6F8A);
        texto = 'En revisión';
        break;
      case 'RESUELTO':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        texto = 'Resuelto';
        break;
      default:
        bgColor = const Color(0xFFFFF2DE);
        textColor = const Color(0xFFE09B2D);
        texto = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.estado == 'EN_REVISION'
                ? Icons.chat_bubble_outline
                : widget.estado == 'RESUELTO'
                    ? Icons.check_circle_outline
                    : Icons.access_time,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.black.withOpacity(0.35),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final bool fromStudent;
  final String text;

  const _Bubble({
    required this.fromStudent,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bg = fromStudent ? const Color(0xFF98CFEA) : const Color(0xFFDDEAF0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
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

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const _InputBox({
    required this.controller,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              enabled: !isLoading,
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