import 'package:flutter/material.dart';
import '../constants/app_theme.dart';  // 👈 IMPORTANTE: con ../ para subir de screens/ a lib/
import '../widgets/professor/stats_grid.dart';  // 👈 Con ../
import '../widgets/professor/category_filter.dart';
import '../widgets/professor/status_tabs.dart';
import '../widgets/professor/message_card.dart';
import '../widgets/footer.dart';
import '../widgets/menu_popup.dart';
import 'chatProfessorInitial.dart';
import 'signIn.dart';
import 'aboutUs.dart';


class ProfessorHomePage extends StatefulWidget {
  const ProfessorHomePage({super.key});

  @override
  State<ProfessorHomePage> createState() => _ProfessorHomePageState();
}

class _ProfessorHomePageState extends State<ProfessorHomePage> {
  String _category = 'Todos';
  int _tabIndex = 0;

  void _openNotifications() {
    // Aquí puedes navegar a notificaciones
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (route) => false,
    );
  }

  void _goToAboutUs() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUs()));
  }

  void _navigateToChat(String category, String date, String message) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatsGrid(onTap: (i) => setState(() => _tabIndex = i)),
                  const SizedBox(height: 28),
                  CategoryFilter(
                    value: _category,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 20),
                  StatusTabs(
                    index: _tabIndex,
                    onChanged: (i) => setState(() => _tabIndex = i),
                  ),
                  const SizedBox(height: 32),
                  ..._buildMessageList(),
                  const SizedBox(height: 48),
                  AppFooter(onAbout: _goToAboutUs),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 56,
      leading: const Padding(
        padding: EdgeInsets.only(left: 8),
        child: MenuPopup(), // Tu widget existente
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

  List<Widget> _buildMessageList() {
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
  }
}