abstract class DeviceEvent {}

class DeviceAnnounced extends DeviceEvent {
  final Map<String, dynamic> json;

  DeviceAnnounced(this.json);
}

class DeviceStatusCheckRequested extends DeviceEvent {}