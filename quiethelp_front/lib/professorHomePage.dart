import 'package:flutter/material.dart';
import 'chatProfessorInitial.dart';
import 'signIn.dart';
import 'aboutUs.dart';

class ProfessorHomePage extends StatefulWidget {
  const ProfessorHomePage({super.key});

  @override
  State<ProfessorHomePage> createState() => _ProfessorHomePageState();
}

class _ProfessorHomePageState extends State<ProfessorHomePage> {
  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);

  String _category = 'Todos';
  int _tabIndex = 0;

  void _openNotifications() {
    // aquí puedes navegar a tu pantalla de notificaciones si la tienes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: PopupMenuButton<_TopMenu>(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),

            // baja el menú para que no salga pegado arriba
            offset: const Offset(0, 52),

            // estilo “card”
            color: Colors.white,
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.12),
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            constraints: const BoxConstraints(minWidth: 220),

            itemBuilder: (_) => [
              PopupMenuItem(
                value: _TopMenu.about,
                height: 44,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.black.withOpacity(0.70),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '¿Quiénes somos?',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _TopMenu.logout,
                height: 44,
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Colors.black.withOpacity(0.70),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (v) =>
                v == _TopMenu.logout ? _logout() : _goToAboutUs(),
          ),
        ),

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/quiethelp_logo.png', height: 28),
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
            child: IconButton(
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_outlined),
            ),
          ),
        ],
      ),

      // mismo wrapper que Student: padding responsive + Center + ConstrainedBox
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
                  // ============================================
                  // SECCIÓN 1: 4 TARJETAS DE ESTADÍSTICAS - AHORA MÁS GRANDES
                  // ============================================
                  _StatsGrid(onTap: (i) => setState(() => _tabIndex = i)),
                  
                  // 🔹 ESPACIO 1: ENTRE TARJETAS Y FILTRO
                  const SizedBox(height: 28),
                  
                  // ============================================
                  // SECCIÓN 2: FILTRO POR CATEGORÍA
                  // ============================================
                  _CategoryFilter(
                    value: _category,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  
                  // 🔹 ESPACIO 2: ENTRE FILTRO Y PESTAÑAS
                  const SizedBox(height: 20),
                  
                  // ============================================
                  // SECCIÓN 3: PESTAÑAS DE ESTADO
                  // ============================================
                  _StatusTabs(
                    index: _tabIndex,
                    onChanged: (i) => setState(() => _tabIndex = i),
                  ),
                  
                  // 🔹 ESPACIO 3: ENTRE PESTAÑAS Y PRIMER MENSAJE
                  const SizedBox(height: 32),
                  
                  // ============================================
                  // SECCIÓN 4: MENSAJES DE ESTUDIANTES
                  // ============================================
                  _MessageCard(
                    category: 'Bullying',
                    urgent: true,
                    body:
                        'Hay un grupo de estudiantes que me molesta todos los días en el recreo. Me quitan mi almuerzo y me dicen cosas feas. No sé qué hacer y tengo miedo de ir a la escuela.',
                    received: 'Recibido: 19 de enero de 2026, 9:00',
                    onReview: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatProfessorInitialPage(
                            category: 'Académico',
                            status: 'Pendiente',
                            dateText: '15 ene 2024, 10:30',
                            schoolText: 'IES Ramiro de Maeztu (28001)',
                            groupText: '2º ESO B',
                            message:
                                'Hay un grupo de compañeros que me molestan todos los días en el recreo. Me quitan las cosas y me dicen cosas feas. No quiero ir al colegio porque me da mucho miedo encontrarme con ellos. Por favor, ayúdenme.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _MessageCard(
                    category: 'Emocional',
                    urgent: false,
                    body:
                        'Últimamente me siento muy triste y no tengo ganas de hacer nada. Mis papás trabajan mucho y no puedo hablar con ellos.',
                    received: 'Recibido: 16 de enero de 2026, 11:00',
                    onReview: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatProfessorInitialPage(
                            category: 'Emocional',
                            status: 'Pendiente',
                            dateText: '16 ene 2026, 11:00',
                            schoolText: 'IES Ramiro de Maeztu (28001)',
                            groupText: '2º ESO B',
                            message:
                                'Últimamente me siento muy triste y no tengo ganas de hacer nada. Mis papás trabajan mucho y no puedo hablar con ellos.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _MessageCard(
                    category: 'Académico',
                    urgent: false,
                    body:
                        'Me está yendo muy mal en matemáticas y lengua. No entiendo varios temas y me atraso mucho, pero me da miedo preguntar porque se han reído de mí.',
                    received: 'Recibido: 19 de enero de 2026, 9:00',
                    onReview: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatProfessorInitialPage(
                            category: 'Académico',
                            status: 'Pendiente',
                            dateText: '19 ene 2026, 9:00',
                            schoolText: 'IES Ramiro de Maeztu (28001)',
                            groupText: '2º ESO B',
                            message:
                                'Me está yendo muy mal en matemáticas y lengua. No entiendo varios temas y me atraso mucho, pero me da miedo preguntar porque se han reído de mí.',
                          ),
                        ),
                      );
                    },
                  ),

                  // 🔹 ESPACIO 4: ENTRE ÚLTIMO MENSAJE Y FOOTER
                  const SizedBox(height: 48),
                  
                  // ============================================
                  // SECCIÓN 5: FOOTER
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
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _goToAboutUs,
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
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

