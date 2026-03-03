import 'package:flutter/material.dart';
import '../../data/services/coap_chaos_service.dart';

class ChaosPanel extends StatefulWidget {
  final String ip;
  final int port;

  const ChaosPanel({
    super.key,
    required this.ip,
    required this.port,
  });

  @override
  State<ChaosPanel> createState() => _ChaosPanelState();
}

class _ChaosPanelState extends State<ChaosPanel> {

  final _service = CoapChaosService();

  double latency = 0;
  double loss = 0;
  bool offline = false;
  bool loading = false;

  Future<void> _applyChaos() async {
    setState(() => loading = true);

    await _service.updateChaos(
      ip: widget.ip,
      port: widget.port,
      latencyMs: latency.toInt(),
      lossRate: loss,
      offline: offline,
    );

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          const Text(
            "⚙ Simulation d'instabilité",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Latency Slider
          Text("Latence: ${latency.toInt()} ms"),
          Slider(
            min: 0,
            max: 2000,
            divisions: 20,
            value: latency,
            onChanged: (value) {
              setState(() => latency = value);
            },
          ),

          const SizedBox(height: 12),

          // Loss Slider
          Text("Perte de paquets: ${(loss * 100).toInt()}%"),
          Slider(
            min: 0,
            max: 1,
            divisions: 10,
            value: loss,
            onChanged: (value) {
              setState(() => loss = value);
            },
          ),

          const SizedBox(height: 12),

          // Offline Switch
          SwitchListTile(
            title: const Text("Mode Offline"),
            value: offline,
            onChanged: (value) {
              setState(() => offline = value);
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: loading ? null : _applyChaos,
            child: loading
                ? const CircularProgressIndicator()
                : const Text("Appliquer"),
          ),
        ],
      ),
    );
  }
}