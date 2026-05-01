import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/coap_temperature_service.dart';

import '../../domain/models/temperature_data.dart';

/*
Objectifs du script amélioré : 
- Un seul timer
- Annulation propre
- Pas de fuite mémoire
- Refresh automatique
- Reload après PUT
*/

/// EVENTS
abstract class DeviceDetailEvent {}

class LoadTemperature extends DeviceDetailEvent {}

class UpdateTemperatureRequested extends DeviceDetailEvent {
  final double newValue;
  UpdateTemperatureRequested(this.newValue);
}

/// STATE
class DeviceDetailState {
  final TemperatureData? temperatureData;
  final bool loading;
  final String? error;

  const DeviceDetailState({
    this.temperatureData,
    this.loading = false,
    this.error,
  });

  DeviceDetailState copyWith({
    TemperatureData? temperatureData,
    bool? loading,
    String? error,
  }) {
    return DeviceDetailState(
      temperatureData:
          temperatureData ?? this.temperatureData,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// BLOC
class DeviceDetailBloc
    extends Bloc<DeviceDetailEvent, DeviceDetailState> {
  final CoapTemperatureService service;
  final String ip;
  final int port;

  Timer? _autoRefreshTimer;

  DeviceDetailBloc(this.service, this.ip, this.port)
      : super(const DeviceDetailState()) {
    on<LoadTemperature>(_onLoadTemperature);
    on<UpdateTemperatureRequested>(_onUpdateTemperature);

    //Auto-refresh toutes les 5 secondes
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => add(LoadTemperature()),
    );
  }

  Future<void> _onLoadTemperature(
    LoadTemperature event,
    Emitter<DeviceDetailState> emit) async {

    emit(state.copyWith(loading: true, error: null));

    final response =
    await service.getTemperature(ip, port);

if (response == null) {
  emit(state.copyWith(
    loading: false,
    error: "Unable to load temperature",
  ));
} else {
  emit(state.copyWith(
    loading: false,
    temperatureData: response,
  ));
}
  }

  Future<void> _onUpdateTemperature(
  UpdateTemperatureRequested event,
  Emitter<DeviceDetailState> emit,
) async {

  emit(state.copyWith(
    loading: true,
    error: null,
  ));

  final response =
      await service.setTemperature(
    ip,
    port,
    event.newValue,
  );

  if (response == null) {

    emit(state.copyWith(
      loading: false,
      error: "Update failed",
    ));

  } else {

    emit(state.copyWith(
      loading: false,
      temperatureData: response,
    ));

  }
}

  // Fermeture et libération des ressources
  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel(); 
    return super.close();
  }
}