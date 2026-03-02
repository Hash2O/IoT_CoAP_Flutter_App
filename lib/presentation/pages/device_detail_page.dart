import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/coap_temperature_service.dart';
import '../bloc/device_detail_bloc.dart';

class DeviceDetailPage extends StatelessWidget {
  final String ip;
  final String name;

  const DeviceDetailPage({
    super.key,
    required this.ip,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DeviceDetailBloc(CoapTemperatureService(), ip)
            ..add(LoadTemperature()),
      child: Scaffold(
        appBar: AppBar(title: Text(name)),
        body: BlocBuilder<DeviceDetailBloc, DeviceDetailState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            if (state.temperature == null) {
              return const Center(child: Text("No data"));
            }

            return _TemperatureView(
              temperature: state.temperature!,
            );
          },
        ),
      ),
    );
  }
}

class _TemperatureView extends StatelessWidget {
  final double temperature;

  const _TemperatureView({required this.temperature});

  @override
  Widget build(BuildContext context) {
    final controller =
        TextEditingController(text: temperature.toString());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Current temperature: $temperature °C",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: "New temperature"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final value =
                  double.tryParse(controller.text);

              if (value != null) {
                context.read<DeviceDetailBloc>().add(
                      UpdateTemperatureRequested(value),
                    );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}