import 'package:flutter/material.dart';
import 'studentHomePage.dart';
import 'chatHistoryStudent.dart';
import 'aboutUs.dart';

class MessageSent extends StatelessWidget {
  const MessageSent({super.key});

  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);

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
                MaterialPageRoute(builder: (_) => const ChatHistoryStudent()),
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
            final horizontalPadding = isDesktop ? 64.0 : 22.0;

            return Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                // 🔹 MODIFICADO: Movemos el Center y ConstrainedBox aquí dentro
                // para que sea idéntico a StudentHomePage
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  14,
                  horizontalPadding,
                  18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    // 🔹 MODIFICADO: Aumentamos el maxWidth de 800 a 1200 
                    // para que coincida con StudentHomePage y tenga mejor 
                    // espaciado en desktop
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.06)),
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
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black.withOpacity(0.45),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(
                                  color: Colors.black.withOpacity(0.08),
                                  height: 18),
                              const SizedBox(height: 22),
                              Center(
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: teal, width: 2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: teal,
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
                                    color: Colors.black.withOpacity(0.45),
                                  ),
                                ),
                              ),
                              // 🔹 MODIFICADO: Aumentamos el espacio entre el mensaje y el botón
                              const SizedBox(height: 32), // Antes era 18
                              Center(
                                child: SizedBox(
                                  height: 44, // 🔹 MODIFICADO: Ligeramente más alto (antes 40)
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
                                      foregroundColor: teal,
                                      side: BorderSide(
                                          color: teal.withOpacity(0.85)),
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
                              // 🔹 MODIFICADO: Aumentamos el espacio inferior dentro de la tarjeta
                              const SizedBox(height: 16), // Antes era 6
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF6F5),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.05)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.verified_user_outlined,
                                  size: 26, color: teal),
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
                                  color: Colors.black.withOpacity(0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Column(
                          children: [
                            const Text(
                              'QuietHelp',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Un espacio seguro para estudiantes',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.45),
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AboutUs()),
                                );
                              },
                              child: const Text(
                                '¿Quiénes somos?',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 🔹 MODIFICADO: Aumentamos el espacio inferior general
                        const SizedBox(height: 42), // Antes era 26
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}