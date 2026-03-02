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

class _TemperatureView extends StatefulWidget {
  final double temperature;

  const _TemperatureView({required this.temperature});

  @override
  State<_TemperatureView> createState() => _TemperatureViewState();
}

class _TemperatureViewState extends State<_TemperatureView> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.temperature;
  }

  @override
  void didUpdateWidget(covariant _TemperatureView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentValue = widget.temperature;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${_currentValue.toStringAsFixed(1)} °C",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          Slider(
            value: _currentValue,
            min: 10,
            max: 35,
            divisions: 50,
            label: _currentValue.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              context.read<DeviceDetailBloc>().add(
                    UpdateTemperatureRequested(_currentValue),
                  );
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }
}