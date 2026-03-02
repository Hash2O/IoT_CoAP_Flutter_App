import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_coap_app/presentation/pages/device_detail_page.dart';

import '../bloc/device_bloc.dart';
import '../bloc/device_state.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Devices")),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          final devices = state.devices.values.toList();

          if (devices.isEmpty) {
            return const Center(child: Text("No devices found"));
          }

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];

              return ListTile(
                title: Text(device.name),
                subtitle: Text(
                  "IP: ${device.ip}\n"
                  "Status: ${device.status.name}",
                ),
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
}