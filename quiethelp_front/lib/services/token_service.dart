import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TokenService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'quiethelp-back.railway.internal';
    }
    return 'http://10.0.2.2:8080';
  }

  static bool _isValidando = false;
  
  Future<bool> validateToken(String token) async {
    if(_isValidando) {
      print('Validación en curso, esperando...');
      for(int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if(!_isValidando) break;
      }
      if(_isValidando) {
        print('Timeout: validación previa no completada');
        return false;
      }
    }
    _isValidando = true;
    print('Validando token: $token');
    
    try {
      // se intenta crear una conversación mínima para validar el token
      final url = Uri.parse('$_baseUrl/api/conversaciones');
      
      final body = {
        "token": token,
        "emisor": {"tarjeta": "Otro",},
        "conversacion": {
          "mensajes": [
            {
              "emisor": "alumno",
              "mensaje": "validación",
            }
          ]
        }
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      
      print('Status code: ${response.statusCode}');
      
      // Si el token es válido, el backend responde con:
      // - 201: si todo está bien (crea conversación)
      // - 400: si falta algún campo pero el token es válido
      // - 401: si el token es inválido
      
      if (response.statusCode == 201 || response.statusCode == 400) {
        return true; // Token válido
      } else if (response.statusCode == 401) {
        return false; // Token inválido
      } else {
        print('Respuesta inesperada: ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('Error de conexión: $e');
      return false; // Error de conexión = token NO válido
    } finally {
      _isValidando = false;
    }
  }
}