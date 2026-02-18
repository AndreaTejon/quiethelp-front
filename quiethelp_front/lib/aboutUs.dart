import 'package:flutter/material.dart';
import 'studentHomePage.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  static const teal = Color(0xFF2CB9B2);
  static const softCard = Color(0xFFEAF6F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // ===========
      // HEADER 
      // ===========
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text(
              'Quiénes somos',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Conoce al equipo detrás de QuietHelp',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ],
        ),
      ),
      
      // ============================================
      // BODY RESPONSIVE CON MÁS ESPACIO A LOS LADOS
      // ============================================
      body: LayoutBuilder(builder: (context, constraints) {
        // Padding responsive
        final padHorizontal = constraints.maxWidth >= 1200 ? 120.0 : 
                             constraints.maxWidth >= 900 ? 80.0 : 
                             constraints.maxWidth >= 600 ? 40.0 : 20.0;
        
        // Ancho máximo del contenido
        final maxContentWidth = constraints.maxWidth >= 1200 ? 900.0 : 1200.0;
        
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padHorizontal, 24, padHorizontal, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =======
                  // LOGO 
                  // =======
                  const SizedBox(height: 16),
                  
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      // ❌ SIN círculo ni clip
                      child: Image.asset(
                        'assets/images/quiethelp_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'QuietHelp',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================================
                  // TEXTO DESCRIPTIVO - ANCHO CONTROLADO
                  // ============================================
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        'Somos un espacio seguro creado por y para la comunidad educativa. Nuestro objetivo es que cada estudiante tenga una vía confidencial para expresar sus preocupaciones y recibir el apoyo que necesita.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ============================================
                  // MISIÓN CARD - ANCHO CONTROLADO
                  // ============================================
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF8F7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Nuestra misión',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Crear un canal de comunicación anónimo y seguro donde los estudiantes puedan compartir sus preocupaciones sobre bullying, problemas académicos o situaciones emocionales, garantizando una respuesta profesional y empática.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ============================
                  // VALORES - GRID RESPONSIVE
                  // ============================
                  const Center(
                    child: Text(
                      'Nuestros valores',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                      
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.2,
                        children: const [
                          _ValueCard(
                            title: 'Confidencialidad',
                            description: 'Tu identidad está completamente protegida. Nadie sabrá quién eres.',
                          ),
                          _ValueCard(
                            title: 'Empatía',
                            description: 'Te escuchamos sin juzgar. Tu bienestar es lo primero.',
                          ),
                          _ValueCard(
                            title: 'Comunidad',
                            description: 'Construimos un entorno más seguro. Juntos es más fácil pedir ayuda.',
                          ),
                          _ValueCard(
                            title: 'Acción',
                            description: 'Damos seguimiento y apoyo. Tu mensaje impulsa una respuesta real.',
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // ===================================
                  // AYUDA CARD - ANCHO CONTROLADO
                  // ===================================
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF8F7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '¿Necesitas más ayuda?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Si prefieres hablar directamente con alguien, también puedes contactar con:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.55),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            _ContactLine(
                              left: 'Teléfono de la Esperanza: ',
                              right: '717 003 717',
                              suffix: ' (24 horas, gratuito y confidencial)',
                            ),
                            const SizedBox(height: 12),
                            _ContactLine(
                              left: 'Línea ',
                              right: '024',
                              suffix: ' – Atención a la conducta suicida (España, 24h)',
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withOpacity(0.55),
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'En caso de emergencia inmediata, llama al ',
                                  ),
                                  TextSpan(
                                    text: '112.',
                                    style: TextStyle(
                                      color: teal,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =========================================
                  // BOTÓN - MÁS ESTRECHO EN DESKTOP
                  // ======================================
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const StudentHomePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Enviar mensaje anónimo',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ============================================
                  // FOOTER
                  // ============================================
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
                    ],
                  ),
                  
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

// ============================================
// VALUE CARD - MEJORADA PARA GRID
// ============================================
class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.title, required this.description});

  final String title;
  final String description;

  static const card = Color(0xFFDBF1EF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CONTACT LINE - MEJORADA
// ============================================
class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.left,
    required this.right,
    required this.suffix,
  });

  final String left;
  final String right;
  final String suffix;

  static const teal = Color(0xFF2CB9B2);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: Colors.black.withOpacity(0.55),
        ),
        children: [
          TextSpan(text: left),
          TextSpan(
            text: right,
            style: const TextStyle(color: teal, fontWeight: FontWeight.w800),
          ),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}