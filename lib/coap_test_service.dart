import 'dart:convert';
import 'package:coap/coap.dart';

class CoapTestService {

  Future<String> fetchHealth(String ip) async {
    try {
      final baseUri = Uri.parse("coap://$ip:5683");

      final client = CoapClient(baseUri);

      print("Flutter envoie vers IP: $ip");

      final healthUri = Uri(path: "/health");

      final response = await client.get(healthUri).timeout(
        const Duration(seconds: 2),
      );

      final decoded = utf8.decode(response.payload);
      return decoded;

    } catch (e) {
      return "Error: $e";
    }
  }
}