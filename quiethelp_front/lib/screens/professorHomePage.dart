import 'package:flutter/material.dart';
import '../constants/app_theme.dart';  // 👈 IMPORTANTE: con ../ para subir de screens/ a lib/
import '../widgets/professor/stats_grid.dart';  // 👈 Con ../
import '../widgets/professor/category_filter.dart';
import '../widgets/professor/status_tabs.dart';
import '../widgets/professor/message_card.dart';
import '../widgets/footer.dart';
import '../widgets/menu_popup.dart';
import '../models/dashboard_resumen.dart';
import '../models/conversacion_response.dart';
import 'chatProfessorInitial.dart';
import 'signIn.dart';
import 'aboutUs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ProfessorHomePage extends StatefulWidget {
  final Map<String, dynamic> profesorData; //Datos
  
  const ProfessorHomePage({super.key, required this.profesorData});

  @override
  State<ProfessorHomePage> createState() => _ProfessorHomePageState();
}

class _ProfessorHomePageState extends State<ProfessorHomePage> {
  String _category = 'Todos';
  int _tabIndex = 0;
  List<ConversacionResponse> _conversaciones = [];
  DashboardResumen? _resumen;
  bool _isLoading = true;
  String? _error;


    @override
  void initState() {
    super.initState();
    // Mostrar quién ha iniciado sesión (para debug)
    print('Profesor logueado: ${widget.profesorData['nombre']}');
    print('ID: ${widget.profesorData['id']}');
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try{ //Carga conversaciones y resumen en paralelo
      await Future.wait([
        _cargarConversaciones(),
        _cargarResumen(),
      ]);
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarConversaciones() async {
    final url = 'http://10.0.2.2:8080/api/conversaciones/dashboard';
    String? estado; //Para mapear el tab
    if (_tabIndex == 0) estado = 'PENDIENTE';
    if (_tabIndex == 1) estado = 'EN_REVISION';
    if (_tabIndex == 2) estado = 'RESUELTO';

    String? tarjeta; //Mapear la categoria si no es todos
    if (_category != 'Todos') tarjeta = _category;

    var uri = Uri.parse(url).replace(queryParameters: {
      if (estado != null) 'estado': estado,
      if (tarjeta != null) 'tarjeta': tarjeta,
    });

    print('Cargando conversaciones: $uri');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _conversaciones = jsonList.map((json) => ConversacionResponse.fromJson(json)).toList();
        });
        print('✅ Cargadas ${_conversaciones.length} conversaciones');
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al cargar conversaciones');
      }
    } catch (e) {
      print('Excepción: $e');
      throw Exception('Error de conexión: $e');      
    }
  }

  Future<void> _cargarResumen() async {
  final url = 'http://10.0.2.2:8080/api/conversaciones/resumen';
  
  print('📡 Cargando resumen: $url');
  
  try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        _resumen = DashboardResumen.fromJson(json);
      });
      print('Resumen cargado: Pendientes: ${_resumen?.pendientes}');
    } else {
      print('Error al cargar resumen: ${response.statusCode}');
    }
  } catch (e) {
    print('Excepción en resumen: $e');
  }
}

  

  void _openNotifications() {
    // Aquí puedes navegar a notificaciones
  }

  void _logout() async {
    // 1. Cerrar sesión en Supabase
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión en Supabase: $e');
    }
    
    // 2. Mensaje de confirmación
    print('Sesión cerrada correctamente');
    
    // 3. Volver a la pantalla de login
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false,  // Elimina todas las rutas anteriores
      );
    }
    
  }

  void _goToAboutUs() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUs()));
  }

  /*void _navigateToChat(String category, String date, String message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatProfessorInitialPage(
          category: category,
          status: 'Pendiente',
          dateText: date,
          schoolText: 'IES Ramiro de Maeztu (28001)',
          groupText: '2º ESO B',
          message: message,
        ),
      ),
    );
  }*/
 void _navigateToChat(ConversacionResponse conversacion) {
  final primerMensaje = conversacion.primerMensaje;
  
  // Combinar curso y grupo si existen
  String cursoGrupo = '';
  if (conversacion.emisor.curso != null && conversacion.emisor.grupo != null) {
    cursoGrupo = '${conversacion.emisor.curso} ${conversacion.emisor.grupo}';
  } else if (conversacion.emisor.curso != null) {
    cursoGrupo = conversacion.emisor.curso!;
  } else if (conversacion.emisor.grupo != null) {
    cursoGrupo = 'Grupo: ${conversacion.emisor.grupo}';
  }
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatProfessorInitialPage(
        conversacionId: conversacion.id,
        category: conversacion.emisor.tarjeta,
        status: conversacion.estado ?? 'Pendiente',
        dateText: conversacion.fechaInicio ?? '',
        schoolText: 'IES Ramiro de Maeztu (28001)',  // Por ahora fijo
        groupText: cursoGrupo,
        message: primerMensaje?.mensaje ?? '',
        urgente: conversacion.emisor.urgente,        // ← Boolean
        revisorId: widget.profesorData['id'],        // ← Del profesor logueado
        revisorNombre: widget.profesorData['nombre'], // ← Revisor_nombre
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: _buildAppBar(),
      body: LayoutBuilder(builder: (context, c) {
        final pad = c.maxWidth >= 900 ? 64.0 : 22.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildBody(),  // 👈 Nuevo método
            ),
          ),
        );
      }),
    );
  }

