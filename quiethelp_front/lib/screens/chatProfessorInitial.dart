// chatProfessorInitial.dart
import 'package:flutter/material.dart';

class ChatProfessorInitialPage extends StatefulWidget {
  final String category;
  final String status; // "Pendiente" | "En revisión" | "Resuelto"
  final String dateText; // "15 ene 2024, 10:30"
  final String schoolText; // "IES Ramiro de Maeztu (28001)"
  final String groupText; // "2º ESO B"
  final String message;

  const ChatProfessorInitialPage({
    super.key,
    required this.category,
    this.status = 'Pendiente',
    required this.dateText,
    required this.schoolText,
    required this.groupText,
    required this.message,
  });

  @override
  State<ChatProfessorInitialPage> createState() => _ChatProfessorInitialPageState();
}

class _ChatProfessorInitialPageState extends State<ChatProfessorInitialPage> {
  static const teal = Color(0xFF2CB9B2);
  static const bgSoft = Color(0xFFEFF7F6);

  // En la captura el botón seleccionado se ve más "azul" que el teal del logo
  static const selectedBlue = Color(0xFF0C6F8A);

  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  bool get _isPending => _status == 'Pendiente';
  bool get _isReview => _status == 'En revisión';
  bool get _isSolved => _status == 'Resuelto';

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
            Image.asset('assets/images/quiethelp_logo.png', height: 28),
            const SizedBox(width: 8),
            const Text(
              'QuietHelp',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        
        actions: [
          // ❌ ELIMINADO: Icono de grid_view_rounded
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.notifications_none_outlined)
          ),
          const SizedBox(width: 6),
        ],
      ),
      
      body: LayoutBuilder(builder: (context, constraints) {
        final pad = constraints.maxWidth >= 900 ? 64.0 : 22.0;
        
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DetailCard(
                    category: widget.category,
                    status: _status,
                    dateText: widget.dateText,
                    schoolText: widget.schoolText,
                    groupText: widget.groupText,
                    message: widget.message,
                    isPending: _isPending,
                    isReview: _isReview,
                    isSolved: _isSolved,
                    onStatusTap: (v) => setState(() => _status = v),
                  ),
                  
                  // 🔹 MÁS ESPACIO: Entre tarjeta y botón - AUMENTADO
                  const SizedBox(height: 35), // Antes 18
                  
                  // 🔹 BOTÓN MÁS ESTRECHO: Centrado y con ancho limitado
                  Center(
                    child: SizedBox(
                      width: 700, // Ancho máximo en desktop
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pedir más información (pendiente de implementar)')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal.withOpacity(0.45),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16), // Más padding vertical
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Pedir más información',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  
                  // 🔹 ESPACIO EXTRA: Después del botón
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

class _DetailCard extends StatelessWidget {
  final String category;
  final String status;
  final String dateText;
  final String schoolText;
  final String groupText;
  final String message;

  final bool isPending;
  final bool isReview;
  final bool isSolved;

  final ValueChanged<String> onStatusTap;

  const _DetailCard({
    required this.category,
    required this.status,
    required this.dateText,
    required this.schoolText,
    required this.groupText,
    required this.message,
    required this.isPending,
    required this.isReview,
    required this.isSolved,
    required this.onStatusTap,
  });

  static const teal = Color(0xFF2CB9B2);
  static const selectedBlue = Color(0xFF0C6F8A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 10),
          
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.black.withOpacity(0.45)),
                  const SizedBox(width: 6),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.black.withOpacity(0.45)),
                  const SizedBox(width: 6),
                  Text(
                    schoolText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_outlined, size: 14, color: Colors.black.withOpacity(0.45)),
                  const SizedBox(width: 6),
                  Text(
                    groupText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.08), height: 1),

          const SizedBox(height: 14),
          const Text(
            'Mensaje del alumno',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.65),
              ),
            ),
          ),
          
          // 🔹 MÁS ESPACIO: Entre mensaje y divider
          const SizedBox(height: 24), // Antes 14
          
          Divider(color: Colors.black.withOpacity(0.08), height: 1),

          // 🔹 MÁS ESPACIO: Entre divider y botones de estado
          const SizedBox(height: 40), // Antes 16
          
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    _StateButton(
                      text: 'Pendiente',
                      icon: Icons.access_time,
                      selected: isPending,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('Pendiente'),
                    ),
                    const SizedBox(height: 8),
                    _StateButton(
                      text: 'En revisión',
                      icon: Icons.chat_bubble_outline,
                      selected: isReview,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('En revisión'),
                    ),
                    const SizedBox(height: 8),
                    _StateButton(
                      text: 'Resuelto',
                      icon: Icons.check_circle_outline,
                      selected: isSolved,
                      selectedColor: selectedBlue,
                      onTap: () => onStatusTap('Resuelto'),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: _StateButton(
                        text: 'Pendiente',
                        icon: Icons.access_time,
                        selected: isPending,
                        selectedColor: selectedBlue,
                        onTap: () => onStatusTap('Pendiente'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StateButton(
                        text: 'En revisión',
                        icon: Icons.chat_bubble_outline,
                        selected: isReview,
                        selectedColor: selectedBlue,
                        onTap: () => onStatusTap('En revisión'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StateButton(
                        text: 'Resuelto',
                        icon: Icons.check_circle_outline,
                        selected: isSolved,
                        selectedColor: selectedBlue,
                        onTap: () => onStatusTap('Resuelto'),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          
          // 🔹 ESPACIO EXTRA: Después de los botones de estado
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pendiente';
    final isReview = status == 'En revisión';
    final isSolved = status == 'Resuelto';
    
    Color pillBg;
    Color pillText;
    
    if (isPending) {
      pillBg = const Color(0xFFFFF2DE);
      pillText = const Color(0xFFE09B2D);
    } else if (isReview) {
      pillBg = const Color(0xFFE3F2FD);
      pillText = const Color(0xFF0C6F8A);
    } else if (isSolved) {
      pillBg = const Color(0xFFE8F5E9);
      pillText = const Color(0xFF2E7D32);
    } else {
      pillBg = Colors.black.withOpacity(0.06);
      pillText = Colors.black.withOpacity(0.65);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending ? Icons.access_time : 
            isReview ? Icons.chat_bubble_outline : 
            isSolved ? Icons.check_circle_outline : 
            Icons.folder_outlined,
            size: 14, 
            color: pillText
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: pillText),
          ),
        ],
      ),
    );
  }
}

class _StateButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _StateButton({
    required this.text,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedColor : Colors.transparent;
    final border = selected ? selectedColor : selectedColor.withOpacity(0.8);
    final fg = selected ? Colors.white : selectedColor;

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: fg),
        label: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: fg),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}