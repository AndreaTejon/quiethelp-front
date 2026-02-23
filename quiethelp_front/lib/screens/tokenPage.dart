import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../widgets/token_input_field.dart';
import '../widgets/page_header.dart';
import '../widgets/disclaimer_text.dart';
import '../widgets/home_button.dart';
import '../services/token_service.dart';
import 'studentHomePage.dart';
import '../services/token_storage.dart';

class TokenPage extends StatefulWidget {
  const TokenPage({super.key});

  @override
  State<TokenPage> createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  final TextEditingController _controller = TextEditingController();
  final TokenService _tokenService = TokenService();
  bool _isValidating = false;
  String? _errorDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAccess() {
    final token = _controller.text.trim().toUpperCase();

    if (token.isEmpty) {
      _showSnackBar('Introduce un token válido');
      return;
    }

    setState(() {
      _isValidating = true;
      _errorDetails = null;
    });

    _tokenService.validateToken(token).then((isValid) async{
      if (!mounted) return;
      
      if (isValid) {
        await TokenStorage.saveToken(token); //Se guarda el token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentHomePage(token: token),
          ),
        );
      } else {
        setState(() {
          _isValidating = false;
          _errorDetails = 'El token no es válido o no existe en la base de datos';
        });
        _showSnackBar('Token inválido o expirado');
      }
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _errorDetails = 'Error de conexión con el servidor';
      });
      _showSnackBar('Error de conexión. Verifica que el backend esté corriendo');
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
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
                      const SizedBox(height: 18),
                      PageHeader(
                        title: 'Acceso con Token',
                        subtitle: 'Introduce el token de acceso proporcionado',
                      ),
                      const SizedBox(height: 34),
                      _buildTokenLabel(),
                      const SizedBox(height: 10),
                      TokenInputField(
                        controller: _controller,
                        onSubmitted: _onAccess,
                      ),
                      const SizedBox(height: 10),
                      _buildTokenHint(),
                      if (_errorDetails != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorDetails!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      HomeButton(
                        text: _isValidating ? 'Validando...' : 'Acceder',
                        onPressed: _isValidating ? () {} : _onAccess,
                        backgroundColor: AppColors.teal,
                      ),
                      const Spacer(),
                      const DisclaimerText(
                        text: 'Si estás en peligro inmediato, contacta a las autoridades',
                      ),
                      const SizedBox(height: 18),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
      ),
    );
  }

  Widget _buildTokenLabel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Token de acceso',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Colors.black.withValues(alpha: 0.65),
        ),
      ),
    );
  }

  Widget _buildTokenHint() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'El token fue enviado por la administración',
        style: TextStyle(
          fontSize: 11,
          color: Colors.black.withValues(alpha: 0.35),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}