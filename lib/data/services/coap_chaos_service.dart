import 'dart:convert';
import 'package:coap/coap.dart';

class CoapChaosService {

  Future<bool> updateChaos({
    required String ip,
    required int port,
    int? latencyMs,
    double? lossRate,
    bool? offline,
  }) async {
    try {
      final client = CoapClient(Uri.parse("coap://$ip:$port"));

      final payload = jsonEncode({
        if (latencyMs != null) "latency_ms": latencyMs,
        if (lossRate != null) "loss_rate": lossRate,
        if (offline != null) "offline": offline,
      });

      final response = await client
          .put(
            Uri(path: "/chaos"),
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