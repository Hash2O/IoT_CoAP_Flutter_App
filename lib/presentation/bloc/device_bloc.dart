import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_coap_app/data/services/coap_temperature_service.dart';

import '../../data/services/device_discovery_service.dart';
import '../../data/services/coap_health_service.dart';
import '../../domain/models/device.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceDiscoveryService discoveryService;
  final CoapHealthService healthService;
  final CoapTemperatureService temperatureService;

  StreamSubscription? _subscription;
  Timer? _healthTimer;
  Timer? _temperatureTimer;

  DeviceBloc(
  this.discoveryService,
  this.healthService,
  this.temperatureService,
) : super(DeviceState.initial()) {
  on<DeviceAnnounced>(_onDeviceAnnounced);
  on<DeviceHealthCheckRequested>(
    _onHealthCheckRequested,
  );
  on<DeviceTemperatureRefreshRequested>(
    _onTemperatureRefreshRequested,
  );

  _startDiscovery();
  _startHealthMonitoring();
  _startTemperatureMonitoring();
}

  void _startDiscovery() async {
    await discoveryService.start();

    _subscription = discoveryService.deviceStream.listen((json) {
      add(DeviceAnnounced(json));
    });
  }

  void _startHealthMonitoring() {
    _healthTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => add(DeviceHealthCheckRequested()),
    );
  }

  void _startTemperatureMonitoring() {
    _temperatureTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => add(DeviceTemperatureRefreshRequested()),
    );
  }

Future<void> _onTemperatureRefreshRequested(
  DeviceTemperatureRefreshRequested event,
  Emitter<DeviceState> emit,
) async {

  final devices =
      Map<String, Device>.from(state.devices);

  for (final entry in devices.entries) {

    final device = entry.value;

    final response =
        await temperatureService.getTemperature(
      device.ip,
      device.port,
    );

    if (response != null) {

      devices[entry.key] = device.copyWith(
        currentTemperature: response.current,
        targetTemperature: response.target,
        heating: response.heating,
      );
    }
  }

  emit(state.copyWith(devices: devices));
}
  void _onDeviceAnnounced(
    DeviceAnnounced event,
    Emitter<DeviceState> emit,
  ) {
    final id = event.json['device_id'];
    final devices = Map<String, Device>.from(state.devices);

    if (!devices.containsKey(id)) {
      devices[id] = Device.fromAnnounce(event.json);
      emit(state.copyWith(devices: devices));
    }
  }

  Future<void> _onHealthCheckRequested(
    DeviceHealthCheckRequested event,
    Emitter<DeviceState> emit,
  ) async {
    final devices = Map<String, Device>.from(state.devices);

    // Ici, éviter les modifications concurrentes
    final keys = devices.keys.toList(); 

    for (final key in keys) {
      final device = devices[key]!;

      final success = await healthService.ping(device.ip, device.port);

      if (success) {
        devices[key] = device.copyWith(
          status: ConnectionStatus.online,
          healthFailures: 0,
          lastSeen: DateTime.now(),
        );
      } else {
        final failures = device.healthFailures + 1;

        if (failures >= 3) {
          devices[key] = device.copyWith(
            status: ConnectionStatus.offline,
            healthFailures: failures,
          );
        } else {
          devices[key] = device.copyWith(
            status: ConnectionStatus.degraded,
            healthFailures: failures,
          );
        }
      }
    }

    emit(state.copyWith(devices: devices));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _healthTimer?.cancel();
    _temperatureTimer?.cancel();

    discoveryService.stop();

    return super.close();
  }
}