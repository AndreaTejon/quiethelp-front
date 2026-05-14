// chatPageStudent.dart
// Pantalla de detalle de conversación para el alumno
// Muestra historial real de mensajes y permite responder (solo si está EN_REVISION)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chatHistoryStudent.dart';

// Modelo para mensajes (simple)
class _MessageResponse {
  final String emisor;
  final String mensaje;
  final String fecha;
  final bool leido;

  _MessageResponse({
    required this.emisor,
    required this.mensaje,
    required this.fecha,
    required this.leido,
  });

  factory _MessageResponse.fromJson(Map<String, dynamic> json) {
    return _MessageResponse(
      emisor: json['emisor'] ?? 'alumno',
      mensaje: json['mensaje'] ?? '',
      fecha: json['fecha'] ?? '',
      leido: json['leido'] ?? false,
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
  final String estado;  // PENDIENTE, EN_REVISION, RESUELTO

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
  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);

  final TextEditingController _ctrl = TextEditingController();
  
  List<_MessageResponse> _mensajes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarConversacion();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // 📡 Cargar conversación desde SpringBoot
  Future<void> _cargarConversacion() async {
    final url = 'http://10.0.2.2:8080/api/conversaciones/alumno/${widget.conversacionId}?token=${widget.token}';
    
    print('📡 Cargando conversación alumno: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final mensajesList = <_MessageResponse>[];
        
        // Extraer mensajes de la respuesta
        if (json['conversacion'] != null && json['conversacion']['mensajes'] != null) {
          for (var msgJson in json['conversacion']['mensajes']) {
            mensajesList.add(_MessageResponse.fromJson(msgJson));
          }
        }
        
        setState(() {
          _mensajes = mensajesList;
          _isLoading = false;
        });
        
        print('✅ Cargados ${_mensajes.length} mensajes');
      } else {
        setState(() {
          _error = 'Error al cargar la conversación';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _error = 'Error de conexión';
        _isLoading = false;
      });
    }
  }

  // 📤 Enviar respuesta del alumno
  Future<void> _enviarRespuesta() async {
    final contenido = _ctrl.text.trim();
    if (contenido.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final url = 'http://10.0.2.2:8080/api/conversaciones/${widget.conversacionId}/alumno-responder';
    
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
        await _cargarConversacion();  // Recargar mensajes
        print('✅ Respuesta enviada');
      } else {
        throw Exception('Error al enviar');
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar mensaje')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatHistoryStudent()),
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
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/quiethelp_logo.png',
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
          IconButton(
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final horizontalPadding = isDesktop ? 64.0 : 22.0;

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
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
                      // Categoría
                      Text(
                        widget.tag,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Estado (pill)
                      _buildEstadoPill(),
                      const SizedBox(height: 8),
                      
                      // Metadatos
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          _MetaChip(icon: Icons.access_time, text: widget.dateText),
                          _MetaChip(icon: Icons.location_on_outlined, text: widget.placeText),
                          if (widget.courseText.isNotEmpty)
                            _MetaChip(icon: Icons.school_outlined, text: widget.courseText),
                        ],
                      ),
                      const SizedBox(height: 14),
                      
                      // Contenedor de mensajes + input
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
                            // Mensajes reales
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
                            
                            // Input solo si está EN_REVISION
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.estado == 'EN_REVISION' ? Icons.chat_bubble_outline :
            widget.estado == 'RESUELTO' ? Icons.check_circle_outline :
            Icons.access_time,
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

// ==================== WIDGETS AUXILIARES ====================

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black.withOpacity(0.35)),
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

  const _Bubble({required this.fromStudent, required this.text});

  @override
  Widget build(BuildContext context) {
    final bg = fromStudent ? const Color(0xFF98CFEA) : const Color(0xFFDDEAF0);

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
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              enabled: !isLoading,
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