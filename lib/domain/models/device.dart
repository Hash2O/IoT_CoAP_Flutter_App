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
  final int port;
  final DateTime lastSeen;
  final ConnectionStatus status;
  final int healthFailures; // Ajout compteur d'échecs
  final double? currentTemperature;
  final double? targetTemperature;
  final bool? heating;

  Device({
    required this.deviceId,
    required this.name,
    required this.ip,
    required this.port,
    required this.lastSeen,
    required this.status,
    required this.healthFailures,
    required this.currentTemperature,
    required this.targetTemperature,
    required this.heating,
  });

  factory Device.fromAnnounce(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      name: json['name'],
      ip: json['ip'],
      port: json['port'] ?? 5683,
      lastSeen: DateTime.now(),
      status: ConnectionStatus.online,
      healthFailures: 0, 
      currentTemperature: null, 
      targetTemperature: null, 
      heating: null,
    );
  }

  Device copyWith({
    String? deviceId,
    String? name,
    String? ip,
    int? port,
    DateTime? lastSeen,
    ConnectionStatus? status,
    int? healthFailures,
    double? currentTemperature,
    double? targetTemperature,
    bool? heating,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      healthFailures: healthFailures ?? this.healthFailures,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      heating: heating ?? this.heating,
    );
  }

  @override
  String toString() {
    return "$name ($ip:$port)";
  }
}