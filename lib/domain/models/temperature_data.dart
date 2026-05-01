class TemperatureData {
  final double current;
  final double target;
  final bool heating;
  final DateTime timestamp;

  const TemperatureData({
    required this.current,
    required this.target,
    required this.heating,
    required this.timestamp,
  });

  factory TemperatureData.fromJson(Map<String, dynamic> json) {
    return TemperatureData(
      current: (json['current'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
      heating: json['heating'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['ts']),
    );
  }
}