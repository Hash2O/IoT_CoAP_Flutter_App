enum ConnectionStatus {
  unknown,
  online,
  degraded,
  offline,
}

class Device {
  final String deviceId;
  final String name;
  final String ip;
  final DateTime lastSeen;
  final ConnectionStatus status;

  Device({
    required this.deviceId,
    required this.name,
    required this.ip,
    required this.lastSeen,
    required this.status,
  });

  factory Device.fromAnnounce(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      name: json['name'],
      ip: json['ip'],
      lastSeen: DateTime.now(),
      status: ConnectionStatus.online,
    );
  }

  Device copyWith({
    String? deviceId,
    String? name,
    String? ip,
    DateTime? lastSeen,
    ConnectionStatus? status,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
    );
  }
}