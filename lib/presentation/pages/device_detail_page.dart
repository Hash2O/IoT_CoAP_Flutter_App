import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_coap_app/chaos_panel.dart';

import '../../data/services/coap_temperature_service.dart';
import '../bloc/device_detail_bloc.dart';

class DeviceDetailPage extends StatelessWidget {
  final String ip;
  final String name;
  final int port;

  const DeviceDetailPage({
    super.key,
    required this.ip,
    required this.name,
    required this.port,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DeviceDetailBloc(CoapTemperatureService(), ip, port)
            ..add(LoadTemperature()),
      child: Scaffold(
        appBar: AppBar(title: Text(name)),
        body: BlocBuilder<DeviceDetailBloc, DeviceDetailState>(
          builder: (context, state) {
            return _TemperatureView(
              temperature: state.temperature,
              lastUpdate: state.lastUpdate,
              ip: ip,
              port: port,
              loading: state.loading,
              error: state.error,
            );
          },
        ),
      ),
    );
  }
}

class _TemperatureView extends StatefulWidget {
  final double? temperature;
  final String ip;
  final int port;
  final bool loading;
  final String? error;
  final DateTime? lastUpdate;

  const _TemperatureView({
    required this.temperature,
    required this.ip,
    required this.port,
    required this.loading,
    required this.error,
    required this.lastUpdate,
  });

  @override
  State<_TemperatureView> createState() => _TemperatureViewState();
}

class _TemperatureViewState extends State<_TemperatureView> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.temperature ?? 22.0;
  }

  @override
  void didUpdateWidget(covariant _TemperatureView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.temperature != null) {
      _currentValue = widget.temperature!;
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget content;

    if (widget.loading) {
      content = const CircularProgressIndicator();
    } 
    else if (widget.error != null) {
      content = Text(
        widget.error!,
        style: const TextStyle(color: Colors.red),
      );
    } 
    else if (widget.temperature != null) {
      content = Column(
        children: [
          Text(
            "${_currentValue.toStringAsFixed(1)} °C",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          if (widget.lastUpdate != null)
            Text(
              "Updated at: ${_formatTime(widget.lastUpdate!)}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

          const SizedBox(height: 30),

          Slider(
            value: _currentValue,
            min: 10,
            max: 35,
            divisions: 50,
            onChanged: widget.error != null // grise le slider en cas d’erreur
                ? null
                : (value) {
                    setState(() => _currentValue = value);
                  },
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DeviceDetailBloc>().add(
                UpdateTemperatureRequested(_currentValue),
              );
            },
            child: const Text("Apply"),
          ),
        ],
      );
    } 
    else {
      content = const Text("No data");
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          Expanded(child: Center(child: content)),

          const Divider(),

          ElevatedButton(
            child: const Text("Mode Admin"),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => ChaosPanel(
                  ip: widget.ip,
                  port: widget.port,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
  return "${date.hour.toString().padLeft(2, '0')}:"
         "${date.minute.toString().padLeft(2, '0')}:"
         "${date.second.toString().padLeft(2, '0')}";
}

}