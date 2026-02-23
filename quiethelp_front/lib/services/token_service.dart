// lib/services/token_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TokenService {
  // Ajusta esta URL según tu backend
  static const String _baseUrl = 'http://localhost:8080';
  
  // Método mejorado con más logging y manejo de errores
  Future<bool> validateToken(String token) async {
    print('🔍 Validando token: $token');
    
    try {
      // Opción 1: Si tienes un endpoint específico para validar tokens
      final url = Uri.parse('$_baseUrl/api/validar-token');
      
      print('📡 Llamando a: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      ).timeout(const Duration(seconds: 10));
      
      print('📥 Respuesta status: ${response.statusCode}');
      print('📥 Respuesta body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('📊 Datos parseados: $data');
          
          // Dependiendo de cómo responda tu backend
          // Opción A: { "valido": true }
          if (data['valido'] != null) {
            return data['valido'] == true;
          }
          // Opción B: { "status": "ok" } o similar
          else if (data['status'] == 'ok' || data['status'] == 'success') {
            return true;
          }
          // Opción C: Si devuelve datos del token, asumimos que es válido
          else if (data['token'] != null || data['id'] != null) {
            return true;
          }
        } catch (e) {
          print('❌ Error parseando JSON: $e');
        }
      }
      
      return false;
      
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }
  
  // Método alternativo: probar el token en el endpoint de conversaciones
  Future<bool> testTokenWithConversation(String token) async {
    print('🔍 Probando token en endpoint de conversaciones: $token');
    
    try {
      final url = Uri.parse('$_baseUrl/api/conversaciones');
      
      // Enviar un mensaje de prueba muy simple
      final body = {
        "token": token,
        "emisor": {
          "tarjeta": "Otro",
        },
        "conversacion": {
          "mensajes": [
            {
              "emisor": "alumno",
              "mensaje": "Token de prueba",
            }
          ]
        }
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      print('📥 Status code: ${response.statusCode}');
      
      // Si es 201 (CREATED) o 401 (UNAUTHORIZED) pero con mensaje claro
      if (response.statusCode == 201) {
        return true; // Token válido
      } else if (response.statusCode == 401) {
        // Token inválido
        return false;
      } else {
        // Otro error - podría ser válido pero hay otro problema
        print('❌ Respuesta inesperada: ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }
}