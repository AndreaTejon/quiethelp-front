import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/about_info_card.dart';
import '../widgets/value_card.dart';
import '../widgets/contact_line.dart';
import 'studentHomePage.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: 'Quiénes somos',
        subtitle: 'Conoce al equipo detrás de QuietHelp',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padHorizontal = constraints.maxWidth >= 1200
              ? 120.0
              : constraints.maxWidth >= 900
              ? 80.0
              : constraints.maxWidth >= 600
              ? 40.0
              : 20.0;

          final maxContentWidth = constraints.maxWidth >= 1200 ? 900.0 : 1200.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padHorizontal, 24, padHorizontal, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildLogo(),
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 16),
                    _buildDescription(),
                    const SizedBox(height: 32),
                    _buildMissionCard(),
                    const SizedBox(height: 40),
                    _buildValuesTitle(),
                    const SizedBox(height: 24),
                    _buildValuesGrid(),
                    const SizedBox(height: 40),
                    _buildHelpCard(),
                    const SizedBox(height: 40),
                    _buildFooter(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: SizedBox(
        width: 80,
        height: 80,
        child: SvgPicture.asset(
          'assets/images/quiethelp_logo.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text('QuietHelp', style: AppTextStyles.titleLarge),
    );
  }

  Widget _buildDescription() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Text(
          'Somos un espacio seguro creado por y para la comunidad educativa. Nuestro objetivo es que cada estudiante tenga una vía confidencial para expresar sus preocupaciones y recibir el apoyo que necesita.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black.withOpacity(0.55),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionCard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: AboutInfoCard(
          title: 'Nuestra misión',
          child: Text(
            'Crear un canal de comunicación anónimo y seguro donde los estudiantes puedan compartir sus preocupaciones sobre bullying, problemas académicos o situaciones emocionales, garantizando una respuesta profesional y empática.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.black.withOpacity(0.55),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValuesTitle() {
    return const Center(
      child: Text('Nuestros valores', style: AppTextStyles.titleMedium),
    );
  }

  Widget _buildValuesGrid() {
    return LayoutBuilder(
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
            ValueCard(
              title: 'Confidencialidad',
              description:
                  'Tu identidad está completamente protegida. Nadie sabrá quién eres.',
            ),
            ValueCard(
              title: 'Empatía',
              description:
                  'Te escuchamos sin juzgar. Tu bienestar es lo primero.',
            ),
            ValueCard(
              title: 'Comunidad',
              description:
                  'Construimos un entorno más seguro. Juntos es más fácil pedir ayuda.',
            ),
            ValueCard(
              title: 'Acción',
              description:
                  'Damos seguimiento y apoyo. Tu mensaje impulsa una respuesta real.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpCard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: AboutInfoCard(
          title: '¿Necesitas más ayuda?',
          child: Column(
            children: [
              Text(
                'Si prefieres hablar directamente con alguien, también puedes contactar con:',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 20),
              const ContactLine(
                left: 'Teléfono de la Esperanza: ',
                right: '717 003 717',
                suffix: ' (24 horas, gratuito y confidencial)',
              ),
              const SizedBox(height: 12),
              const ContactLine(
                left: 'Línea ',
                right: '024',
                suffix: ' – Atención a la conducta suicida (España, 24h)',
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black.withOpacity(0.55),
                  ),
                  children: const [
                    TextSpan(
                      text: 'En caso de emergencia inmediata, llama al ',
                    ),
                    TextSpan(
                      text: '112.',
                      style: TextStyle(
                        color: AppColors.teal,
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
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text('QuietHelp', style: AppTextStyles.labelLarge),
        const SizedBox(height: 6),
        Text(
          'Un espacio seguro para estudiantes',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.black.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}
