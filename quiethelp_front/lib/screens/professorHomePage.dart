import 'dart:async'; // Polling: permite actualizar datos cada X segundos
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiethelp_front/screens/homePage.dart';
import '../constants/app_theme.dart';
import '../widgets/professor/stats_grid.dart';
import '../widgets/professor/category_filter.dart';
import '../widgets/professor/status_tabs.dart';
import '../widgets/professor/message_card.dart';
import '../widgets/footer.dart';
import '../widgets/menu_popup.dart';
import '../models/dashboard_resumen.dart';
import '../models/conversacion_response.dart';
import 'chatProfessorInitial.dart';
import 'aboutUs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class ProfessorHomePage extends StatefulWidget {
  final Map<String, dynamic> profesorData;

  const ProfessorHomePage({super.key, required this.profesorData});

  @override
  State<ProfessorHomePage> createState() => _ProfessorHomePageState();
}

class _ProfessorHomePageState extends State<ProfessorHomePage> {
  String _category = 'Todos';
  int _tabIndex = 0;
  bool _soloUrgentes = false;
  List<ConversacionResponse> _conversaciones = [];
  bool _hasUnreadInReview = false;
  DashboardResumen? _resumen;
  bool _isLoading = true;
  String? _error;

  // Polling: timer que refresca automáticamente las conversaciones
  Timer? _refreshTimer;

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    return 'http://10.0.2.2:8080';
  }

  @override
  void initState() {
    super.initState();

    print('Profesor logueado: ${widget.profesorData['nombre']}');
    print('ID: ${widget.profesorData['id']}');

    _cargarDatos();

    // Polling: refresca los datos automáticamente cada 5 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _refrescarDatosSilencioso();
      }
    });
  }

  @override
  void dispose() {
    // Polling: detiene el timer al salir de la pantalla
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _cargarConversaciones(),
        _cargarResumen(),
        _cargarNotificacionesRevision(),
      ]);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Error al cargar datos: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Polling: actualiza datos sin mostrar pantalla de carga
  Future<void> _refrescarDatosSilencioso() async {
    try {
      await Future.wait([
        _cargarConversaciones(),
        _cargarResumen(),
        _cargarNotificacionesRevision(),
      ]);
    } catch (e) {
      print('Error refrescando datos: $e');
    }
  }

  Future<void> _cargarNotificacionesRevision() async {
    final uri = Uri.parse('$_baseUrl/api/conversaciones/dashboard').replace(
      queryParameters: {
        'estado': 'EN_REVISION',
        'revisorId': widget.profesorData['id'],
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        final conversaciones = jsonList
            .map((json) => ConversacionResponse.fromJson(json))
            .toList();

        final haySinLeer = conversaciones.any((conv) {
          return conv.mensajes.any(
            (msg) => msg.emisor == 'alumno' && msg.leido == false,
          );
        });

        if (!mounted) return;

        setState(() {
          _hasUnreadInReview = haySinLeer;
        });
      }
    } catch (e) {
      print('Error cargando notificaciones revisión: $e');
    }
  }

  Future<void> _cargarConversaciones() async {
    final url = '$_baseUrl/api/conversaciones/dashboard';

    String? estado;
    if (_tabIndex == 0) estado = 'PENDIENTE';
    if (_tabIndex == 1) estado = 'EN_REVISION';
    if (_tabIndex == 2) estado = 'RESUELTO';

    String? tarjeta;
    if (_category != 'Todos') tarjeta = _category;

    final queryParams = <String, String>{};

    if (estado != null) queryParams['estado'] = estado;
    if (tarjeta != null) queryParams['tarjeta'] = tarjeta;

    queryParams['revisorId'] = widget.profesorData['id'];

    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    print('Cargando conversaciones: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      var nuevasConversaciones = jsonList
          .map((json) => ConversacionResponse.fromJson(json))
          .toList();

      if (_soloUrgentes) {
        nuevasConversaciones = nuevasConversaciones
            .where((conv) => conv.emisor.urgente == true)
            .toList();
      }

      // Orden: la conversación con el mensaje más reciente aparece arriba
      // Dentro de _cargarConversaciones(), después de obtener las conversaciones
      nuevasConversaciones.sort((a, b) {
        final fechaA = _fechaMasRecienteConversacion(a);
        final fechaB = _fechaMasRecienteConversacion(b);
        return fechaB.compareTo(fechaA); // mas reciente PRIMERO (arriba)
      });

      if (!mounted) return;

      setState(() {
        _conversaciones = nuevasConversaciones;
      });

      print('Cargadas ${_conversaciones.length} conversaciones');
    } else {
      print('Error ${response.statusCode}: ${response.body}');
      throw Exception('Error al cargar conversaciones');
    }
  }

  // Orden: busca la fecha más reciente entre todos los mensajes de una conversación
  DateTime _fechaMasRecienteConversacion(ConversacionResponse conversacion) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    DateTime fechaMasReciente = DateTime(2000);

    // Parsear fechaInicio
    if (conversacion.fechaInicio != null &&
        conversacion.fechaInicio!.isNotEmpty) {
      try {
        fechaMasReciente = formatter.parse(conversacion.fechaInicio!);
      } catch (e) {
        print('Error parseando fechaInicio: $e');
      }
    }

    // Buscar la fecha más reciente entre todos los mensajes
    for (final mensaje in conversacion.mensajes) {
      try {
        final fechaMensaje = formatter.parse(mensaje.fecha);
        if (fechaMensaje.isAfter(fechaMasReciente)) {
          fechaMasReciente = fechaMensaje;
        }
      } catch (e) {
        print('Error parseando fecha mensaje: $e');
      }
    }

    return fechaMasReciente;
  }

  Future<void> _cargarResumen() async {
    final url = '$_baseUrl/api/conversaciones/resumen';

    print('Cargando resumen: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final nuevoResumen = DashboardResumen.fromJson(json);

      if (!mounted) return;

      setState(() {
        _resumen = nuevoResumen;
      });

      print('Resumen cargado: Pendientes: ${_resumen?.pendientes}');
    } else {
      print('Error al cargar resumen: ${response.statusCode}');
      throw Exception('Error al cargar resumen');
    }
  }

  void _openNotifications() {}

  void _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión en Supabase: $e');
    }

    print('Sesión cerrada correctamente');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }

  void _goToAboutUs() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUs()));
  }

  String _estadoLabel(String? estado) {
    switch (estado) {
      case 'EN_REVISION':
        return 'En revisión';
      case 'RESUELTO':
        return 'Resuelto';
      default:
        return 'Pendiente';
    }
  }

  bool _tieneAlumnoSinLeer(ConversacionResponse conv) {
    return conv.estado == 'EN_REVISION' &&
        conv.mensajes.any(
          (msg) => msg.emisor == 'alumno' && msg.leido == false,
        );
  }

  Future<void> _navigateToChat(ConversacionResponse conversacion) async {
    final primerMensaje = conversacion.primerMensaje;

    String cursoGrupo = '';
    if (conversacion.emisor.curso != null &&
        conversacion.emisor.grupo != null) {
      cursoGrupo = '${conversacion.emisor.curso} ${conversacion.emisor.grupo}';
    } else if (conversacion.emisor.curso != null) {
      cursoGrupo = conversacion.emisor.curso!;
    } else if (conversacion.emisor.grupo != null) {
      cursoGrupo = 'Grupo: ${conversacion.emisor.grupo}';
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatProfessorInitialPage(
          conversacionId: conversacion.id,
          category: conversacion.emisor.tarjeta,
          status: conversacion.estado ?? 'Pendiente',
          dateText: conversacion.fechaInicio ?? '',
          schoolText: 'IES Ramiro de Maeztu (28001)',
          groupText: cursoGrupo,
          message: primerMensaje?.mensaje ?? '',
          urgente: conversacion.emisor.urgente,
          revisorId: widget.profesorData['id'],
          revisorNombre: widget.profesorData['nombre'],
        ),
      ),
    );

    await _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, c) {
          final pad = c.maxWidth >= 900 ? 64.0 : 22.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _buildBody(),
              ),
            ),
          );
        },
      ),
    );
  }

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
            SizedBox(height: 100),
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 20),
            Text(_error!, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _cargarDatos, child: Text('Reintentar')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsGrid(
          pendientes: _resumen?.pendientes ?? 0,
          enRevision: _resumen?.enRevision ?? 0,
          resueltos: _resumen?.resueltos ?? 0,
          urgentes: _resumen?.urgentes ?? 0,
          onTap: (i) {
  setState(() {
    if (i == 3) {
      _soloUrgentes = true;
    } else {
      _tabIndex = i;
      _soloUrgentes = false;
    }
  });

  _cargarConversaciones();
},
        ),
        const SizedBox(height: 28),
        CategoryFilter(
          value: _category,
          onChanged: (v) {
            setState(() => _category = v);
            _cargarConversaciones();
          },
        ),
        const SizedBox(height: 20),
        StatusTabs(
          index: _tabIndex,
          hasUnreadInReview: _hasUnreadInReview,
          onChanged: (i) {
  setState(() {
    _tabIndex = i;
  });

  _cargarConversaciones();
},
        ),
        const SizedBox(height: 32),
        ..._buildMessageList(),
        const SizedBox(height: 48),
        AppFooter(onAbout: _goToAboutUs),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: MenuPopup(onLogout: _logout, onAbout: _goToAboutUs),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/images/quiethelp_logo.svg', height: 28),
          const SizedBox(width: 8),
          const Text('QuietHelp', style: AppTextStyles.titleSmall),
        ],
      ),
      actions: [
        SizedBox(
          width: 56,
          child: IconButton(
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMessageList() {
    if (_conversaciones.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No hay conversaciones en esta categoría'),
          ),
        ),
      ];
    }

    return _conversaciones.map((conv) {
      final primerMensaje = conv.primerMensaje;
      if (primerMensaje == null) return const SizedBox();

      final unread = _tieneAlumnoSinLeer(conv);

      return Column(
        children: [
          MessageCard(
            category: conv.emisor.tarjeta,
            urgent: conv.emisor.urgente,
            body: primerMensaje.mensaje,
            received: 'Recibido: ${conv.fechaInicio ?? ''}',
            statusLabel: _estadoLabel(conv.estado),
            unread: unread,
            cadenaVerificada: conv.cadenaVerificada,
            onReview: () => _navigateToChat(conv),
          ),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }
}
