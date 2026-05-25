import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'studentHomePage.dart';
import 'chatHistoryStudent.dart';
import 'aboutUs.dart';

class MessageSent extends StatefulWidget {
  final bool urgente;

  const MessageSent({super.key, this.urgente = false});

  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);

  @override
  State<MessageSent> createState() => _MessageSentState();
}

class _MessageSentState extends State<MessageSent> {
  late bool mostrarAviso;

  @override
  void initState() {
    super.initState();
    mostrarAviso = widget.urgente;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: MessageSent.bgSoft,

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
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatHistoryStudent(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_none_outlined),
              ),

              const SizedBox(width: 6),
            ],
          ),

          body: SafeArea(
            top: false,

            child: LayoutBuilder(
              builder: (context, constraints) {

                final isDesktop = constraints.maxWidth >= 900;

                final horizontalPadding =
                    isDesktop ? 64.0 : 22.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    18,
                  ),

                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 1200),

                      child: Column(
                        children: [

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius:
                                  BorderRadius.circular(18),

                              border: Border.all(
                                color: Colors.black.withOpacity(0.06),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.04),

                                  blurRadius: 18,

                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Row(
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

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [

                                          const Text(
                                            'Envía tu mensaje',

                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black,
                                            ),
                                          ),

                                          const SizedBox(height: 2),

                                          Text(
                                            'Nadie sabrá que eres tú',

                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w600,

                                              color: Colors.black
                                                  .withOpacity(0.45),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Divider(
                                  color:
                                      Colors.black.withOpacity(0.08),

                                  height: 18,
                                ),

                                const SizedBox(height: 22),

                                Center(
                                  child: Container(
                                    width: 42,
                                    height: 42,

                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(
                                            color: MessageSent.teal,
                                            width: 2,
                                          ),

                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),

                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: MessageSent.teal,
                                      size: 24,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                const Center(
                                  child: Text(
                                    'Mensaje enviado con éxito',

                                    textAlign: TextAlign.center,

                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Center(
                                  child: Text(
                                    'Tu mensaje ha sido recibido de forma\nsegura y anónima. Un adulto de confianza lo\nrevisará pronto.',

                                    textAlign: TextAlign.center,

                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,

                                      color:
                                          Colors.black.withOpacity(0.45),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                Center(
                                  child: SizedBox(
                                    height: 44,

                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,

                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const StudentHomePage(),
                                          ),
                                        );
                                      },

                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            MessageSent.teal,

                                        side: BorderSide(
                                          color:
                                              MessageSent.teal
                                                  .withOpacity(0.85),
                                        ),

                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),

                                      child: const Text(
                                        'Enviar otro mensaje',

                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF6F5),

                              borderRadius:
                                  BorderRadius.circular(18),

                              border: Border.all(
                                color: Colors.black.withOpacity(0.05),
                              ),
                            ),

                            child: Column(
                              children: [

                                const Icon(
                                  Icons.verified_user_outlined,
                                  size: 26,
                                  color: MessageSent.teal,
                                ),

                                const SizedBox(height: 10),

                                const Text(
                                  'Tu seguridad es nuestra prioridad',

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'QuietHelp fue creado para que puedas pedir ayuda sin miedo.\nCada mensaje es tratado con el máximo cuidado y confidencialidad por\nprofesionales capacitados.',

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,

                                    color:
                                        Colors.black.withOpacity(0.45),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 42),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // =========================
        // MODAL URGENTE
        // =========================

        if (mostrarAviso)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  mostrarAviso = false;
                });
              },

              child: Material(
                color: Colors.transparent,

                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10,
                    ),

                    child: Container(
                      color: Colors.black.withOpacity(0.60),

                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              mostrarAviso = false;
                            });
                          },

                          child: Container(

                            // =========================
                            // TAMAÑO MÁXIMO
                            // =========================
                            constraints: const BoxConstraints(
                              maxWidth: 420,
                            ),

                            margin: const EdgeInsets.symmetric(
                              horizontal: 28,
                            ),

                            // =========================
                            // PADDING DEL AVISO
                            // CAMBIA ESTO
                            // =========================
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 24,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4F4),

                              borderRadius:
                                  BorderRadius.circular(22),

                              border: Border.all(
                                color: Colors.redAccent,
                                width: 1.2,
                              ),
                            ),

                            child: const Column(
                              mainAxisSize: MainAxisSize.min,

                              crossAxisAlignment:
                                  CrossAxisAlignment.center,

                              children: [

                                Text(
                                  'Si estás pasando por un momento muy difícil y sientes que no puedes más, no te quedes solo/a.',

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),

                                SizedBox(height: 18),

                                Text(
                                  '📞 Teléfono de la Esperanza\n717 003 717',

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),

                                SizedBox(height: 14),

                                Text(
                                  '📞 Línea 024\nAtención a la conducta suicida',

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),

                                SizedBox(height: 14),

                                Text(
                                  '🚨 Emergencia inmediata: 112',

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.redAccent,
                                  ),
                                ),

                                SizedBox(height: 20),

                                Text(
                                  'Tu vida importa.',

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}