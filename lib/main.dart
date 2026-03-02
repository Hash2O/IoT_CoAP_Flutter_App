import 'dart:async';
import 'package:flutter/material.dart';

import 'data/services/device_discovery_service.dart';
import 'domain/models/device.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiscoveryTestPage(),
    );
  }
}

class DiscoveryTestPage extends StatefulWidget {
  const DiscoveryTestPage({super.key});

  @override
  State<DiscoveryTestPage> createState() => _DiscoveryTestPageState();
}

class _DiscoveryTestPageState extends State<DiscoveryTestPage> {
  final DeviceDiscoveryService discovery = DeviceDiscoveryService();

  StreamSubscription? _subscription;
  Timer? _statusTimer;

  final Map<String, Device> _devices = {};

  @override
  void initState() {
    super.initState();

    discovery.start();

    _subscription = discovery.deviceStream.listen((json) {
      final id = json['device_id'];

      setState(() {
        if (_devices.containsKey(id)) {
          _devices[id] = _devices[id]!.copyWith(
            lastSeen: DateTime.now(),
            status: ConnectionStatus.online,
          );
        } else {
          _devices[id] = Device.fromAnnounce(json);
        }
      });
    });

    _startStatusMonitoring();
  }

  void _startStatusMonitoring() {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final now = DateTime.now();

      setState(() {
        _devices.updateAll((key, device) {
          final diff = now.difference(device.lastSeen).inSeconds;

          if (diff <= 5) {
            return device.copyWith(status: ConnectionStatus.online);
          } else if (diff <= 10) {
            return device.copyWith(status: ConnectionStatus.degraded);
          } else {
            return device.copyWith(status: ConnectionStatus.offline);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _statusTimer?.cancel();
    discovery.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devices = _devices.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Discovery Test"),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];

          return ListTile(
            title: Text(device.name),
            subtitle: Text(
              "IP: ${device.ip}\n"
              "ID: ${device.deviceId}\n"
              "Last seen: ${device.lastSeen}\n"
              "Status: ${device.status.name}",
            ),
          );
        },
      ),
    );
  }
}