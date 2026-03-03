import 'dart:convert';
import 'package:coap/coap.dart';

// Inspiré de coap_test_service.dart
// Retourne true si réponse valide, false sinon
// Important : Aucune exception propagée : l'app ne crashe pas

class CoapHealthService {
  Future<bool> ping(String ip, int port) async {
    try {
      // final baseUri = Uri.parse("coap://$ip:$port");
      // final client = CoapClient(baseUri);

      final client = CoapClient(Uri.parse("coap://$ip:$port"));

      final response = await client
          .get(Uri(path: "/health"))
          .timeout(const Duration(seconds: 2));

      client.close();

      final decoded = utf8.decode(response.payload);
      return decoded.isNotEmpty;

    } catch (_) {
      return false;
    }
  }
}