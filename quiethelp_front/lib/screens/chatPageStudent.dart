// chatPageStudent.dart
import 'package:flutter/material.dart';
import 'chatHistoryStudent.dart';

class ChatPageStudent extends StatefulWidget {
  final String title;
  final String tag;
  final String dateText;
  final String placeText;
  final String courseText;

  const ChatPageStudent({
    super.key,
    required this.title,
    required this.tag,
    required this.dateText,
    required this.placeText,
    required this.courseText,
  });

  @override
  State<ChatPageStudent> createState() => _ChatPageStudentState();
}

class _ChatPageStudentState extends State<ChatPageStudent> {
  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);

  final TextEditingController _ctrl = TextEditingController();

  final List<_ChatMsg> _messages = [
    _ChatMsg(
      fromStudent: true,
      text: 'Me siento mal\n..................\nme pegan todos los días.. ayuda',
    ),
    _ChatMsg(
      fromStudent: false,
      text: 'Mensaje del profesor pidiendo más información relevante para poder ayudar al alumno',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatHistoryStudent()),
    );
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(fromStudent: true, text: text));
      _ctrl.clear();
    });
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
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/quiethelp_logo.png',
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
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),

      // 🔹 MODIFICADO: Eliminamos la Column exterior y usamos LayoutBuilder + SingleChildScrollView
      // con la misma estructura de padding y centrado que en StudentHomePage y MessageSent
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final horizontalPadding = isDesktop ? 64.0 : 22.0;

          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                14,
                horizontalPadding,
                18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tag,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          _MetaChip(icon: Icons.access_time, text: widget.dateText),
                          _MetaChip(icon: Icons.location_on_outlined, text: widget.placeText),
                          _MetaChip(icon: Icons.school_outlined, text: widget.courseText),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ..._messages.map((m) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Align(
                                  alignment: m.fromStudent 
                                      ? Alignment.centerRight 
                                      : Alignment.centerLeft,
                                  child: _Bubble(
                                    fromStudent: m.fromStudent,
                                    text: m.text,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            _InputBox(
                              controller: _ctrl,
                              onSend: _send,
                            ),
                            // 🔹 MODIFICADO: Añadimos espaciado inferior dentro de la tarjeta
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      // 🔹 MODIFICADO: Eliminamos el botón duplicado que estaba fuera del ScrollView
                      // y añadimos espacio inferior
                      const SizedBox(height: 42),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black.withOpacity(0.35)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final bool fromStudent;
  final String text;

  const _Bubble({required this.fromStudent, required this.text});

  @override
  Widget build(BuildContext context) {
    final bg = fromStudent ? const Color(0xFF98CFEA) : const Color(0xFFDDEAF0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: Colors.black.withOpacity(0.78),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBox({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Mensaje...',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.25),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 38,
            width: 42,
            child: IconButton(
              onPressed: onSend,
              icon: Icon(Icons.send_rounded, size: 18, color: Colors.black.withOpacity(0.55)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final bool fromStudent;
  final String text;

  _ChatMsg({required this.fromStudent, required this.text});
}