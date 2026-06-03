import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_theme.dart';
import '../widgets/info_card.dart';
import '../widgets/home_button.dart';
import 'tokenPage.dart';
import 'signIn.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final horizontalPadding = isDesktop ? 64.0 : 22.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildLogo(),
                      const SizedBox(height: 18),
                      _buildTitle(),
                      const SizedBox(height: 10),
                      _buildSubtitle(),
                      const SizedBox(height: 70),
                      _buildInfoCards(),
                      const SizedBox(height: 18),
                      _buildActionButtons(context),
                      const SizedBox(height: 14),
                      _buildDisclaimer(),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SvgPicture.asset(
      'assets/images/quiethelp_logo.svg',
      width: 78,
      height: 78,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTitle() {
    return const Text(
      'QuietHelp',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Un lugar donde puedes hablar sin miedo',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        height: 1.25,
        color: Colors.black.withValues(alpha: 0.45),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        InfoCard(
          icon: Icons.shield_outlined,
          iconBg: AppColors.tealSoft,
          iconColor: AppColors.teal,
          title: '100% Anónimo',
          subtitle: 'Tu identidad está completamente\nprotegida',
        ),
        const SizedBox(height: 14),
        InfoCard(
          icon: Icons.lock_outline,
          iconBg: AppColors.tealSoft,
          iconColor: AppColors.teal,
          title: 'Sin historial',
          subtitle: 'Los mensajes no se guardan en\nningún lugar',
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        HomeButton(
          text: 'Enviar mensaje anónimo',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TokenPage()),
            );
          },
          backgroundColor: AppColors.teal,
        ),
        const SizedBox(height: 8),
        HomeButton(
          text: 'Acceso profesorado',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInPage()),
            );
          },
          backgroundColor: AppColors.teal.withValues(alpha: 0.85),
          height: 44,
          fontSize: 13,
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Text(
      'Si estás en peligro inmediato, contacta con las autoridades',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        color: Colors.black.withValues(alpha: 0.35),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}