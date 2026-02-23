// chatHistoryStudent.dart
import 'package:flutter/material.dart';
import 'chatPageStudent.dart';

class ChatHistoryStudent extends StatelessWidget {
  const ChatHistoryStudent({super.key});

  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);

  @override
  Widget build(BuildContext context) {
    final items = <_ChatHistoryItem>[
      _ChatHistoryItem(
        title: 'Problemas con compañeros',
        tag: 'Emocional',
        preview: 'Hola, necesito ....',
        dateText: '15 ene 2024, 10:30',
        placeText: 'IES Santísima Trinidad (37007)',
        courseText: '2º DAM',
      ),
      _ChatHistoryItem(
        title: 'Me cuesta matemáticas',
        tag: 'Académico',
        preview: 'No entiendo fracciones y me da vergüenza preguntar...',
        dateText: '18 ene 2024, 09:10',
        placeText: 'IES Ramiro de Maeztu (28001)',
        courseText: '2º ESO B',
      ),
    ];

    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chats con respuesta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Un profesor pide más información para ayudarte',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ),
      ),
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final horizontalPadding = isDesktop ? 64.0 : 16.0;

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
                    children: [
                      // Lista de conversaciones
                      ...items.map((it) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChatHistoryCard(
                          item: it,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPageStudent(
                                  title: it.title,
                                  tag: it.tag,
                                  dateText: it.dateText,
                                  placeText: it.placeText,
                                  courseText: it.courseText,
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                      
                      // 🔹 MODIFICADO: EXACTAMENTE COMO EN LA IMAGEN
                      // Línea separadora
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        height: 1,
                        color: Colors.black.withOpacity(0.08),
                      ),
                      
                      // Texto informativo exacto de la imagen
                      Text(
                        'Tus conversaciones sólo aparecen aquí cuando un profesor te responde pidiendo más información.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      
                      const SizedBox(height: 18),
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

class _ChatHistoryCard extends StatelessWidget {
  final _ChatHistoryItem item;
  final VoidCallback onTap;

  const _ChatHistoryCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FBFA),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Color(0xFF2CB9B2).withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    item.tag,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.75),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            // Metadatos responsivos
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                
                if (isWide) {
                  return Row(
                    children: [
                      _buildMetaItem(
                        icon: Icons.access_time,
                        text: item.dateText,
                      ),
                      const SizedBox(width: 16),
                      _buildMetaItem(
                        icon: Icons.location_on_outlined,
                        text: item.placeText,
                      ),
                      const SizedBox(width: 16),
                      _buildMetaItem(
                        icon: Icons.school_outlined,
                        text: item.courseText,
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetaItem(
                        icon: Icons.access_time,
                        text: item.dateText,
                      ),
                      const SizedBox(height: 8),
                      _buildMetaItem(
                        icon: Icons.location_on_outlined,
                        text: item.placeText,
                      ),
                      const SizedBox(height: 8),
                      _buildMetaItem(
                        icon: Icons.school_outlined,
                        text: item.courseText,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black.withOpacity(0.35)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.45),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatHistoryItem {
  final String title;
  final String tag;
  final String preview;
  final String dateText;
  final String placeText;
  final String courseText;

  const _ChatHistoryItem({
    required this.title,
    required this.tag,
    required this.preview,
    required this.dateText,
    required this.placeText,
    required this.courseText,
  });
}