import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  
  ConnectivityBloc(this.connectivity) : super(ConnectivityInitial()) {
    on<InitializeConnectivity>(_onInitializeConnectivity);
    on<ConnectivityChanged>(_onConnectivityChanged);
  }
  
  Future<void> _onInitializeConnectivity(
    InitializeConnectivity event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(ConnectivityLoading());
    
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      emit(_mapResultToState(connectivityResult));
      
      _connectivitySubscription = connectivity.onConnectivityChanged.listen(
        (result) => add(ConnectivityChanged(result)),
      );
    } catch (_) {
      emit(ConnectivityFailure());
    }
  }
  
  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(_mapResultToState(event.result));
  }
  
  ConnectivityState _mapResultToState(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return ConnectivityConnected(result);
      case ConnectivityResult.none:
        return ConnectivityDisconnected();
      default:
        return ConnectivityDisconnected();
    }
  }
  
  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