enum _TopMenu { logout, about }

class _StatsGrid extends StatelessWidget {
  final ValueChanged<int> onTap;

  const _StatsGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: 'Pendientes',
                value: '2',
                icon: Icons.inbox_outlined,
                onTap: () => onTap(0),
              ),
            ),
            const SizedBox(width: 16), // Aumentado de 12 a 16
            Expanded(
              child: _StatBox(
                label: 'En revisión',
                value: '1',
                icon: Icons.access_time,
                onTap: () => onTap(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // Aumentado de 12 a 16
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: 'Resueltos',
                value: '1',
                icon: Icons.check_box_outlined,
                onTap: () => onTap(2),
              ),
            ),
            const SizedBox(width: 16), // Aumentado de 12 a 16
            Expanded(
              child: _StatBox(
                label: 'Urgentes',
                value: '1',
                icon: Icons.warning_amber_rounded,
                onTap: () => onTap(0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18), // Aumentado de 14 a 18
      child: Container(
        height: 90, // Aumentado de 70 a 90
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Aumentado padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18), // Aumentado de 14 a 18
          border: Border.all(color: Colors.black.withOpacity(0.08)), // Un poco más visible
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Sombra más visible
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black.withOpacity(0.6)), // Aumentado de 16 a 22
            const SizedBox(width: 12), // Aumentado de 8 a 12
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12, // Aumentado de 10.5 a 12
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 6), // Aumentado de 4 a 6
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24, // Aumentado de 18 a 24
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CategoryFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 18),
          const SizedBox(width: 10),
          _Chip(
            text: 'Todos',
            selected: value == 'Todos',
            onTap: () => onChanged('Todos'),
          ),
          const SizedBox(width: 8),
          _Chip(
            text: 'Bullying',
            selected: value == 'Bullying',
            onTap: () => onChanged('Bullying'),
          ),
          const SizedBox(width: 8),
          _Chip(
            text: 'Académico',
            selected: value == 'Académico',
            onTap: () => onChanged('Académico'),
          ),
          const SizedBox(width: 8),
          _Chip(
            text: 'Emocional',
            selected: value == 'Emocional',
            onTap: () => onChanged('Emocional'),
          ),
          const SizedBox(width: 8),
          _Chip(
            text: 'Otro',
            selected: value == 'Otro',
            onTap: () => onChanged('Otro'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  static const teal = Color(0xFF2CB9B2);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? teal : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: teal),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : teal,
          ),
        ),
      ),
    );
  }
}

class _StatusTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _StatusTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _Tab('Pendientes', index == 0, () => onChanged(0)),
          _Tab('En revisión', index == 1, () => onChanged(1)),
          _Tab('Resueltos', index == 2, () => onChanged(2)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Tab(this.text, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.black.withOpacity(0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(selected ? 0.8 : 0.55),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String category;
  final bool urgent;
  final String body;
  final String received;
  final VoidCallback onReview;

  const _MessageCard({
    required this.category,
    required this.urgent,
    required this.body,
    required this.received,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(category),
              if (urgent) const _UrgentTag(),
              const _StatusTag(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  received,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onReview,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(88, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: BorderSide(color: Colors.black.withOpacity(0.12)),
                ),
                child: const Text(
                  'Revisar',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _UrgentTag extends StatelessWidget {
  const _UrgentTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Urgente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFF5A5F),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2DE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Pendiente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFFE09B2D),
        ),
      ),
    );
  }
}