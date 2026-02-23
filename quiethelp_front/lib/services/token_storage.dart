// lib/services/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _key = 'alumno_token';
  
  // Guardar token después de login
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
    print('✅ Token guardado: $token');
  }
  
  // Obtener token guardado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
  
  // Eliminar token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    print('🔓 Token eliminado');
  }
  
  // Verificar si hay token
  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }
}