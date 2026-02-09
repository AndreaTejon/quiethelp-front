import 'package:flutter/material.dart';
import 'tokenPage.dart';
import 'signIn.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF2CB9B2);
    const tealSoft = Color(0xFFE7F7F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 22),

              Image.asset(
                'assets/images/quiethelp_logo.png',
                width: 78,
                height: 78,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 18),

              const Text(
                'Espacio Seguro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Un lugar donde puedes hablar sin miedo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.25,
                  color: Colors.black.withOpacity(0.45),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              _InfoCard(
                icon: Icons.shield_outlined,
                iconBg: tealSoft,
                iconColor: teal,
                title: '100% Anónimo',
                subtitle: 'Tu identidad está completamente\nprotegida',
              ),

              const SizedBox(height: 14),

              _InfoCard(
                icon: Icons.lock_outline,
                iconBg: tealSoft,
                iconColor: teal,
                title: 'Sin historial',
                subtitle: 'Los mensajes no se guardan en\nningún lugar',
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TokenPage()),
                    );*/
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enviar mensaje anónimo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                    );*/
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal.withOpacity(0.85),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Acceso comité',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Si estás en peligro inmediato, contacta a las autoridades',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.35),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.25,
                    color: Colors.black.withOpacity(0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
