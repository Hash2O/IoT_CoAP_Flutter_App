import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_coap_app/chaos_panel.dart';
import 'package:iot_coap_app/domain/models/temperature_data.dart';

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
              temperatureData: state.temperatureData,
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
  final TemperatureData? temperatureData;
  final String ip;
  final int port;
  final bool loading;
  final String? error;

  const _TemperatureView({
    required this.temperatureData,
    required this.ip,
    required this.port,
    required this.loading,
    required this.error,
  });

  @override
  State<_TemperatureView> createState() => _TemperatureViewState();
}

class _TemperatureViewState extends State<_TemperatureView> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue =
    widget.temperatureData?.target ?? 22.0;
  }

  @override
  void didUpdateWidget(covariant _TemperatureView oldWidget) {
    super.didUpdateWidget(oldWidget);

if (widget.temperatureData != null) {
  if (widget.temperatureData != null &&
    oldWidget.temperatureData?.target !=
        widget.temperatureData?.target) {
      _currentValue =
        widget.temperatureData!.target;
    }  
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
    else if (widget.temperatureData != null) {
      content = Column(
        children: [
          Text(
            "${widget.temperatureData!.current.toStringAsFixed(1)} °C",
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Target : "
            "${widget.temperatureData!.target.toStringAsFixed(1)} °C",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),

          Chip(
            backgroundColor:
                widget.temperatureData!.heating
                    ? Colors.orange.shade200
                    : Colors.blueGrey.shade200,
            label: Text(
              widget.temperatureData!.heating
                  ? "Heating"
                  : "Idle",
            ),
          ),
          const SizedBox(height: 8),

             Text(
              "Updated at: ${_formatTime(
                widget.temperatureData!.timestamp,
              )}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

          const SizedBox(height: 30),

          Slider(
            label: "${_currentValue.toStringAsFixed(1)} °C",
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