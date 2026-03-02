import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/device_discovery_service.dart';
import '../../data/services/coap_health_service.dart';
import '../../domain/models/device.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceDiscoveryService discoveryService;
  final CoapHealthService healthService;

  StreamSubscription? _subscription;
  Timer? _healthTimer;

  DeviceBloc(
    this.discoveryService,
    this.healthService,
  ) : super(DeviceState.initial()) {
    on<DeviceAnnounced>(_onDeviceAnnounced);
    on<DeviceHealthCheckRequested>(_onHealthCheckRequested);

    _startDiscovery();
    _startHealthMonitoring();
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

    final keys = devices.keys.toList(); // éviter modification concurrente

    for (final key in keys) {
      final device = devices[key]!;

      final success = await healthService.ping(device.ip);

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
    discoveryService.stop();
    return super.close();
  }
}