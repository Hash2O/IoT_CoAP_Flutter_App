import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/device_bloc.dart';

import 'presentation/pages/login_page.dart';

import 'data/services/device_discovery_service.dart';
import 'data/services/coap_health_service.dart';
import 'data/services/coap_temperature_service.dart';

import 'data/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [

        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            AuthService(),
          ),
        ),

        BlocProvider<DeviceBloc>(
          create: (_) => DeviceBloc(
            DeviceDiscoveryService(),
            CoapHealthService(),
            CoapTemperatureService(),
          ),
        ),

      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}