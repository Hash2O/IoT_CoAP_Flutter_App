import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/coap_temperature_service.dart';

///***********************
// Events
///***********************

abstract class DeviceDetailEvent {}

class LoadTemperature extends DeviceDetailEvent {}

class UpdateTemperatureRequested extends DeviceDetailEvent {
  final double newValue;

  UpdateTemperatureRequested(this.newValue);
}
///***********************
// State
/// **********************

class DeviceDetailState {
  final double? temperature;
  final bool loading;
  final String? error;

  DeviceDetailState({
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

///***********************
// Bloc
///***********************

class DeviceDetailBloc
    extends Bloc<DeviceDetailEvent, DeviceDetailState> {
  final CoapTemperatureService service;
  final String ip;

  DeviceDetailBloc(this.service, this.ip)
      : super(DeviceDetailState()) {
    on<LoadTemperature>(_onLoadTemperature);
    on<UpdateTemperatureRequested>(_onUpdateTemperature);
  }

  Future<void> _onLoadTemperature(
      LoadTemperature event,
      Emitter<DeviceDetailState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    final temp = await service.getTemperature(ip);

    if (temp == null) {
      emit(state.copyWith(
        loading: false,
        error: "Failed to load temperature",
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
        error: "Failed to update temperature",
      ));
    } else {
      add(LoadTemperature());
    }
  }
}