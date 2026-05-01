import 'dart:convert';
import 'package:coap/coap.dart';
import 'package:iot_coap_app/presentation/bloc/device_detail_bloc.dart';
import '../../domain/models/temperature_data.dart';

class CoapTemperatureService {
//   Future<TemperatureResponse?> getTemperature(String ip, int port) async {
//   try {
//     final client = CoapClient(Uri.parse("coap://$ip:$port"));

//     final response = await client
//         .get(Uri(path: "/temperature"))
//         .timeout(const Duration(seconds: 2));

//     client.close();

//     final decoded = utf8.decode(response.payload);
//     final json = jsonDecode(decoded);

//     return TemperatureResponse(
//       value: (json['value'] as num).toDouble(),
//       timestamp:
//           DateTime.fromMillisecondsSinceEpoch(json['ts']),
//     );
//   } catch (_) {
//     return null;
//   }
// }

Future<TemperatureData?> getTemperature(
  String ip,
  int port,
) async {
  try {
    final client = CoapClient(
      Uri.parse("coap://$ip:$port"),
    );

    final response = await client
        .get(Uri(path: "/temperature"))
        .timeout(const Duration(seconds: 2));

    client.close();

    final decoded = utf8.decode(response.payload);
    final json = jsonDecode(decoded);

    return TemperatureData.fromJson(json);

  } catch (_) {
    return null;
  }
}

// Future<TemperatureResponse?> setTemperature(
//     String ip,
//     int port,
//     double value,
// ) async {
//   try {
//     final client = CoapClient(Uri.parse("coap://$ip:$port"));
//     final payload = jsonEncode({"value": value});
//     final response = await client.put(
//       Uri(path: "/temperature"),
//       payload: payload,
//     );

//     client.close();

//     final decoded = utf8.decode(response.payload);
//     final json = jsonDecode(decoded);

//     return TemperatureResponse(
//       value: (json['value'] as num).toDouble(),
//       timestamp:
//           DateTime.fromMillisecondsSinceEpoch(json['ts']),
//     );
//   } catch (_) {
//     return null;
//   }
// }

Future<TemperatureData?> setTemperature(
  String ip,
  int port,
  double target,
) async {
  try {
    final client = CoapClient(
      Uri.parse("coap://$ip:$port"),
    );

    final payload = jsonEncode({
      "target": target,
    });

    final response = await client
        .put(
          Uri(path: "/temperature"),
          payload: payload,
        )
        .timeout(const Duration(seconds: 2));

    client.close();

    final decoded = utf8.decode(response.payload);
    final json = jsonDecode(decoded);

    return TemperatureData.fromJson(json);

  } catch (_) {
    return null;
  }
}
}