// chatHistoryStudent.dart
// Muestra el historial de conversaciones del alumno (solo PENDIENTES y EN_REVISION)
// Las conversaciones resueltas NO aparecen

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chatPageStudent.dart';
import '../models/conversacion_response.dart';
import '../services/token_storage.dart';

class ChatHistoryStudent extends StatefulWidget {
  const ChatHistoryStudent({super.key});

  @override
  State<ChatHistoryStudent> createState() => _ChatHistoryStudentState();
}

class _ChatHistoryStudentState extends State<ChatHistoryStudent> {
  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);
  
  List<ConversacionResponse> _conversaciones = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  @override
  void initState() {
    super.initState();
    _cargarTokenYConversaciones();
  }

  // 📡 Cargar token y luego conversaciones
  Future<void> _cargarTokenYConversaciones() async {
    final token = await TokenStorage.getToken();
    
    if (token == null) {
      setState(() {
        _error = 'No hay sesión activa';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _token = token;
    });

    await _cargarConversaciones(token);
  }

  // 📡 OBTENER CONVERSACIONES DEL ALUMNO DESDE SPRINGBOOT
  // GET /api/conversaciones/alumno?token=TOKEN
  Future<void> _cargarConversaciones(String token) async {
    final url = 'http://10.0.2.2:8080/api/conversaciones/alumno?token=$token';
    
    print('📡 Cargando historial del alumno: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        
        // Filtrar SOLO PENDIENTES y EN REVISION (las resueltas no se muestran)
        final conversaciones = jsonList
            .map((json) => ConversacionResponse.fromJson(json))
            .where((conv) => conv.estado != 'RESUELTO')
            .toList();
        
        setState(() {
          _conversaciones = conversaciones;
          _isLoading = false;
        });
        
        print('✅ Cargadas ${_conversaciones.length} conversaciones activas');
      } else {
        setState(() {
          _error = 'Error al cargar historial';
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

  // 🔄 Combinar curso y grupo
  String _combinarCursoGrupo(String? curso, String? grupo) {
    if (curso != null && grupo != null) {
      return '$curso $grupo';
    } else if (curso != null) {
      return curso;
    } else if (grupo != null) {
      return 'Grupo: $grupo';
    } else {
      return '';
    }
  }

  // 🎨 CONSTRUIR PANTALLA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final horizontalPadding = isDesktop ? 64.0 : 16.0;

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
                  child: _buildBody(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🎨 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chats con respuesta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Un profesor pide más información para ayudarte',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Cuerpo principal con manejo de estados
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          children: [
            SizedBox(height: 100),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Cargando conversaciones...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 20),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _cargarTokenYConversaciones();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_conversaciones.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No hay conversaciones activas',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            height: 1,
            color: Colors.black.withOpacity(0.08),
          ),
          _buildInfoText(),
        ],
      );
    }

    return Column(
      children: [
        // Lista de conversaciones reales
        ..._conversaciones.map((conv) {
          final primerMensaje = conv.primerMensaje;
          if (primerMensaje == null) return const SizedBox();
          
          String titulo = conv.emisor.tarjeta;
          String estadoTexto = conv.estado ?? 'PENDIENTE';
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChatHistoryCard(
              titulo: titulo,
              tag: conv.emisor.tarjeta,
              preview: primerMensaje.mensaje,
              dateText: conv.fechaInicio ?? '',
              placeText: 'IES Ramiro de Maeztu (28001)',
              courseText: _combinarCursoGrupo(conv.emisor.curso, conv.emisor.grupo),
              estado: estadoTexto,
              tieneRespuestas: conv.mensajes.length > 1,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPageStudent(
                      conversacionId: conv.id,
                      token: _token!,
                      title: titulo,
                      tag: conv.emisor.tarjeta,
                      dateText: conv.fechaInicio ?? '',
                      placeText: 'IES Ramiro de Maeztu (28001)',
                      courseText: _combinarCursoGrupo(conv.emisor.curso, conv.emisor.grupo),
                      estado: estadoTexto,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
        
        const SizedBox(height: 20),
        
        // Línea separadora
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          height: 1,
          color: Colors.black.withOpacity(0.08),
        ),
        
        // Texto informativo
        _buildInfoText(),
        
        const SizedBox(height: 18),
      ],
    );
  }

  // ℹ️ Texto informativo
  Widget _buildInfoText() {
    return Text(
      'Tus conversaciones sólo aparecen aquí cuando un profesor te responde pidiendo más información.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: Colors.black.withOpacity(0.4),
      ),
    );
  }
}

// 🃏 Tarjeta de conversación
class _ChatHistoryCard extends StatelessWidget {
  final String titulo;
  final String tag;
  final String preview;
  final String dateText;
  final String placeText;
  final String courseText;
  final String estado;
  final bool tieneRespuestas;
  final VoidCallback onTap;

  const _ChatHistoryCard({
    required this.titulo,
    required this.tag,
    required this.preview,
    required this.dateText,
    required this.placeText,
    required this.courseText,
    required this.estado,
    required this.tieneRespuestas,
    required this.onTap,
  });

  Color _getTagColor(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return const Color(0xFFE09B2D);
      case 'EN_REVISION':
        return const Color(0xFF0C6F8A);
      case 'RESUELTO':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Icons.access_time;
      case 'EN_REVISION':
        return Icons.chat_bubble_outline;
      case 'RESUELTO':
        return Icons.check_circle_outline;
      default:
        return Icons.folder_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: tieneRespuestas 
                ? const Color(0xFF2CB9B2).withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (tieneRespuestas) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2CB9B2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getTagColor(estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _getTagColor(estado).withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getEstadoIcon(estado),
                        size: 12,
                        color: _getTagColor(estado),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        estado == 'EN_REVISION' ? 'En revisión' : 
                        estado == 'RESUELTO' ? 'Resuelto' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _getTagColor(estado),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                
                if (isWide) {
                  return Row(
                    children: [
                      _buildMetaItem(icon: Icons.access_time, text: dateText),
                      const SizedBox(width: 16),
                      _buildMetaItem(icon: Icons.location_on_outlined, text: placeText),
                      if (courseText.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        _buildMetaItem(icon: Icons.school_outlined, text: courseText),
                      ],
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetaItem(icon: Icons.access_time, text: dateText),
                      const SizedBox(height: 8),
                      _buildMetaItem(icon: Icons.location_on_outlined, text: placeText),
                      if (courseText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildMetaItem(icon: Icons.school_outlined, text: courseText),
                      ],
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black.withOpacity(0.35)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.45),
            ),
          ),
        ),
      ],
    );
  }
}