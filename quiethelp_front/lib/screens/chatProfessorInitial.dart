// chatProfessorInitial.dart
// Pantalla de detalle de conversación para el profesor
// Muestra el historial completo de mensajes y permite responder
// Incluye lógica de asignación y cambio de estados

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/conversacion_response.dart';  // Modelo para recibir conversaciones
import '../models/message_response.dart';       // Modelo para recibir mensajes

class ChatProfessorInitialPage extends StatefulWidget {
  final int conversacionId;           // ID de la conversación (para llamadas API)
  final String category;               // Categoría: Bullying, Académico, Emocional
  final String status;                 // "Pendiente" | "En revisión" | "Resuelto"
  final String dateText;               // "15 ene 2024, 10:30"
  final String schoolText;             // "IES Ramiro de Maeztu (28001)"
  final String groupText;               // "2º ESO B" (combinación de curso + grupo)
  final String message;                 // Primer mensaje (para la tarjeta)
  final bool urgente;                   // Si la conversación es urgente
  final String revisorId;               // ID del profesor logueado (desde Supabase)
  final String revisorNombre;           // Nombre del profesor logueado

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
  State<ChatProfessorInitialPage> createState() => _ChatProfessorInitialPageState();
}

class _ChatProfessorInitialPageState extends State<ChatProfessorInitialPage> {
  // 📦 VARIABLES DE ESTADO
  List<MessageResponse> _mensajes = [];           // Lista de mensajes reales
  bool _isLoading = true;                          // Control de carga
  String? _error;                                   // Mensaje de error
  final TextEditingController _respuestaController = TextEditingController(); // Control del input
  late String _status;                              // Estado actual de la conversación
  
