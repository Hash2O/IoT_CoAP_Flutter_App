import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/device_discovery_service.dart';
import '../../domain/models/device.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceDiscoveryService discoveryService;

  StreamSubscription? _subscription;
  Timer? _statusTimer;

  DeviceBloc(this.discoveryService) : super(DeviceState.initial()) {
    on<DeviceAnnounced>(_onDeviceAnnounced);
    on<DeviceStatusCheckRequested>(_onStatusCheckRequested);

    _startDiscovery();
    _startStatusMonitoring();
  }

  void _startDiscovery() async {
    await discoveryService.start();

    _subscription = discoveryService.deviceStream.listen((json) {
      add(DeviceAnnounced(json));
    });
  }

  void _startStatusMonitoring() {
    _statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => add(DeviceStatusCheckRequested()),
    );
  }

  void _onDeviceAnnounced(
    DeviceAnnounced event,
    Emitter<DeviceState> emit,
  ) {
    final id = event.json['device_id'];
    final devices = Map<String, Device>.from(state.devices);

    if (devices.containsKey(id)) {
      devices[id] = devices[id]!.copyWith(
        lastSeen: DateTime.now(),
        status: ConnectionStatus.online,
      );
    } else {
      devices[id] = Device.fromAnnounce(event.json);
    }

    emit(state.copyWith(devices: devices));
  }

  void _onStatusCheckRequested(
    DeviceStatusCheckRequested event,
    Emitter<DeviceState> emit,
  ) {
    final now = DateTime.now();
    final devices = Map<String, Device>.from(state.devices);

    devices.updateAll((key, device) {
      final diff = now.difference(device.lastSeen).inSeconds;

      if (diff <= 5) {
        return device.copyWith(status: ConnectionStatus.online);
      } else if (diff <= 10) {
        return device.copyWith(status: ConnectionStatus.degraded);
      } else {
        return device.copyWith(status: ConnectionStatus.offline);
      }
    });

    emit(state.copyWith(devices: devices));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _statusTimer?.cancel();
    discoveryService.stop();
    return super.close();
  }
}