// Modèle Device propre

// But compteur échecs : 1 échec => degraded, 3 échecs => offline

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
  final int healthFailures; // Ajout compteur d'échecs

  Device({
    required this.deviceId,
    required this.name,
    required this.ip,
    required this.lastSeen,
    required this.status,
    required this.healthFailures,
  });

  factory Device.fromAnnounce(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      name: json['name'],
      ip: json['ip'],
      lastSeen: DateTime.now(),
      status: ConnectionStatus.online,
      healthFailures: 0,
    );
  }

  Device copyWith({
    String? deviceId,
    String? name,
    String? ip,
    DateTime? lastSeen,
    ConnectionStatus? status,
    int? healthFailures,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      healthFailures: healthFailures ?? this.healthFailures,
    );
  }
}