  // 🎨 CONSTANTES DE COLOR
  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);
  static const selectedBlue = Color(0xFF0C6F8A);
  static const urgentRed = Color(0xFFD32F2F);       // Color para urgente

  // 🚀 INICIALIZACIÓN
  @override
  void initState() {
    super.initState();
    _status = widget.status;                         // Estado inicial desde widget
    _cargarConversacionCompleta();                    // Cargar mensajes reales
    print('🔵 Chat iniciado - ID: ${widget.conversacionId}');
  }

  @override
  void dispose() {
    _respuestaController.dispose();                   // Limpiar controlador
    super.dispose();
  }

  // 📡 CARGAR CONVERSACIÓN COMPLETA DESDE SPRINGBOOT
  // GET /api/conversaciones/{id}
  Future<void> _cargarConversacionCompleta() async {
    final url = 'http://10.0.2.2:8080/api/conversaciones/${widget.conversacionId}';
    print('📡 Cargando conversación: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final conversacion = ConversacionResponse.fromJson(json);
        
        setState(() {
          _mensajes = conversacion.mensajes;
          _isLoading = false;
        });
        
        // Actualizar el estado si viene del backend
        if (conversacion.estado != null) {
          setState(() {
            _status = _mapEstado(conversacion.estado!);
          });
        }
        
        print('✅ Conversación cargada: ${_mensajes.length} mensajes');
      } else {
        setState(() {
          _error = 'Error al cargar la conversación (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      setState(() {
        _error = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  // 🔄 CONVERTIR ESTADO DEL BACKEND AL FORMATO DE LA UI
  String _mapEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE': return 'Pendiente';
      case 'EN_REVISION': return 'En revisión';
      case 'RESUELTO': return 'Resuelto';
      default: return 'Pendiente';
    }
  }

  // 📤 ASIGNAR CONVERSACIÓN AL PROFESOR (PATCH)
  // Solo se llama cuando está PENDIENTE y se quiere pasar a EN_REVISION
  Future<void> _asignarYRevisar() async {
    // Mostrar carga
    setState(() {
      _isLoading = true;
    });

    final url = 'http://10.0.2.2:8080/api/conversaciones/${widget.conversacionId}/asignar';
    final fullUrl = '$url?revisorId=${widget.revisorId}&revisorNombre=${Uri.encodeComponent(widget.revisorNombre)}';
    
    try {
      print('📤 Asignando conversación a: ${widget.revisorNombre}');
      
      final response = await http.patch(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📥 Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // ✅ Éxito: actualizar estado local
        setState(() {
          _status = 'En revisión';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Conversación asignada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recargar conversación para obtener datos actualizados
        await _cargarConversacionCompleta();
        
      } else {
        throw Exception('Error al asignar: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al asignar: $e'),
          backgroundColor: Colors.red,
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

  // 📤 CAMBIAR ESTADO (solo para EN_REVISION → RESUELTO)
  Future<void> _marcarResuelto() async {
    // Mostrar carga
    setState(() {
      _isLoading = true;
    });

    final url = 'http://10.0.2.2:8080/api/conversaciones/${widget.conversacionId}/estado?nuevoEstado=RESUELTO';
    
    try {
      print('📤 Marcando como resuelto');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📥 Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // ✅ Éxito: actualizar estado local
        setState(() {
          _status = 'Resuelto';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Conversación marcada como resuelta'),
            backgroundColor: Colors.green,
          ),
        );
        
      } else {
        throw Exception('Error al marcar resuelto: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al marcar resuelto: $e'),
          backgroundColor: Colors.red,
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

  // 📤 ENVIAR RESPUESTA DEL PROFESOR
  // POST /api/conversaciones/{id}/responder
  Future<void> _enviarRespuesta() async {
    final contenido = _respuestaController.text.trim();
    
    // Validar que no esté vacío
    if (contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un mensaje'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar que la conversación esté en revisión (solo se puede responder si está asignada)
    if (!_isReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes responder conversaciones en revisión'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar indicador de carga
    setState(() {
      _isLoading = true;
    });

    final url = 'http://10.0.2.2:8080/api/conversaciones/${widget.conversacionId}/responder';
    
    try {
      print('📤 Enviando respuesta...');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contenido': contenido,
          'revisorId': widget.revisorId,
          'revisorNombre': widget.revisorNombre,
        }),
      );
      
      print('📥 Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // ✅ Éxito: limpiar campo y recargar mensajes
        _respuestaController.clear();
        await _cargarConversacionCompleta();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Respuesta enviada'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al enviar: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar: $e'),
          backgroundColor: Colors.red,
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

  // 🎨 WIDGET: AppBar personalizada
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
          Image.asset('assets/images/quiethelp_logo.png', height: 28),
          const SizedBox(width: 8),
          const Text(
            'QuietHelp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {}, 
          icon: const Icon(Icons.notifications_none_outlined)
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  // 💬 WIDGET: Lista de mensajes (historial completo)
  Widget _buildMensajesList() {
    if (_mensajes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No hay mensajes en esta conversación'),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _mensajes.length,
      itemBuilder: (context, index) {
        final msg = _mensajes[index];
        final esProfesor = msg.emisor == 'profesor';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esProfesor ? '👨‍🏫 Profesor' : '👤 Alumno',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: esProfesor ? teal : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(msg.mensaje),
                const SizedBox(height: 4),
                Text(
                  msg.fecha,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📝 WIDGET: Área de respuesta (input + botón)
  Widget _buildRespuestaArea() {
    // Si está resuelto, no se puede responder
    if (_isSolved) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '✅ Conversación resuelta',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Si está pendiente, no se puede responder (hay que asignar primero)
    if (_isPending) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '📌 Asigna la conversación para poder responder',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ),
      );
    }

    // Solo se muestra si está en revisión
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚨 Etiqueta de URGENTE (si aplica)
            if (widget.urgente) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: urgentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: urgentRed.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: urgentRed),
                    const SizedBox(width: 6),
                    Text(
                      'URGENTE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: urgentRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Campo de texto para la respuesta
            const Text(
              'Escribe tu respuesta:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _respuestaController,
              decoration: InputDecoration(
                hintText: 'Mensaje del profesor...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 4,
              minLines: 2,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            
            // Botón de enviar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enviarRespuesta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar mensaje',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔄 GETTERS PARA ESTADOS
  bool get _isPending => _status == 'Pendiente';
  bool get _isReview => _status == 'En revisión';
  bool get _isSolved => _status == 'Resuelto';

  // 🏗️ CONSTRUCCIÓN DE LA PANTALLA
  @override
  Widget build(BuildContext context) {
    // 📍 Manejo de estados de carga y error
    if (_isLoading && _mensajes.isEmpty) {
      return Scaffold(
        backgroundColor: bgSoft,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
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

    // 📱 Pantalla principal
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: _buildAppBar(),
      body: LayoutBuilder(builder: (context, constraints) {
        final pad = constraints.maxWidth >= 900 ? 64.0 : 22.0;
        
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🃏 Tarjeta de detalle con lógica de estados
                  _DetailCard(
                    category: widget.category,
                    status: _status,
                    dateText: widget.dateText,
                    schoolText: widget.schoolText,
                    groupText: widget.groupText,
                    message: widget.message,
                    isPending: _isPending,
                    isReview: _isReview,
                    isSolved: _isSolved,
                    onStatusTap: (nuevoEstado) async {
                      // REGLAS DE NEGOCIO:
                      // - Pendiente → En revisión: ASIGNAR
                      // - En revisión → Resuelto: RESOLVER
                      // - Cualquier otra combinación: NO PERMITIDA
                      
                      if (_isPending && nuevoEstado == 'En revisión') {
                        await _asignarYRevisar();
                      }
                      else if (_isReview && nuevoEstado == 'Resuelto') {
                        await _marcarResuelto();
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No se puede cambiar de $_status a $nuevoEstado'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 💬 Historial de mensajes
                  _buildMensajesList(),
                  
                  const SizedBox(height: 24),
                  
                  // 📝 Área de respuesta
                  _buildRespuestaArea(),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ==================== WIDGETS PRIVADOS ====================

// 🃏 Tarjeta de detalle del alumno
class _DetailCard extends StatelessWidget {
  final String category;
  final String status;
  final String dateText;
  final String schoolText;
  final String groupText;
  final String message;
  final bool isPending;
  final bool isReview;
  final bool isSolved;
  final ValueChanged<String> onStatusTap;

  const _DetailCard({
    required this.category,
    required this.status,
    required this.dateText,
    required this.schoolText,
    required this.groupText,
    required this.message,
    required this.isPending,
    required this.isReview,
    required this.isSolved,
    required this.onStatusTap,
  });

  static const teal = Color(0xFF2CB9B2);
  static const selectedBlue = Color(0xFF0C6F8A);

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
          // 🏷️ Categoría y estado
          Row(
            children: [
              const Icon(Icons.menu_book_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 10),
          
          // 📅 Información contextual
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.black.withOpacity(0.45)),
                  const SizedBox(width: 6),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.black.withOpacity(0.45)),
                  const SizedBox(width: 6),
                  Text(
                    schoolText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              if (groupText.isNotEmpty) // Solo mostrar si hay curso/grupo
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group_outlined, size: 14, color: Colors.black.withOpacity(0.45)),
                    const SizedBox(width: 6),
                    Text(
                      groupText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.08), height: 1),

          // 💬 Mensaje del alumno
          const SizedBox(height: 14),
          const Text(
            'Mensaje del alumno',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.65),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Divider(color: Colors.black.withOpacity(0.08), height: 1),

          // 🔘 Botones de estado
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
              } else {
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
              }
            },
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// 🏷️ Píldora de estado (colores según estado)
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
            isPending ? Icons.access_time : 
            isReview ? Icons.chat_bubble_outline : 
            isSolved ? Icons.check_circle_outline : 
            Icons.folder_outlined,
            size: 14, 
            color: pillText
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: pillText),
          ),
        ],
      ),
    );
  }
}

// 🔘 Botón de estado individual
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
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: fg),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}