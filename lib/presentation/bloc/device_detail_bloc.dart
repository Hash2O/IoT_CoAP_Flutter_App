import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/coap_temperature_service.dart';

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
  final double? temperature;
  final bool loading;
  final String? error;

  const DeviceDetailState({
    this.temperature,
    this.loading = false,
    this.error,
  });

  DeviceDetailState copyWith({
    double? temperature,
    bool? loading,
    String? error,
  }) {
    return DeviceDetailState(
      temperature: temperature ?? this.temperature,
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

  Timer? _autoRefreshTimer;

  DeviceDetailBloc(this.service, this.ip)
      : super(const DeviceDetailState()) {
    on<LoadTemperature>(_onLoadTemperature);
    on<UpdateTemperatureRequested>(_onUpdateTemperature);

    // 🔥 Auto-refresh toutes les 5 secondes
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => add(LoadTemperature()),
    );
  }

  Future<void> _onLoadTemperature(
      LoadTemperature event,
      Emitter<DeviceDetailState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    final temp = await service.getTemperature(ip);

    if (temp == null) {
      emit(state.copyWith(
        loading: false,
        error: "Unable to load temperature",
      ));
    } else {
      emit(state.copyWith(
        loading: false,
        temperature: temp,
      ));
    }
  }

  Future<void> _onUpdateTemperature(
      UpdateTemperatureRequested event,
      Emitter<DeviceDetailState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    final success =
        await service.setTemperature(ip, event.newValue);

    if (!success) {
      emit(state.copyWith(
        loading: false,
        error: "Update failed",
      ));
    } else {
      // Recharge immédiatement après modification
      add(LoadTemperature());
    }
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel(); // ✅ Important !
    return super.close();
  }
}