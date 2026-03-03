import 'dart:convert';
import 'package:coap/coap.dart';

class CoapTemperatureService {
  Future<double?> getTemperature(String ip, int port) async {
    try {
      final client = CoapClient(Uri.parse("coap://$ip:$port"));

      final response = await client
          .get(Uri(path: "/temperature"))
          .timeout(const Duration(seconds: 2));

      client.close();

      final decoded = utf8.decode(response.payload);
      final json = jsonDecode(decoded);

      return (json['temperature'] as num).toDouble();
    } catch (_) {
      return null;
    }
  }

  Future<bool> setTemperature(String ip, int port, double value) async {
    try {
      final client = CoapClient(Uri.parse("coap://$ip:$port"));

      final payload = jsonEncode({"temperature": value});

      final response = await client
          .put(
            Uri(path: "/temperature"),
            payload: payload,
          )
          .timeout(const Duration(seconds: 2));

      client.close();

      return response.code.isSuccess;
    } catch (_) {
      return false;
    }
  }
}