Widget _buildBody() { // Método que maneja los estados de carga
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
            onPressed: _cargarDatos,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // StatsGrid con datos REALES
      StatsGrid(
        pendientes: _resumen?.pendientes ?? 0,
        enRevision: _resumen?.enRevision ?? 0,
        resueltos: _resumen?.resueltos ?? 0,
        urgentes: _resumen?.urgentes ?? 0,
        onTap: (i) {
          setState(() => _tabIndex = i);
          _cargarConversaciones();  // Recargar con nuevo estado
        },
      ),
      const SizedBox(height: 28),
      
      // CategoryFilter (sin cambios)
      CategoryFilter(
        value: _category,
        onChanged: (v) {
          setState(() => _category = v);
          _cargarConversaciones();  // Recargar con nueva categoría
        },
      ),
      const SizedBox(height: 20),
      
      // StatusTabs (sin cambios)
      StatusTabs(
        index: _tabIndex,
        onChanged: (i) {
          setState(() => _tabIndex = i);
          _cargarConversaciones();  // Recargar con nuevo estado
        },
      ),
      const SizedBox(height: 32),
      
      // Mensajes REALES
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
        padding: EdgeInsets.only(left: 8),
        child: MenuPopup(
          onLogout: _logout, 
          onAbout: _goToAboutUs,
        ), // Tu widget existente
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/quiethelp_logo.png', height: 28),
          const SizedBox(width: 8),
          const Text(
            'QuietHelp',
            style: AppTextStyles.titleSmall,
          ),
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

 /* List<Widget> _buildMessageList() {
    final messages = [
      {
        'category': 'Bullying',
        'urgent': true,
        'date': '19 de enero de 2026, 9:00',
        'message':
            'Hay un grupo de estudiantes que me molesta todos los días en el recreo. Me quitan mi almuerzo y me dicen cosas feas. No sé qué hacer y tengo miedo de ir a la escuela.',
      },
      {
        'category': 'Emocional',
        'urgent': false,
        'date': '16 de enero de 2026, 11:00',
        'message':
            'Últimamente me siento muy triste y no tengo ganas de hacer nada. Mis papás trabajan mucho y no puedo hablar con ellos.',
      },
      {
        'category': 'Académico',
        'urgent': false,
        'date': '19 de enero de 2026, 9:00',
        'message':
            'Me está yendo muy mal en matemáticas y lengua. No entiendo varios temas y me atraso mucho, pero me da miedo preguntar porque se han reído de mí.',
      },
    ];

    return messages.map((m) {
      return Column(
        children: [
          MessageCard(
            category: m['category'] as String,
            urgent: m['urgent'] as bool,
            body: m['message'] as String,
            received: 'Recibido: ${m['date']}',
            onReview: () => _navigateToChat(
              m['category'] as String,
              m['date'] as String,
              m['message'] as String,
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }*/
  List<Widget> _buildMessageList() {
  if (_conversaciones.isEmpty) {
    return [
      const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No hay conversaciones en esta categoría'),
        ),
      )
    ];
  }

  return _conversaciones.map((conv) {
    final primerMensaje = conv.primerMensaje;
    if (primerMensaje == null) return const SizedBox();
    
    return Column(
      children: [
        MessageCard(
          category: conv.emisor.tarjeta,
          urgent: conv.emisor.urgente,
          body: primerMensaje.mensaje,
          received: 'Recibido: ${conv.fechaInicio ?? ''}',
          onReview: () => _navigateToChat(conv),
        ),
        const SizedBox(height: 12),
      ],
    );
  }).toList();
}
}