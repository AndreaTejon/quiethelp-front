import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 NUEVO
import 'professorHomePage.dart';
import 'homePage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  static const teal = Color(0xFF2CB9B2);

  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false; // 👈 NUEVO: para controlar estado de carga

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // 🟢 NUEVO: Función de login con Supabase
  Future<void> _onLogin() async {
    final email = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    // Validaciones básicas
    if (email.isEmpty || password.isEmpty) {
      _mostrarError('Completa email y contraseña');
      return;
    }

    // Validar que tenga formato de email (opcional pero recomendado)
    if (!email.contains('@')) {
      _mostrarError('Introduce un email válido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Llamar a Supabase Auth
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // 2️⃣ Obtener datos del usuario
      final user = response.user;
      
      if (user == null) {
        throw Exception('No se pudo obtener el usuario');
      }

      // 3️⃣ Preparar datos del profesor
      final profesorData = {
        'id': user.id,                                // UUID para revisorId
        'email': user.email,
        'nombre': user.email!.split('@').first,       // "profesor" del email
        'metadata': user.userMetadata,                 // Si hay más datos
      };

      print('✅ Login exitoso:');
      print('   - ID: ${profesorData['id']}');
      print('   - Email: ${profesorData['email']}');
      print('   - Nombre: ${profesorData['nombre']}');

      // 4️⃣ Navegar a ProfessorHomePage con los datos
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfessorHomePage(profesorData: profesorData),
          ),
        );
      }

    } on AuthException catch (e) {
      // Error específico de autenticación
      print('❌ AuthException: ${e.message}');
      _mostrarError('Email o contraseña incorrectos');
      
    } catch (e) {
      // Otros errores (red, etc.)
      print('❌ Error: $e');
      _mostrarError('Error de conexión. Intenta de nuevo');
      
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Función auxiliar para mostrar errores
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
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
                      const _TopIcon(),
                      const SizedBox(height: 22),
                      const Text(
                        'Acceso Comité',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Inicia sesión para acceder al panel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.25,
                          color: Colors.black.withOpacity(0.45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email', // 👈 Cambié "Usuario" por "Email"
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.65),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _userCtrl,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading, // 👈 Deshabilitar mientras carga
                        decoration: InputDecoration(
                          hintText: 'profesor@instituto.com',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.25),
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.black.withOpacity(0.35),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: teal,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Contraseña
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contraseña',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.65),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onLogin(),
                        enabled: !_isLoading, // 👈 Deshabilitar mientras carga
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.25),
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.black.withOpacity(0.35),
                          ),
                          suffixIcon: IconButton(
                            onPressed: _isLoading ? null : () => // 👈 No permitir mientras carga
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.black.withOpacity(0.35),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: teal,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Botón de login
                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(  // Mostrar loader mientras carga
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        'Si estás en peligro inmediato, contacta a las autoridades',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.35),
                          fontWeight: FontWeight.w500,
                        ),
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
}

class _TopIcon extends StatelessWidget {
  const _TopIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/quiethelp_logo.png',
      width: 92,
      height: 92,
      fit: BoxFit.contain,
    );
  }
}