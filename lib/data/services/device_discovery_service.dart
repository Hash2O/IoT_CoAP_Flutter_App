import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DeviceDiscoveryService {
  static const String multicastAddress = '239.255.255.250';
  static const int multicastPort = 5684;

  RawDatagramSocket? _socket;
  final StreamController<Map<String, dynamic>> _deviceController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get deviceStream =>
      _deviceController.stream;

  Future<void> start() async {
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      multicastPort,
      reuseAddress: true,
      reusePort: true,
    );

    _socket!.joinMulticast(
      InternetAddress(multicastAddress),
    );

    _socket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket!.receive();

        if (datagram != null) {
          try {
            final message = utf8.decode(datagram.data);
            final jsonData = jsonDecode(message);

            _deviceController.add(jsonData);

          } catch (e) {
            print("Invalid announce packet: $e");
          }
        }
      }
    });
  }

  void stop() {
    _socket?.close();
    _deviceController.close();
  }
}