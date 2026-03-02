import '../../domain/models/device.dart';

class DeviceState {
  final Map<String, Device> devices;

  DeviceState({required this.devices});

  factory DeviceState.initial() {
    return DeviceState(devices: {});
  }

  DeviceState copyWith({
    Map<String, Device>? devices,
  }) {
    return DeviceState(
      devices: devices ?? this.devices,
    );
  }
}