import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_coap_app/data/services/coap_health_service.dart';

import 'data/services/device_discovery_service.dart';
import 'presentation/bloc/device_bloc.dart';
import 'presentation/pages/device_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeviceBloc(
        DeviceDiscoveryService(),
        CoapHealthService(),
      ),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DeviceListPage(),
      ),
    );
  }
}