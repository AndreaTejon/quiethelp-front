import 'package:flutter/material.dart';
import 'messageSent.dart';
import 'chatHistoryStudent.dart';
import 'signIn.dart';
import 'aboutUs.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);
  
  final msgCtrl = TextEditingController();
  final groupCtrl = TextEditingController();
  String? curso, topic;

  @override
  void dispose() {
    msgCtrl.dispose();
    groupCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (msgCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe tu mensaje antes de enviar')),
      );
      return;
    }
    _push(const MessageSent());
  }

  void _push(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  void _logout() => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInPage()), (_) => false);
  void _notifications() => _push(const ChatHistoryStudent());
  void _about() => _push(const AboutUs());

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    
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
    child: PopupMenuButton<_Menu>(
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      offset: const Offset(0, 52),
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
          value: _Menu.about,
          height: 44,
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.black.withOpacity(0.70)),
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
          value: _Menu.logout,
          height: 44,
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Colors.black.withOpacity(0.70)),
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
      onSelected: (v) => v == _Menu.logout ? _logout() : _about(),
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
        onPressed: _notifications,
        icon: const Icon(Icons.notifications_none_outlined),
      ),
    ),
  ],
),

      body: LayoutBuilder(builder: (context, c) {
        final pad = c.maxWidth >= 900 ? 64.0 : 22.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(children: [
                _buildMessageCard(),
                const SizedBox(height: 18),
                _buildSecurityCard(),
                const SizedBox(height: 18),
                _buildFooter(w, _about),
                SizedBox(height: w < 380 ? 18 : 26),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(),
        const SizedBox(height: 14),
        _buildSecureBadge(),
        
        const SizedBox(height: 40),
        _buildLabel('Información adicional (opcional)'),
        const SizedBox(height: 12),
        _buildCourseGroupRow(),
        
        const SizedBox(height: 40),
        _buildLabel('¿Sobre qué necesitas ayuda?'),
        const SizedBox(height: 14),
        _buildTopicsGrid(),
        
        const SizedBox(height: 40),
        _buildLabel('Tu mensaje', required: true),
        const SizedBox(height: 14),
        _buildMessageField(),
        
        const SizedBox(height: 40),
        _buildSendButton(),
      ]),
    );
  }

  Widget _buildHeader() => Row(children: [
    Container(
      width: 38, height: 38,
      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text('Envía tu mensaje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      SizedBox(height: 2),
      Text('Nadie sabrá que eres tú', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black45)),
    ])),
  ]);

  Widget _buildSecureBadge() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF3FBFA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: teal.withOpacity(0.25)),
    ),
    child: Row(children: [
      const Icon(Icons.lock_outline, size: 16, color: teal),
      const SizedBox(width: 8),
      Expanded(child: Text('Conexión segura y anónima', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: teal.withOpacity(0.9)))),
      Container(width: 6, height: 6, decoration: const BoxDecoration(color: teal, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text('Cifrado activo', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: teal.withOpacity(0.9))),
    ]),
  );

  Widget _buildLabel(String text, {bool required = false}) => Row(children: [
    Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.75))),
    if (required) ...[const SizedBox(width: 4), const Text('*', style: TextStyle(color: Color(0xFFFF5A5F), fontWeight: FontWeight.w900))],
  ]);

  Widget _buildCourseGroupRow() => Row(children: [
    Expanded(child: _DropdownField(
      hint: 'Curso', value: curso,
      items: const ['1º','2º','3º','4º','5º','6º','Otro'],
      onChanged: (v) => setState(() => curso = v),
    )),
    const SizedBox(width: 10),
    Expanded(child: _TextFieldBox(hint: 'Grupo', controller: groupCtrl, maxLength: 40)),
  ]);

  Widget _buildTopicsGrid() => LayoutBuilder(builder: (context, c) {
    final w = (c.maxWidth - 10) / 2;
    final topics = [
      ('bullying', Icons.shield_outlined, 'Bullying'),
      ('academica', Icons.school_outlined, 'Dificultad académica'),
      ('emociones', Icons.favorite_border, 'Problemas emocionales'),
      ('otro', Icons.more_horiz, 'Otro'),
    ];
    return Wrap(spacing: 10, runSpacing: 10, children: topics.map((t) => _TopicTile(
      width: w, height: 64,
      selected: topic == t.$1,
      icon: t.$2, label: t.$3,
      onTap: () => setState(() => topic = t.$1),
    )).toList());
  });

  Widget _buildMessageField() => TextField(
    controller: msgCtrl,
    minLines: 6, maxLines: 8,
    decoration: InputDecoration(
      hintText: 'Cuéntanos lo que te preocupa. Estamos aquí para ayudarte.',
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.25), fontWeight: FontWeight.w600, fontSize: 12.5),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.12))),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: teal, width: 1.4)),
    ),
  );

  Widget _buildSendButton() => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton.icon(
      onPressed: _send,
      style: ElevatedButton.styleFrom(
        backgroundColor: teal.withOpacity(0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.send_rounded, size: 18),
      label: const Text('Enviar mensaje anónimo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
    ),
  );

  Widget _buildSecurityCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF6F5),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.black.withOpacity(0.05)),
    ),
    child: Column(children: const [
      Icon(Icons.verified_user_outlined, size: 26, color: teal),
      SizedBox(height: 10),
      Text('Tu seguridad es nuestra prioridad', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
      SizedBox(height: 8),
      Text('QuietHelp fue creado para que puedas pedir ayuda sin miedo.\nCada mensaje es tratado con el máximo cuidado y confidencialidad por\nprofesionales capacitados.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.5, height: 1.35, fontWeight: FontWeight.w600, color: Colors.black45)),
    ]),
  );

  Widget _buildFooter(double w, VoidCallback onAbout) => Column(children: [
    const Text('QuietHelp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6),
    const Text('Un espacio seguro para estudiantes', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black45)),
    const SizedBox(height: 6),
    GestureDetector(onTap: onAbout, child: const Text('¿Quiénes somos?', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: teal))),
  ]);
}

enum _Menu { logout, about }

class _DropdownField extends StatelessWidget {
  final String hint; final String? value; final List<String> items; final ValueChanged<String?> onChanged;
  const _DropdownField({required this.hint, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black.withOpacity(0.12))),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      isExpanded: true,
      value: value,
      hint: Text(hint, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.35))),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black.withOpacity(0.35)),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)))).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
    )),
  );
}

class _TextFieldBox extends StatelessWidget {
  final String hint; final TextEditingController controller; final int maxLength;
  const _TextFieldBox({required this.hint, required this.controller, required this.maxLength});

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black.withOpacity(0.12))),
    child: Center(child: TextField(
      controller: controller,
      maxLength: maxLength,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.35)),
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
    )),
  );
}

class _TopicTile extends StatelessWidget {
  final double width, height; final bool selected; final IconData icon; final String label; final VoidCallback onTap;
  const _TopicTile({required this.width, required this.height, required this.selected, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      width: width, height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF3FBFA) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? const Color(0xFF2CB9B2).withOpacity(0.65) : Colors.black.withOpacity(0.12)),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: selected ? const Color(0xFF2CB9B2) : Colors.black.withOpacity(0.65)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.2, fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.8)))),
      ]),
    ),
  );
}