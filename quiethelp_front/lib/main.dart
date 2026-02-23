  import 'package:flutter/material.dart';
  import 'screens/loading.dart';
  import 'services/token_storage.dart'; //Para verificar si existe token
  import 'screens/studentHomePage.dart';

  void main() async{
    WidgetsFlutterBinding.ensureInitialized(); //para SharedPreferences
      // Verificar si hay token guardado
    final hasToken = await TokenStorage.hasToken();
    String? token;
    
    if (hasToken) {
      token = await TokenStorage.getToken();
      print('Token encontrado: $token');
    } else {
      print('No hay token guardado');
    }
    runApp(MyApp(initialToken: token));
  }

  class MyApp extends StatelessWidget {
    final String? initialToken;
  
    const MyApp({super.key, this.initialToken});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'QuietHelp',
        debugShowCheckedModeBanner: false,
        home: initialToken != null 
          ? StudentHomePage(token: initialToken)  // 👈 Token existe, va directo a Home
          : const LoadingPage(),                  // 👈 No hay token, va a Loading (que irá a Login)
      );
    }
  }