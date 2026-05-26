import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:quiethelp_front/screens/homePage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../constants/app_theme.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/topic_tile.dart';
import '../widgets/security_badge.dart';
import '../widgets/footer.dart';
import '../widgets/menu_popup.dart';
import '../constants/app_data.dart';

import 'messageSent.dart';
import 'chatHistoryStudent.dart';
import 'signIn.dart';
import 'aboutUs.dart';

import '../services/token_storage.dart';
import '../services/token_service.dart';
import '../models/conversacion_response.dart';

class StudentHomePage extends StatefulWidget {
  final String? token;

  const StudentHomePage({super.key, this.token});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final msgCtrl = TextEditingController();
  final groupCtrl = TextEditingController();

  String? curso;
  String? topic;

  bool _sending = false;
  bool _tokenValidado = false;
  bool _hasUnreadProfessorMessages = false;

  Timer? _notificationTimer;

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    return 'http://10.0.2.2:8080';
  }

  @override
  void initState() {
    super.initState();

    msgCtrl.addListener(_onMessageChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validarTokenAlIniciar();
      _cargarNotificaciones();

      _notificationTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _cargarNotificaciones(),
      );
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();

    msgCtrl.removeListener(_onMessageChanged);
    msgCtrl.dispose();
    groupCtrl.dispose();
    super.dispose();
  }

  void _onMessageChanged() {
    setState(() {});
  }

  bool get _isValid => topic != null && msgCtrl.text.trim().isNotEmpty;

  Future<void> _cargarNotificaciones() async {
    final token = widget.token ?? await TokenStorage.getToken();
    if (token == null) return;

    final uri = Uri.parse(
      '$_baseUrl/api/conversaciones/alumno',
    ).replace(queryParameters: {'token': token});

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        final conversaciones = jsonList
            .map((json) => ConversacionResponse.fromJson(json))
            .toList();

        final hayNoLeidos = conversaciones.any((conv) {
          return conv.mensajes.any(
            (msg) => msg.emisor == 'profesor' && msg.leido == false,
          );
        });

        if (!mounted) return;

        setState(() {
          _hasUnreadProfessorMessages = hayNoLeidos;
        });
      }
    } catch (e) {
      print('Error cargando notificaciones: $e');
    }
  }

  void _validarTokenAlIniciar() async {
    if (_tokenValidado || widget.token == null) return;

    _tokenValidado = true;

    await Future.delayed(const Duration(milliseconds: 500));

    final tokenService = TokenService();
    final esValido = await tokenService.validateToken(widget.token!);

    if (!esValido && mounted) {
      _showSnackBar('Token inválido o expirado');

      await TokenStorage.clearToken();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (_) => false,
      );
    }
  }

  String _mapTarjeta(String t) {
    switch (t) {
      case 'bullying':
        return 'Bullying';
      case 'academica':
        return 'Académico';
      case 'emociones':
        return 'Emocional';
      default:
        return 'Otro';
    }
  }

  String _getCurrentDate() {
    return DateTime.now().toIso8601String();
  }

  Future<void> _send() async {
    if (widget.token == null) {
      _showSnackBar('Sesión no válida');
      _logout();
      return;
    }

    if (topic == null) {
      _showSnackBar('Elige una tarjeta');
      return;
    }

    final msg = msgCtrl.text.trim();

    if (msg.isEmpty) {
      _showSnackBar('Escribe tu mensaje antes de enviar');
      return;
    }

    if (_sending) return;

    setState(() => _sending = true);

    final url = Uri.parse('$_baseUrl/api/conversaciones');

    final Map<String, dynamic> body = {
      "token": widget.token,
      "emisor": {
        "tarjeta": _mapTarjeta(topic!),
        if (curso != null) "curso": curso,
        if (groupCtrl.text.trim().isNotEmpty) "grupo": groupCtrl.text.trim(),
      },
      "conversacion": {
        "mensajes": [
          {"emisor": "alumno", "mensaje": msg, "fecha": _getCurrentDate()},
        ],
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        if (mounted) {
          msgCtrl.clear();
          groupCtrl.clear();

          setState(() {
            curso = null;
            topic = null;
            _sending = false;
          });
        }

        if (mounted) {
          final decoded = jsonDecode(response.body);
          final urgente =
              decoded["conversacion"]?["urgente"] == true ||
              decoded["emisor"]?["urgente"] == true;

          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => MessageSent(urgente: urgente)),
          );
        }

        return;
      } else if (response.statusCode == 401) {
        if (!mounted) return;

        setState(() => _sending = false);

        _showSnackBar('Token inválido o expirado');
        _logout();
      } else {
        if (!mounted) return;

        String errorMsg = 'Error al enviar el mensaje';

        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map && decoded["mensaje"] != null) {
            errorMsg = decoded["mensaje"].toString();
          }
        } catch (_) {}

        setState(() => _sending = false);

        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      print('Excepción: $e');

      if (!mounted) return;

      setState(() => _sending = false);

      _showErrorDialog(
        'No se pudo conectar con el servidor. ¿Quieres intentarlo de nuevo?',
      );
    }
  }

  void _showErrorDialog(String message) {
  if (!mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 28),
            padding: const EdgeInsets.fromLTRB(24, 46, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.errorRed,
                  size: 28,
                ),
                const SizedBox(height: 18),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Volver'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _send();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _logout() async {
    await TokenStorage.clearToken();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  }

  void _notifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatHistoryStudent()),
    );

    _cargarNotificaciones();
  }

  void _about() => _push(const AboutUs());

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: MenuPopup(onLogout: _logout, onAbout: _about),
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
        actions: [
          SizedBox(
            width: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: _notifications,
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
                if (_hasUnreadProfessorMessages)
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
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pad = constraints.maxWidth >= 900 ? 64.0 : 22.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildMessageCard(),
                    const SizedBox(height: 18),
                    _buildSecurityCard(),
                    const SizedBox(height: 18),
                    AppFooter(onAbout: _about),
                    SizedBox(height: w < 380 ? 18 : 26),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          const SecurityBadge(),
          const SizedBox(height: 40),
          _buildLabel('Información adicional (opcional)'),
          const SizedBox(height: 12),
          _buildCourseGroupRow(),
          const SizedBox(height: 40),
          _buildLabel('¿Sobre qué necesitas ayuda?', required: true),
          const SizedBox(height: 14),
          _buildTopicsGrid(),
          const SizedBox(height: 40),
          _buildLabel('Tu mensaje', required: true),
          const SizedBox(height: 14),
          CustomTextField(
            hint: 'Cuéntanos lo que te preocupa. Estamos aquí para ayudarte.',
            controller: msgCtrl,
            isMultiline: true,
            minLines: 6,
            maxLines: 8,
          ),
          const SizedBox(height: 40),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Envía tu mensaje',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 2),
              Text(
                'Nadie sabrá que eres tú',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: Colors.black.withValues(alpha: 0.75),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.errorRed,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCourseGroupRow() {
    return Row(
      children: [
        Expanded(
          child: CustomDropdown(
            hint: 'Curso',
            value: curso,
            items: AppData.courses,
            onChanged: (v) => setState(() => curso = v),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomTextField(
            hint: 'Grupo',
            controller: groupCtrl,
            maxLength: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            TopicTile(
              width: w,
              height: 64,
              selected: topic == 'bullying',
              icon: Icons.shield_outlined,
              label: 'Bullying',
              onTap: () => setState(() => topic = 'bullying'),
            ),
            TopicTile(
              width: w,
              height: 64,
              selected: topic == 'academica',
              icon: Icons.school_outlined,
              label: 'Dificultad académica',
              onTap: () => setState(() => topic = 'academica'),
            ),
            TopicTile(
              width: w,
              height: 64,
              selected: topic == 'emociones',
              icon: Icons.favorite_border,
              label: 'Problemas emocionales',
              onTap: () => setState(() => topic = 'emociones'),
            ),
            TopicTile(
              width: w,
              height: 64,
              selected: topic == 'otro',
              icon: Icons.more_horiz,
              label: 'Otro',
              onTap: () => setState(() => topic = 'otro'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isValid ? _send : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isValid
              ? AppColors.teal
              : AppColors.teal.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _sending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(
          _sending ? 'Enviando...' : 'Enviar mensaje anónimo',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.tealSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: const Column(
        children: [
          Icon(Icons.verified_user_outlined, size: 26, color: AppColors.teal),
          SizedBox(height: 10),
          Text(
            'Tu seguridad es nuestra prioridad',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'QuietHelp fue creado para que puedas pedir ayuda sin miedo.\n'
            'Cada mensaje es tratado con el máximo cuidado y confidencialidad por\n'
            'profesionales capacitados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
