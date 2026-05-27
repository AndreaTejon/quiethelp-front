import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class MessageService {

  static String get _baseUrl {
    if (kIsWeb) {
      return 'quiethelp-back.railway.internal';
    }
    return 'http://10.0.2.2:8080';
  }

  static Future<http.Response> sendMessage(MessageRequest request) async {
    return await http.post(
      Uri.parse('$_baseUrl/api/messages'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );
  }

  static String extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        if (decoded["message"] != null) {
          return decoded["message"].toString();
        } else if (decoded.isNotEmpty) {
          return decoded.values.first.toString();
        }
      }
    } catch (_) {}

    return 'Error al enviar (${response.statusCode})';
  }
}