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

              return ListTile(
                title: Text(device.name),
                subtitle: Text(device.ip),
                trailing: _buildStatusBadge(device.status),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeviceDetailPage(
                        ip: device.ip,
                        name: device.name,
                      ),
                    ),
                  );
                },
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

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}