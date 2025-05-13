part of 'connectivity_bloc.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
  
  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityLoading extends ConnectivityState {}

class ConnectivityConnected extends ConnectivityState {
  final ConnectivityResult connectionType;
  
  const ConnectivityConnected(this.connectionType);
  
  @override
  List<Object> get props => [connectionType];
}

class ConnectivityDisconnected extends ConnectivityState {}

class ConnectivityFailure extends ConnectivityState {}
