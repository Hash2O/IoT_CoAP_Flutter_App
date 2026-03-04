import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/device_bloc.dart';
import '../bloc/device_state.dart';
import '../pages/device_detail_page.dart';
import '../../domain/models/device.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discovered Devices"),
      ),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          final devices = state.devices.values.toList();

          if (devices.isEmpty) {
            return const Center(
              child: Text("No devices discovered"),
            );
          }

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    device.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text("IP: ${device.ip}:${device.port}"),
                      Text("ID: ${device.deviceId}"),
                      Text(
                        "Last seen: ${_formatDate(device.lastSeen)}",
                      ),
                    ],
                  ),
                  trailing:
                      _buildStatusBadge(device.status),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DeviceDetailPage(
                          ip: device.ip,
                          port: device.port,
                          name: device.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(ConnectionStatus status) {
    Color color;

    switch (status) {
      case ConnectionStatus.online:
        color = Colors.green;
        break;
      case ConnectionStatus.degraded:
        color = Colors.orange;
        break;
      case ConnectionStatus.offline:
        color = Colors.red;
        break;
      case ConnectionStatus.unknown:
      color = Colors.black;
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          status.name,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}:"
        "${date.second.toString().padLeft(2, '0')}";
  }
}